import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontScaleHelper {
  static const String _fontScaleKey = 'font_scale';
  static const List<double> _fontScales = [-2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0];

  static double _currentScale = 0.0;
  static final List<VoidCallback> _listeners = [];

  /// Add a listener to be called when font scale changes
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners that font scale has changed
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Initialize the font scale from shared preferences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentScale = prefs.getDouble(_fontScaleKey) ?? 0.0;
    _notifyListeners();
  }

  /// Get the current font scale
  static double get currentScale => _currentScale;

  /// Get the current font size multiplier
  static double get fontSizeMultiplier {
    return 1.0 + (_currentScale / 10.0); // Convert scale to multiplier
  }

  /// Get the scaled font size
  static double getScaledFontSize(double baseFontSize) {
    return baseFontSize * fontSizeMultiplier;
  }

  /// Get the current font scale index
  static int get currentIndex {
    return _fontScales.indexOf(_currentScale);
  }

  /// Toggle to the next font scale
  static Future<double> toggleFontScale() async {
    final currentIndex = _fontScales.indexOf(_currentScale);
    final nextIndex = (currentIndex + 1) % _fontScales.length;
    _currentScale = _fontScales[nextIndex];

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, _currentScale);

    // Notify listeners
    _notifyListeners();

    return _currentScale;
  }

  /// Get the icon for the current font scale
  static IconData get currentIcon {
    switch (_currentScale.toInt()) {
      case -2:
        return Icons.text_decrease;
      case -1:
        return Icons.text_decrease;
      case 0:
        return Icons.text_fields;
      case 1:
        return Icons.text_increase;
      case 2:
        return Icons.text_increase;
      default:
        return Icons.text_fields;
    }
  }

  /// Get the label for the current font scale
  static String get currentLabel {
    if (_currentScale == 0.0) return 'Normal';
    return _currentScale > 0
        ? '+${_currentScale.toInt()}'
        : '${_currentScale.toInt()}';
  }
}
