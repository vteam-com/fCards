// ignore: fcheck_magic_numbers

/// Game layout and sizing constants.
class ConstLayout {
  const ConstLayout();

  // Base Fibonacci numbers: 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946
  // Text sizes (S/M/L approach)
  static const double textXS = 8.0; // Extra Small
  static const double textS = 13.0; // Small
  static const double textM = 21.0; // Medium
  static const double textL = 34.0; // Large
  static const double textXL = 55.0; // Extra Large

  // Size (XS/S/M/L/XL approach)
  static const double sizeXS = 2.0; // Extra Small
  static const double sizeS = 5.0; // Small
  static const double sizeM = 13.0; // Medium
  static const double sizeL = 21.0; // Large
  static const double sizeXL = 34.0; // Extra Large
  static const double sizeXXL = 55.0; // Extra Extra Large

  // Border radius (S/M/L approach)
  static const double radiusXS = 2.0; // Extra Small
  static const double radiusS = 5.0; // Small
  static const double radiusM = 13.0; // Medium
  static const double radiusL = 21.0; // Large
  static const double radiusXL = 34.0; // Extra Large

  // Icon sizes (S/M/L approach)
  static const double iconXS = 13.0; // Extra Small
  static const double iconS = 21.0; // Small
  static const double iconM = 34.0; // Medium
  static const double iconL = 55.0; // Large
  static const double iconXL = 89.0; // Extra Large

  // Stroke widths (S/M/L approach)
  static const double strokeXS = 1.0; // Extra Small
  static const double strokeS = 2.0; // Small
  static const double strokeM = 3.0; // Medium
  static const double strokeL = 5.0; // Large
  static const double strokeXL = 8.0; // Extra Large

  // Elevation (S/M/L approach)
  static const double elevationXS = 1.0; // Extra Small
  static const double elevationS = 2.0; // Small
  static const double elevationM = 5.0; // Medium
  static const double elevationL = 8.0; // Large
  static const double elevationXL = 13.0; // Extra Large

  // Padding (XS/S/M/L/XL approach)
  static const double paddingXS = 3.0; // Extra Small
  static const double paddingS = 5.0; // Small
  static const double paddingM = 8.0; // Medium
  static const double paddingL = 13.0; // Large
  static const double paddingXL = 21.0; // Extra Large
  static const double paddingXXL = 34.0; // Extra Extra Large

  /// The width for the game over dialog (610.0)
  static const double gameOverDialogWidth = 610.0;

  /// Height of player zone widget in desktop layout (610.0)
  static const double desktopPlayerZoneHeight = 610.0;

  /// Height of player zone widget in phone layout (610.0)
  static const double phonePlayerZoneHeight = 610.0;

  /// Height of CTA (call to action) section in player zone (144.0)
  static const double playerZoneCTAHeight = 144.0;

  /// Height of card grid section in desktop player zone (377.0)
  static const double desktopCardGridHeight = 377.0;

  /// Height of card grid section in phone player zone (377.0)
  static const double phoneCardGridHeight = 377.0;

  /// Scroll offset adjustment for phone layout (55.0)
  static const double phoneScrollOffset = 55.0;

  /// Scroll offset adjustment for desktop/tablet layout (89.0)
  static const double desktopScrollOffset = 89.0;

  /// Animation duration for scroll to active player
  static const int scrollAnimationDuration = 500;

  /// Maximum width for the start game screen content (377.0)
  static const double startGameScreenMaxWidth = 377.0;

  /// Height for the game style widget (610.0)
  static const double gameStyleWidgetHeight = 610.0;

  /// Main Menu Max Width (377.0)
  static const double mainMenuMaxWidth = 377.0;

  /// Main Menu Button Height (89.0)
  static const double mainMenuButtonHeight = 89.0;

  /// Main menu button width for text text (233.0).
  static const double mainMenuButtonTextWidth = 233.0;

  /// Main menu spacer height (21.0).
  static const double mainMenuSpacerHeight = 21.0;

  /// Golf column width (89.0).
  static const double golfColumnWidth = 89.0;

  /// Animation duration 300ms.
  static const int animationDuration300 = 300;

  /// Height 40 (Snap to 34 or 55? 34 is sizeXL. Let's use 34 or 55. 40 is close to 34).
  static const double height40 = 34.0;

  /// Dialog button width (89)
  static const double dialogButtonWidth = 89.0;

  /// Dialog button height (55)
  static const double dialogButtonHeight = 55.0;

  /// Waiting widget size (377.0).
  static const double waitingWidgetSize = 377.0;

  /// Breakpoint Phone (610).
  static const double breakpointPhone = 610.0;

  /// Breakpoint Tablet (987).
  static const double breakpointTablet = 987.0;

  /// Breakpoint Desktop (1597).
  static const double breakpointDesktop = 1597.0;

  /// Scroll alignment center (0.5).
  static const double scrollAlignmentCenter = 0.5;

  /// Card stack offset large (0.5).
  static const double cardStackOffsetLarge = 0.5;

  /// Card stack threshold (50).
  static const int cardStackThreshold = 50;

  /// Card stack offset small (0.2).
  static const double cardStackOffsetSmall = 0.2;

  /// Card height scale (1.50).
  static const double cardHeightScale = 1.50;

  /// Card width scale (1.30).
  static const double cardWidthScale = 1.30;

  /// Skyjo card width (233.0).
  static const double skyjoCardWidth = 233.0;

  /// Skyjo card height (377.0).
  static const double skyjoCardHeight = 377.0;

  /// Skyjo radial radius (0.75).
  static const double skyjoRadialRadius = 0.75;

  /// Skyjo offset (13.0).
  static const double skyjoOffset = 13.0;

  /// Card center offset X (34).
  static const double cardCenterOffsetX = 34.0;

  /// Card center offset Y (55).
  static const double cardCenterOffsetY = 55.0;

  static const int selectedRoomBackgroundAlpha = 128;
  static const int dateCharacterLeftSpacePadding = 2;
  static const int negativeNumberMaxLength = 2;

  static const int joinGameStepCount = 3;
  static const double joinGamePlayerListMaxWidth = 377.0;
}
