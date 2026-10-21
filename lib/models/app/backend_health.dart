import 'package:flutter/foundation.dart';

export 'package:cards/models/app/backend_unavailable_exception.dart';

/// How long requests fail fast after the backend stopped answering, before
/// one probe request is let through again (Fibonacci seconds).
const Duration backendRetryAfter = Duration(seconds: 34);

/// What the app currently knows about the backend.
enum BackendStatus {
  /// No request has completed or timed out yet.
  unknown,

  /// The last request got an answer.
  reachable,

  /// The last request timed out; requests fail fast until a probe succeeds.
  unreachable,
}

/// Tracks whether the backend answers, so a hung server costs one timeout
/// instead of one per request (a circuit breaker).
///
/// After a timeout every request is refused immediately for
/// [backendRetryAfter]. Then a single probe request goes through: if it
/// answers the breaker closes, if it times out the wait starts over. Any
/// answer, even an error, counts as reachable. Listeners are notified when
/// [status] changes, so screens can show a banner and a retry button.
class BackendHealth extends ChangeNotifier {
  /// Creates a tracker; [now] can be replaced in tests.
  BackendHealth({DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// The tracker shared by the app.
  static final BackendHealth instance = BackendHealth();

  final DateTime Function() _now;
  DateTime? _lastFailureAt;
  bool _probeInFlight = false;
  BackendStatus _status = BackendStatus.unknown;

  /// What the app currently knows about the backend.
  BackendStatus get status => _status;

  /// Whether requests are currently refused.
  bool get isUnreachable => _status == BackendStatus.unreachable;

  /// When the backend was last found unreachable, or null.
  DateTime? get lastFailureAt => _lastFailureAt;

  /// Whether a request may be sent now.
  ///
  /// Always true while the backend is reachable or unknown. While it is
  /// unreachable, true once per [backendRetryAfter], for a single probe; the
  /// caller must then report the outcome with [recordSuccess] or
  /// [recordFailure].
  bool beginAttempt() {
    if (_status != BackendStatus.unreachable) {
      return true;
    }
    final DateTime? lastFailureAt = _lastFailureAt;
    final bool cooledDown =
        lastFailureAt == null ||
        _now().difference(lastFailureAt) >= backendRetryAfter;
    if (!cooledDown || _probeInFlight) {
      return false;
    }
    _probeInFlight = true;
    return true;
  }

  /// Records that the backend answered a request.
  void recordSuccess() {
    _probeInFlight = false;
    _setStatus(BackendStatus.reachable);
  }

  /// Records that a request timed out.
  void recordFailure() {
    _probeInFlight = false;
    _lastFailureAt = _now();
    _setStatus(BackendStatus.unreachable);
  }

  /// Forgets the last failure, so the next request is sent right away.
  void reset() {
    _probeInFlight = false;
    _lastFailureAt = null;
    _setStatus(BackendStatus.unknown);
  }

  void _setStatus(BackendStatus value) {
    if (_status == value) {
      return;
    }
    _status = value;
    notifyListeners();
  }
}
