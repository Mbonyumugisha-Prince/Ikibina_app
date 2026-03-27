import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/otp_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final OtpService _otpService = OtpService();

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  // Reads emailVerified from the Firestore user document
  bool get isEmailVerified => _user?.emailVerified ?? false;
  bool get twoFactorEnabled => _user?.twoFactorEnabled ?? false;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      _user = await _authService.getCurrentUserProfile();
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      _user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      _user = await _authService.signIn(email: email, password: password);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Generates OTP, saves to Firestore, sends email via Gmail SMTP.
  Future<bool> sendOtp({
    required String email,
    required String name,
  }) async {
    final uid = _authService.currentUser?.uid ?? '';
    try {
      await _otpService.sendOtp(uid, email, name: name);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Verifies OTP from Firestore. On success updates emailVerified in Firestore.
  Future<bool> verifyOtp(String otp) async {
    final email = _authService.currentUser?.email ?? '';
    _setLoading(true);
    try {
      final result = await _otpService.verifyOtp(email, otp);
      if (result == OtpResult.success) {
        // Reload user from Firestore so isEmailVerified reflects the update
        _user = await _authService.getCurrentUserProfile();
        _error = null;
        notifyListeners();
        return true;
      }
      _error = _otpResultMessage(result);
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _otpResultMessage(OtpResult r) {
    switch (r) {
      case OtpResult.invalid:
        return 'Incorrect code. Please try again.';
      case OtpResult.expired:
        return 'Code expired. Tap resend for a new one.';
      case OtpResult.alreadyUsed:
        return 'Code already used. Tap resend.';
      case OtpResult.notFound:
        return 'Code not found. Tap resend.';
      default:
        return 'Verification failed.';
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(
      {required String currentPassword, required String newPassword}) async {
    _setLoading(true);
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(
      {required String name, required String phone}) async {
    _setLoading(true);
    try {
      await _authService.updateProfile(name: name, phone: phone);
      // Refresh the user data
      _user = await _authService.getCurrentUserProfile();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePhotoUrl(String photoUrl) async {
    _setLoading(true);
    try {
      await _authService.updatePhotoUrl(photoUrl);
      _user = await _authService.getCurrentUserProfile();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sends a login verification OTP to the current user's email.
  /// Uses a login-specific email template, distinct from the 2FA setup email.
  Future<bool> sendLogin2FAOtp() async {
    final uid = _authService.currentUser?.uid ?? '';
    final email = _authService.currentUser?.email ?? '';
    final name = _user?.name ?? '';
    try {
      await _otpService.sendLogin2FAOtp(uid, email, name: name);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Verifies the login 2FA OTP without changing the twoFactorEnabled flag.
  Future<bool> verifyLogin2FAOtp(String otp) async {
    final email = _authService.currentUser?.email ?? '';
    _setLoading(true);
    try {
      final result = await _otpService.verify2FAOtp(email, otp);
      if (result == OtpResult.success) {
        _error = null;
        return true;
      }
      _error = _otpResultMessage(result);
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Re-authenticates with password, then sends a 2FA OTP to the user's email.
  Future<bool> initiate2FASetup(String password) async {
    _setLoading(true);
    try {
      await _authService.reauthenticate(password);
      final email = _authService.currentUser?.email ?? '';
      final name = _user?.name ?? '';
      final uid = _authService.currentUser?.uid ?? '';
      await _otpService.send2FAOtp(uid, email, name: name);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verifies the 2FA OTP and enables 2FA on success.
  Future<bool> verify2FAAndEnable(String otp) async {
    final email = _authService.currentUser?.email ?? '';
    _setLoading(true);
    try {
      final result = await _otpService.verify2FAOtp(email, otp);
      if (result == OtpResult.success) {
        await _authService.set2FAEnabled(true);
        _user = await _authService.getCurrentUserProfile();
        _error = null;
        notifyListeners();
        return true;
      }
      _error = _otpResultMessage(result);
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Disables 2FA for the current user.
  Future<bool> disable2FA() async {
    _setLoading(true);
    try {
      await _authService.set2FAEnabled(false);
      _user = await _authService.getCurrentUserProfile();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateNotificationSettings(
      Map<String, dynamic> notificationSettings) async {
    _setLoading(true);
    try {
      await _authService.updateNotificationSettings(notificationSettings);
      _user = await _authService.getCurrentUserProfile();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
