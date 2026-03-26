import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(name);
    // OTP email is sent via Cloud Function — no Firebase link needed

    final user = UserModel(
      id: credential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toMap());
    return user;
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _getUserById(credential.user!.uid);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<UserModel?> _getUserById(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<UserModel?> getCurrentUserProfile() async {
    if (currentUser == null) return null;
    return _getUserById(currentUser!.uid);
  }

  Future<void> updateProfile(
      {required String name, required String phone}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(name);

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update({
      'name': name,
      'phone': phone,
      'updatedAt':
          DateTime.now().toIso8601String(), // or FieldValue.serverTimestamp()
    });
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updatePhotoURL(photoUrl);
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update({'photoUrl': photoUrl});
  }

  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user currently logged in.');
    if (user.email == null) throw Exception('User email is null.');

    // 1. Re-authenticate the user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // 2. Update password
    await user.updatePassword(newPassword);
  }
}
