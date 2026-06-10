import 'package:cards/models/app/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

const String reviewersDbPath = 'reviewers';

/// Parses reviewer flags stored as booleans, numbers, strings, or maps.
bool parseReviewerAccess(Object? rawValue) {
  if (rawValue == null) {
    return false;
  }

  if (rawValue is bool) {
    return rawValue;
  }

  if (rawValue is num) {
    return rawValue != 0;
  }

  if (rawValue is String) {
    final normalized = rawValue.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  if (rawValue is Map<Object?, Object?>) {
    final dynamic enabledField =
        rawValue['enabled'] ?? rawValue['active'] ?? rawValue['isReviewer'];
    return parseReviewerAccess(enabledField);
  }

  if (rawValue is Map<dynamic, dynamic>) {
    final dynamic enabledField =
        rawValue['enabled'] ?? rawValue['active'] ?? rawValue['isReviewer'];
    return parseReviewerAccess(enabledField);
  }

  return false;
}

/// Streams reviewer access for the current authenticated user.
Stream<bool> reviewerAccessStream() {
  return AuthService.authStateChanges().asyncExpand((User? user) {
    if (user == null || user.isAnonymous) {
      return Stream<bool>.value(false);
    }

    return FirebaseDatabase.instance
        .ref('$reviewersDbPath/${user.uid}')
        .onValue
        .map((DatabaseEvent event) {
          return parseReviewerAccess(event.snapshot.value);
        })
        .handleError((_) => false);
  });
}

/// Returns whether the current user has reviewer access.
Future<bool> isCurrentUserReviewer() async {
  final User? user = AuthService.currentUser;
  if (user == null || user.isAnonymous) {
    return false;
  }

  final DataSnapshot snapshot = await FirebaseDatabase.instance
      .ref('$reviewersDbPath/${user.uid}')
      .get();
  return parseReviewerAccess(snapshot.value);
}
