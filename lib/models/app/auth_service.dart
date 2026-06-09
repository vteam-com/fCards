import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

const String googleSignInFieldEmail = 'email';
const String googleSignInFieldProfile = 'profile';
const String googleSignInPromptSelectAccount = 'select_account';

/// Authentication helper for guest mode and Google sign-in flows.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _initialized = false;

  /// Emits auth updates whenever Firebase user state changes.
  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Returns the currently signed-in Firebase user, if available.
  static User? get currentUser => _auth.currentUser;

  /// Returns true when the current auth session belongs to a non-anonymous user.
  static bool get isSignedInWithAccount {
    final user = _auth.currentUser;
    return user != null && !user.isAnonymous;
  }

  /// Ensures there is at least an anonymous authenticated user session.
  static Future<void> ensureSignedIn() async {
    if (_auth.currentUser != null) {
      return;
    }

    await _auth.signInAnonymously();
  }

  static bool get _usesGoogleSignInPluginFlow =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize();
    _initialized = true;
  }

  /// Completes Google auth via `google_sign_in` and maps it to Firebase.
  ///
  /// This path is required on macOS because `signInWithProvider` is not
  /// implemented by the current Firebase Auth macOS plugin.
  static Future<UserCredential> _signInWithGooglePlugin() async {
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

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final GoogleSignInClientAuthorization? authz = await googleUser
        .authorizationClient
        .authorizationForScopes([
          googleSignInFieldEmail,
          googleSignInFieldProfile,
        ]);

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: authz?.accessToken,
      idToken: googleAuth.idToken,
    );

    final User? user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      try {
        return await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'credential-already-in-use' ||
            error.code == 'provider-already-linked') {
          await user.delete();
          return _auth.signInWithCredential(credential);
        }

        rethrow;
      }
    }

    return _auth.signInWithCredential(credential);
  }

  /// Signs in with Google and links anonymous users when possible.
  static Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    provider.addScope(googleSignInFieldEmail);
    provider.addScope(googleSignInFieldProfile);
    provider.setCustomParameters({'prompt': googleSignInPromptSelectAccount});

    if (kIsWeb) {
      return _auth.signInWithPopup(provider);
    }

    if (_usesGoogleSignInPluginFlow) {
      return _signInWithGooglePlugin();
    }

    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      try {
        return await user.linkWithProvider(provider);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'credential-already-in-use' ||
            error.code == 'provider-already-linked') {
          await user.delete();
          return _auth.signInWithProvider(provider);
        }

        rethrow;
      }
    }

    return _auth.signInWithProvider(provider);
  }

  /// Signs out from Firebase.
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } finally {
      if (_usesGoogleSignInPluginFlow) {
        await _ensureInitialized();
        await GoogleSignIn.instance.signOut();
      }
    }
  }
}
