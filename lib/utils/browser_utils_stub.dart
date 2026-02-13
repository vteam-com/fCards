/// Returns the current browser origin for non-web builds.
String getWindowOrigin() => '';

/// No-op history push used when browser APIs are unavailable.
void pushHistoryState(String _, String _) {
  // Stub implementation
}
