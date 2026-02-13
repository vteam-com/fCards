import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication helper for guest mode and Google sign-in flows.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Emits auth updates whenever Firebase user state changes.
  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Returns the currently signed-in Firebase user, if available.
  static User? get currentUser => _auth.currentUser;

  /// Ensures there is at least an anonymous authenticated user session.
  static Future<void> ensureSignedIn() async {
    if (_auth.currentUser != null) {
      return;
    }

    await _auth.signInAnonymously();
  }

  /// Signs in with Google and links anonymous users when possible.
  static Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');
      provider.setCustomParameters({'prompt': 'select_account'});
      return _auth.signInWithPopup(provider);
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign_in_canceled',
        message: 'Google sign-in was canceled by the user.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      try {
        return await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'credential-already-in-use') {
          await user.delete();
          return _auth.signInWithCredential(credential);
        }

        rethrow;
      }
    }

    return _auth.signInWithCredential(credential);
  }

  /// Signs out from Firebase and clears native Google session state.
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } finally {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    }
  }
}
