import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

const String googleSignInFieldEmail = 'email';
const String googleSignInFieldProfile = 'profile';

/// Authentication helper for guest mode and Google sign-in flows.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _initialized = false;

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

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize();
    _initialized = true;
  }

  /// Signs in with Google and links anonymous users when possible.
  static Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.addScope(googleSignInFieldEmail);
      provider.addScope(googleSignInFieldProfile);
      provider.setCustomParameters({'prompt': 'select_account'});
      return _auth.signInWithPopup(provider);
    }

    await _ensureInitialized();

    final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: [googleSignInFieldEmail, googleSignInFieldProfile],
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        throw FirebaseAuthException(
          code: 'sign_in_canceled',
          message: 'Google sign-in was canceled by the user.',
        );
      }
      rethrow;
    }

    final googleAuth = googleUser.authentication;
    final authz = await googleUser.authorizationClient.authorizationForScopes([
      googleSignInFieldEmail,
      googleSignInFieldProfile,
    ]);

    final credential = GoogleAuthProvider.credential(
      accessToken: authz?.accessToken,
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
        await _ensureInitialized();
        await GoogleSignIn.instance.signOut();
      }
    }
  }
}
