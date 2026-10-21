/// Thrown instead of sending a request while the backend is unreachable.
class BackendUnavailableException implements Exception {
  /// Creates the exception.
  const BackendUnavailableException();

  @override
  String toString() => 'BackendUnavailableException: backend is unreachable';
}
