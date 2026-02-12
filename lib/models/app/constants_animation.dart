/// Animation and visual effect constants.
///
/// This class defines the standardized values for shadows, blurs, and opacities
/// used to achieve the glassmorphic "Casino Table Top" aesthetic.
class ConstAnimation {
  const ConstAnimation();

  /// Standard blur sigma for backdrop filters.
  static const double blurSigma = 1.0;

  /// Opacity for the white border around glass elements.
  static const double borderOpacity = 0.5;

  /// Opacity for the semi-transparent black background.
  static const double blackBackgroundOpacity = 0.12;

  /// Opacity for light overlay effects.
  static const double whiteOverlayOpacity = 0.5;

  /// Opacity for white highlight gradients.
  static const double whiteHighlightOpacity = 0.99;

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

  // Table top ambient background animation
  /// Duration in milliseconds for the ambient felt movement.
  static const int tableTopAmbientDuration = 10946;

  /// Opacity for the moving highlight layer.
  static const double tableTopHighlightOpacity = 0.5;

  /// Opacity for the moving shadow layer.
  static const double tableTopShadowOpacity = 0.20;

  /// Radius for the radial highlight layer.
  static const double tableTopHighlightRadius = 1.2;

  /// Alpha channel for ambient halo circles in the table top overlay.
  static const int tableTopAmbientCircleAlpha = 34;

  /// Radius for ambient halo circles in the table top overlay.
  static const double tableTopAmbientCircleRadius = 0.8;

  /// Size divisor for the primary ambient halo circle.
  static const double tableTopPrimaryCircleDivisor = 2.0;

  /// Size and phase divisor for the secondary ambient halo circle.
  static const double tableTopSecondaryCircleDivisor = 4.0;
}
