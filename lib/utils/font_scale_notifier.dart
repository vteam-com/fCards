import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontScaleNotifier extends ChangeNotifier {
  static const String _fontScaleKey = 'font_scale';
  static const List<double> _fontScales = [-2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0];

  double _currentScale = 0.0;

  static final FontScaleNotifier _instance = FontScaleNotifier._internal();
  factory FontScaleNotifier() => _instance;
  FontScaleNotifier._internal();

  /// Initialize the font scale from shared preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentScale = prefs.getDouble(_fontScaleKey) ?? 0.0;
    notifyListeners();
  }

  /// Get the current font scale
  double get currentScale => _currentScale;

  /// Get the current font size multiplier
  double get fontSizeMultiplier {
    return 1.0 + (_currentScale / 10.0); // Convert scale to multiplier
  }

  /// Get the scaled font size
  double getScaledFontSize(double baseFontSize) {
    return baseFontSize * fontSizeMultiplier;
  }

  /// Get the current font scale index
  int get currentIndex {
    return _fontScales.indexOf(_currentScale);
  }

  /// Toggle to the next font scale
  Future<double> toggleFontScale() async {
    final currentIndex = _fontScales.indexOf(_currentScale);
    final nextIndex = (currentIndex + 1) % _fontScales.length;
    _currentScale = _fontScales[nextIndex];

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, _currentScale);

    // Notify listeners
    notifyListeners();

    return _currentScale;
  }

  /// Get the icon for the current font scale
  IconData get currentIcon {
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
  String get currentLabel {
    if (_currentScale == 0.0) return 'Normal';
    return _currentScale > 0
        ? '+${_currentScale.toInt()}'
        : '${_currentScale.toInt()}';
  }
}
