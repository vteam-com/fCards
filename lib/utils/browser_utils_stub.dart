String getWindowOrigin() => '';

void pushHistoryState(String title, String url) {}

Future<void> toggleFullscreen() async {
  // No fullscreen implementation for non-web platforms
  // Could be extended with platform-specific implementations
}
