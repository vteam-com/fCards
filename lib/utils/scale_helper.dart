import 'package:flutter/material.dart';
import 'font_scale_notifier.dart';

/// A helper class that provides scaling functionality for all UI elements
class ScaleHelper {
  static final FontScaleNotifier _fontScaleNotifier = FontScaleNotifier();

  /// Get the current scale multiplier
  static double get scaleMultiplier => _fontScaleNotifier.fontSizeMultiplier;

  /// Scale a dimension (width, height, size, etc.)
  static double scaleDimension(double baseDimension) {
    return baseDimension * scaleMultiplier;
  }

  /// Scale an EdgeInsets
  static EdgeInsets scaleEdgeInsets(EdgeInsets basePadding) {
    return EdgeInsets.all(basePadding.top * scaleMultiplier);
  }

  /// Scale a BorderRadius
  static BorderRadius scaleBorderRadius(BorderRadius baseRadius) {
    return BorderRadius.all(
      Radius.circular(baseRadius.topLeft.x * scaleMultiplier),
    );
  }

  /// Scale a font size
  static double scaleFontSize(double baseFontSize) {
    return _fontScaleNotifier.getScaledFontSize(baseFontSize);
  }

  /// Scale an icon size
  static double scaleIconSize(double baseIconSize) {
    return baseIconSize * scaleMultiplier;
  }

  /// Scale a stroke width
  static double scaleStrokeWidth(double baseStrokeWidth) {
    return baseStrokeWidth * scaleMultiplier;
  }

  /// Scale a Size object
  static Size scaleSize(Size baseSize) {
    return Size(
      baseSize.width * scaleMultiplier,
      baseSize.height * scaleMultiplier,
    );
  }

  /// Scale an Offset
  static Offset scaleOffset(Offset baseOffset) {
    return Offset(
      baseOffset.dx * scaleMultiplier,
      baseOffset.dy * scaleMultiplier,
    );
  }

  /// Get a scaled TextStyle
  static TextStyle getScaledTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextDecoration? decoration,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize != null ? scaleFontSize(fontSize) : null,
      fontWeight: fontWeight,
      color: color,
      decoration: decoration,
      fontFamily: fontFamily,
    );
  }

  /// Listen to scale changes
  static void addListener(VoidCallback listener) {
    _fontScaleNotifier.addListener(listener);
  }

  /// Remove a scale change listener
  static void removeListener(VoidCallback listener) {
    _fontScaleNotifier.removeListener(listener);
  }
}
