import 'dart:async';

import 'package:cards/models/app/backend_health.dart';

export 'package:cards/models/app/backend_health.dart';

const String _noEventMessage = 'No Firebase event received';

/// Maximum time to wait for a Firebase Realtime Database request.
const Duration firebaseRequestTimeout = Duration(seconds: 13);

/// Sends the Firebase request made by [request] with a bounded wait.
///
/// Throws [BackendUnavailableException] without sending anything while
/// [BackendHealth] says the backend is unreachable, and a [TimeoutException]
/// when the request does not answer within [timeout]. Either way the backend
/// state is updated, so a hung server costs the app one timeout, not one per
/// request.
Future<T> withFirebaseRequestTimeout<T>(
  Future<T> Function() request, {
  Duration timeout = firebaseRequestTimeout,
  BackendHealth? health,
}) async {
  final BackendHealth tracker = health ?? BackendHealth.instance;
  if (!tracker.beginAttempt()) {
    throw const BackendUnavailableException();
  }
  try {
    final T result = await request().timeout(timeout);
    tracker.recordSuccess();
    return result;
  } on TimeoutException {
    tracker.recordFailure();
    rethrow;
  } catch (_) {
    // An error is still an answer: the backend is reachable.
    tracker.recordSuccess();
    rethrow;
  }
}

/// Listens to the Firebase stream made by [source], failing when its first
/// event does not arrive within [timeout].
///
/// Later events are not timed, since a value stream is silent until the data
/// changes. While [BackendHealth] says the backend is unreachable the stream
/// fails right away with [BackendUnavailableException], without subscribing.
Stream<T> withFirebaseStreamTimeout<T>(
  Stream<T> Function() source, {
  Duration timeout = firebaseRequestTimeout,
  BackendHealth? health,
}) {
  final BackendHealth tracker = health ?? BackendHealth.instance;
  late final StreamController<T> controller;
  StreamSubscription<T>? subscription;
  Timer? firstEventTimer;

  void stop() {
    firstEventTimer?.cancel();
    firstEventTimer = null;
    subscription?.cancel();
    subscription = null;
  }

  controller = StreamController<T>(
    onListen: () {
      if (!tracker.beginAttempt()) {
        controller.addError(const BackendUnavailableException());
        controller.close();
        return;
      }
      firstEventTimer = Timer(timeout, () {
        tracker.recordFailure();
        stop();
        controller.addError(TimeoutException(_noEventMessage, timeout));
        controller.close();
      });
      subscription = source().listen(
        (T event) {
          if (firstEventTimer != null) {
            firstEventTimer?.cancel();
            firstEventTimer = null;
            tracker.recordSuccess();
          }
          controller.add(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (firstEventTimer != null) {
            firstEventTimer?.cancel();
            firstEventTimer = null;
            tracker.recordSuccess();
          }
          controller.addError(error, stackTrace);
        },
        onDone: () {
          stop();
          controller.close();
        },
      );
    },
    onCancel: stop,
  );
  return controller.stream;
}
