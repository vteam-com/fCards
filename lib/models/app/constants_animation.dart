/// Animation and visual effect constants.
///
/// This class defines the standardized values for shadows, blurs, and opacities
/// used to achieve the glassmorphic "Casino Table Top" aesthetic.
class ConstAnimation {
  const ConstAnimation();

  // Glassmorphism effects
  /// Standard blur sigma for backdrop filters.
  static const double blurSigma = 14.0;

  /// Opacity for the white border around glass elements.
  static const double borderOpacity = 0.5;

  /// Opacity for the dark overlay layer.
  static const double blackOverlayOpacity = 0.28;

  /// Opacity for the semi-transparent black background.
  static const double blackBackgroundOpacity = 0.12;

  /// Opacity for light overlay effects.
  static const double whiteOverlayOpacity = 0.25;

  /// Opacity for white highlight gradients.
  static const double whiteHighlightOpacity = 0.1;

  // Shadow effects
  /// Standard blur radius for drop shadows.
  static const double shadowBlurRadius = 10.0;

  /// Standard Y-offset for drop shadows.
  static const double shadowOffset = 4.0;

  /// Standard spread radius for drop shadows.
  static const double shadowSpreadRadius = 0.0;

  /// Blur radius for highlight shadows.
  static const double highlightShadowBlurRadius = 6.0;

  /// Y-offset for highlight shadows.
  static const double highlightShadowOffset = 2.0;

  /// Spread radius for highlight shadows.
  static const double highlightShadowSpreadRadius = 0.0;

  // Interaction animations
  /// Duration in milliseconds for the wiggle animation.
  static const int wiggleAnimationDuration = 750;

  /// Minimum rotation angle for wiggle effect.
  static const double wiggleAngleMin = -0.05;

  /// Maximum rotation angle for wiggle effect.
  static const double wiggleAngleMax = 0.05;
}
