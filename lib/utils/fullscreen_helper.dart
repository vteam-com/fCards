import 'package:universal_platform/universal_platform.dart';

/// Platform-specific fullscreen helper
class FullscreenHelper {
  static Future<void> toggleFullscreen() async {
    if (UniversalPlatform.isWeb) {
      // Web implementation is handled by browser_utils.dart
      return;
    }

    if (UniversalPlatform.isMacOS) {
      // macOS fullscreen implementation
      // Note: Native macOS fullscreen requires platform channels
      // For now, we'll show a message or use a workaround
      return;
    }

    if (UniversalPlatform.isIOS) {
      // iOS fullscreen implementation
      // Note: iOS apps are typically fullscreen by default
      // Could potentially hide/show status bar with platform channels
      return;
    }

    if (UniversalPlatform.isAndroid) {
      // Android fullscreen implementation
      // Note: Would require platform channels or a plugin
      return;
    }
  }

  /// Returns whether fullscreen is supported on the current platform
  static bool get isSupported {
    return UniversalPlatform.isWeb;
  }
}
