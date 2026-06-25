import 'package:cards/models/app/auth_service.dart';
import 'package:cards/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _initialsKey = 'guest_initials';
const String _firebaseUsersNode = 'users';
const String _firebaseInitialsNode = 'initials';
const int _maxInitialsLength = 2;

/// Persists and retrieves the player's chosen identity.
///
/// Identity is either a Google-authenticated display name or locally-stored
/// two-character guest initials.
class IdentityService {
  /// Normalizes user-entered initials to an uppercase, max-two-character token.
  static String _normalizeInitials(String initials) {
    final normalized = initials.trim().toUpperCase();
    if (normalized.isEmpty) {
      return '';
    }
    if (normalized.length <= _maxInitialsLength) {
      return normalized;
    }
    return normalized.substring(0, _maxInitialsLength);
  }

  /// Returns true when [error] represents a Firebase permission denial.
  static bool _isPermissionDeniedError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('permission-denied') ||
        text.contains('permission_denied');
  }

  /// Returns the stored guest initials, or null if none have been saved.
  static Future<String?> getStoredInitials() async {
    final prefs = await SharedPreferences.getInstance();
    final String? localInitials = prefs.getString(_initialsKey);
    final String? normalizedLocal = localInitials == null
        ? null
        : _normalizeInitials(localInitials);

    final String? uid = AuthService.isSignedInWithAccount
        ? AuthService.currentUser?.uid
        : null;
    if (uid != null) {
      try {
        final DataSnapshot snapshot = await FirebaseDatabase.instance
            .ref('$_firebaseUsersNode/$uid/$_firebaseInitialsNode')
            .get();
        final Object? backendInitials = snapshot.value;
        if (backendInitials is String) {
          final String normalizedBackend = _normalizeInitials(backendInitials);
          if (normalizedBackend.isNotEmpty) {
            if (normalizedLocal != normalizedBackend) {
              await prefs.setString(_initialsKey, normalizedBackend);
            }
            return normalizedBackend;
          }
        }
      } on FirebaseException catch (error) {
        if (!_isPermissionDeniedError(error)) {
          logger.w('getStoredInitials backend lookup failed: $error');
        }
      } catch (error) {
        if (!_isPermissionDeniedError(error)) {
          logger.w('getStoredInitials backend lookup failed: $error');
        }
      }
    }

    return normalizedLocal;
  }

  /// Persists guest initials locally. Normalises to uppercase.
  static Future<void> saveInitials(String initials) async {
    final String normalized = _normalizeInitials(initials);
    if (normalized.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_initialsKey, normalized);

    final String? uid = AuthService.isSignedInWithAccount
        ? AuthService.currentUser?.uid
        : null;
    if (uid == null) {
      return;
    }

    try {
      await FirebaseDatabase.instance
          .ref('$_firebaseUsersNode/$uid/$_firebaseInitialsNode')
          .set(normalized);
    } on FirebaseException catch (error) {
      if (!_isPermissionDeniedError(error)) {
        logger.w('saveInitials backend save failed: $error');
      }
    } catch (error) {
      if (!_isPermissionDeniedError(error)) {
        logger.w('saveInitials backend save failed: $error');
      }
    }
  }

  /// Returns the Google sign-in display name, or null if not signed in.
  static String? get googleDisplayName {
    if (!AuthService.isSignedInWithAccount) {
      return null;
    }
    return AuthService.currentUser?.displayName;
  }

  /// Resolves the active identity display name.
  ///
  /// Returns the Google display name when signed in, or the stored guest
  /// initials, or null when no identity has been set.
  static Future<String?> resolveIdentityName() async {
    final googleName = googleDisplayName;
    if (googleName != null && googleName.isNotEmpty) {
      return googleName;
    }
    return getStoredInitials();
  }
}
