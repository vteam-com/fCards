import 'dart:ui';

/// A helper class for font scaling functionality
class FontScaleHelper {
  /// Current font scale multiplier
  static double currentScale = 1.0;

  /// Get a scaled font size
  static double getScaledFontSize(double baseFontSize) {
    return baseFontSize * currentScale;
  }

  /// Add a listener for font scale changes
  static void addListener(VoidCallback listener) {
    // Simple implementation - in a real app this would listen to system font scale changes
  }

  /// Remove a listener for font scale changes
  static void removeListener(VoidCallback listener) {
    // Simple implementation
  }
}

/// A notifier for font scale changes
class FontScaleNotifier {
  /// Initialize the notifier
  void initialize() {
    // Simple implementation
  }
}
