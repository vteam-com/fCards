import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

const String appleSignInFieldEmail = 'email';
const String appleSignInFieldName = 'name';
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

  /// Returns true on platforms where this app currently exposes Apple sign-in.
  ///
  /// macOS is intentionally excluded here because the native Apple sign-in
  /// entitlement requires a Mac App Development provisioning profile for this
  /// bundle ID, and CLI debug builds fail without that profile.
  static bool get supportsAppleSignIn =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.windows;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize();
    _initialized = true;
  }

  /// Converts `google_sign_in` failures into app-level auth errors.
  static FirebaseAuthException _googleSignInExceptionToFirebaseAuthException(
    GoogleSignInException error,
  ) {
    if (error.code == GoogleSignInExceptionCode.canceled ||
        error.code == GoogleSignInExceptionCode.interrupted) {
      return FirebaseAuthException(code: 'sign_in_canceled');
    }

    if (error.code == GoogleSignInExceptionCode.clientConfigurationError) {
      return FirebaseAuthException(
        code: 'google_sign_in_failed',
        message: error.description,
      );
    }

    if (error.code == GoogleSignInExceptionCode.uiUnavailable) {
      return FirebaseAuthException(
        code: 'google_sign_in_failed',
        message: error.description,
      );
    }

    return FirebaseAuthException(
      code: 'google_sign_in_failed',
      message: error.description,
    );
  }

  /// Completes Google auth via `google_sign_in` and maps it to Firebase.
  ///
  /// This path is required on macOS because `signInWithProvider` is not
  /// implemented by the current Firebase Auth macOS plugin.
  static Future<UserCredential> _signInWithGooglePlugin() async {
    await _ensureInitialized();

    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate(
            scopeHint: [googleSignInFieldEmail, googleSignInFieldProfile],
          );

      final String? idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseAuthException(code: 'google_sign_in_missing_id_token');
      }

      final GoogleSignInClientAuthorization? existingAuthorization =
          await googleUser.authorizationClient.authorizationForScopes([
            googleSignInFieldEmail,
            googleSignInFieldProfile,
          ]);

      final GoogleSignInClientAuthorization authz =
          existingAuthorization ??
          await googleUser.authorizationClient.authorizeScopes([
            googleSignInFieldEmail,
            googleSignInFieldProfile,
          ]);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: idToken,
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
    } on GoogleSignInException catch (error) {
      throw _googleSignInExceptionToFirebaseAuthException(error);
    } on PlatformException catch (error) {
      throw FirebaseAuthException(
        code: 'google_sign_in_failed',
        message: error.message,
      );
    }
  }

  /// Signs in with a provider, linking the current anonymous user when present.
  static Future<UserCredential> _signInWithFirebaseProvider(
    AuthProvider provider,
  ) async {
    if (kIsWeb) {
      return _auth.signInWithPopup(provider);
    }

    final User? user = _auth.currentUser;
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

  /// Throws a Firebase auth error when the current Firebase app is unavailable.
  static void _throwIfFirebaseUnavailable() {
    try {
      _auth.app;
    } on FirebaseException catch (error) {
      throw FirebaseAuthException(
        code: 'network-error',
        message:
            error.message ??
            'Unable to connect to Firebase. Please check your internet connection.',
      );
    } catch (_) {
      throw FirebaseAuthException(
        code: 'network-error',
        message:
            'Unable to connect to Firebase. Please check your internet connection.',
      );
    }
  }

  /// Signs in with Google and links anonymous users when possible.
  static Future<UserCredential> signInWithGoogle() async {
    _throwIfFirebaseUnavailable();

    final provider = GoogleAuthProvider();
    provider.addScope(googleSignInFieldEmail);
    provider.addScope(googleSignInFieldProfile);
    provider.setCustomParameters({'prompt': googleSignInPromptSelectAccount});

    if (_usesGoogleSignInPluginFlow) {
      return _signInWithGooglePlugin();
    }

    return _signInWithFirebaseProvider(provider);
  }

  /// Signs in with Apple and links anonymous users when possible.
  static Future<UserCredential> signInWithApple() async {
    _throwIfFirebaseUnavailable();

    if (!supportsAppleSignIn) {
      throw FirebaseAuthException(
        code: 'operation-not-supported',
        message: 'Apple sign-in is not available on this platform.',
      );
    }

    final provider = AppleAuthProvider();
    provider.addScope(appleSignInFieldEmail);
    provider.addScope(appleSignInFieldName);
    return _signInWithFirebaseProvider(provider);
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
