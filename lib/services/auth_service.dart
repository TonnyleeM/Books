import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp(String email, String password) async {
    try {
      if (kIsWeb) {
        // For web, disable app verification
        await _auth.setSettings(appVerificationDisabledForTesting: true);
      }
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('SignUp error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      if (kIsWeb) {
        // For web, disable app verification
        await _auth.setSettings(appVerificationDisabledForTesting: true);
      }
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('SignIn error: $e');
      rethrow;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Resend verification error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('SignOut error: $e');
      rethrow;
    }
  }
}
