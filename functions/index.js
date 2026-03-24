/* eslint-disable max-len */
const {setGlobalOptions} = require("firebase-functions");
const functions = require("firebase-functions/v1");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const crypto = require("crypto");
const {sendWelcomeEmail, sendOtpEmail} = require("./services/emailService");

// Initialize Admin SDK once
if (admin.apps.length === 0) admin.initializeApp();
const db = admin.firestore();

setGlobalOptions({maxInstances: 10});

// ─────────────────────────────────────────────────────────────
//  AUTH TRIGGER — send welcome email on new user creation
// ─────────────────────────────────────────────────────────────
exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
  const {uid, email, displayName} = user;

  if (!email) {
    logger.warn("onUserCreated: no email for user", {uid});
    return null;
  }

  const name = displayName || "there";

  try {
    const result = await sendWelcomeEmail(name, email);
    logger.info("Welcome email sent", {uid, email, messageId: result && result.id});
  } catch (err) {
    logger.error("Failed to send welcome email", {uid, email, error: err.message});
  }

  return null;
});

// ─────────────────────────────────────────────────────────────
//  CALLABLE — generate OTP and send verification email
// ─────────────────────────────────────────────────────────────
exports.sendVerificationOtp = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in");
  }

  const uid = request.auth.uid;
  const {email, name} = request.data;

  if (!email || !name) {
    throw new HttpsError("invalid-argument", "email and name are required");
  }

  // Generate a secure 6-digit OTP
  const otp = crypto.randomInt(100000, 999999).toString();
  const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 min

  // Store in Firestore (overwrites any previous OTP)
  await db.collection("email_otps").doc(uid).set({
    otp,
    expiresAt,
    verified: false,
    attempts: 0,
    createdAt: new Date(),
  });

  try {
    const result = await sendOtpEmail(name, email, otp);
    logger.info("OTP email sent", {uid, email, messageId: result && result.id});
  } catch (err) {
    logger.error("Failed to send OTP email", {uid, email, error: err.message});
    throw new HttpsError("internal", "Failed to send verification email");
  }

  return {success: true};
});

// ─────────────────────────────────────────────────────────────
//  CALLABLE — verify OTP entered by user
// ─────────────────────────────────────────────────────────────
exports.verifyEmailOtp = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in");
  }

  const uid = request.auth.uid;
  const {otp} = request.data;

  if (!otp || otp.length !== 6) {
    throw new HttpsError("invalid-argument", "A 6-digit OTP is required");
  }

  const docRef = db.collection("email_otps").doc(uid);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new HttpsError("not-found", "No OTP found. Please request a new one.");
  }

  const data = doc.data();

  // Already verified
  if (data.verified) return {success: true};

  // Too many attempts (max 5)
  if (data.attempts >= 5) {
    throw new HttpsError("resource-exhausted", "Too many attempts. Request a new code.");
  }

  // Expired
  if (new Date() > data.expiresAt.toDate()) {
    throw new HttpsError("deadline-exceeded", "Code expired. Please request a new one.");
  }

  // Wrong code — increment attempts
  if (data.otp !== otp) {
    await docRef.update({attempts: admin.firestore.FieldValue.increment(1)});
    throw new HttpsError("invalid-argument", "Incorrect code. Please try again.");
  }

  // ✅ Valid — mark verified + update Firebase Auth emailVerified flag
  await Promise.all([
    docRef.update({verified: true}),
    admin.auth().updateUser(uid, {emailVerified: true}),
  ]);

  logger.info("Email verified via OTP", {uid});
  return {success: true};
});
