// ignore: fcheck_magic_numbers

/// Game layout and sizing constants.
class ConstLayout {
  const ConstLayout();

  // Base Fibonacci numbers: 1, 2, 3, 5, 8, 13, 21, 34, 55, 89
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

  /// The border radius for buttons and containers
  static const double borderRadius = 8.0;

  /// The border radius multiplier for selected room container
  static const double selectedRoomBorderRadiusMultiplier = 1.5;

  /// The horizontal padding for buttons
  static const double buttonHorizontalPadding = 16.0;

  /// The vertical padding for buttons
  static const double buttonVerticalPadding = 12.0;

  /// The border width for enabled borders
  static const double enabledBorderWidth = 1.0;

  /// The border width for focused borders
  static const double focusedBorderWidth = 4.0;

  /// The width for the game over dialog
  static const double gameOverDialogWidth = 500.0;

  /// Spacing between player zones in desktop layout
  static const double playerZoneSpacing = 40.0;

  /// Height of player zone widget in desktop layout
  static const double desktopPlayerZoneHeight = 700.0;

  /// Height of player zone widget in phone layout
  static const double phonePlayerZoneHeight = 550.0;

  /// Height of CTA (call to action) section in player zone
  static const double playerZoneCTAHeight = 140.0;

  /// Height of card grid section in desktop player zone
  static const double desktopCardGridHeight = 400.0;

  /// Height of card grid section in phone player zone
  static const double phoneCardGridHeight = 300.0;

  /// Padding top for desktop layout
  static const double desktopTopPadding = 20.0;

  /// Padding around player zone in phone layout
  static const double phonePlayerZonePadding = 8.0;

  /// Scroll offset adjustment for phone layout
  static const double phoneScrollOffset = 50.0;

  /// Scroll offset adjustment for desktop/tablet layout
  static const double desktopScrollOffset = 100.0;

  /// Animation duration for scroll to active player
  static const int scrollAnimationDuration = 500;

  /// Maximum width for the start game screen content
  static const double startGameScreenMaxWidth = 400.0;

  /// Height for the game style widget
  static const double gameStyleWidgetHeight = 500.0;

  /// Main Menu Max Width (400.0)
  static const double mainMenuMaxWidth = 400.0;

  /// Main Menu Button Height (80.0)
  static const double mainMenuButtonHeight = 80.0;

  /// Main menu button width for text text (200.0).
  static const double mainMenuButtonTextWidth = 200.0;

  /// Main menu spacer height (20.0).
  static const double mainMenuSpacerHeight = 20.0;

  /// Golf column width (90.0).
  static const double golfColumnWidth = 90.0;

  /// Animation duration 300ms.
  static const int animationDuration300 = 300;

  /// Height 40.
  static const double height40 = 40.0;

  /// Loading indicator radius (40).
  static const double loadingIndicatorRadius = 40.0;

  /// Waiting widget size (400.0).
  static const double waitingWidgetSize = 400.0;

  /// Breakpoint Phone (600).
  static const double breakpointPhone = 600.0;

  /// Breakpoint Tablet (900).
  static const double breakpointTablet = 900.0;

  /// Breakpoint Desktop (1200).
  static const double breakpointDesktop = 1200.0;

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

  /// Skyjo card width (200.0).
  static const double skyjoCardWidth = 200.0;

  /// Skyjo card height (300.0).
  static const double skyjoCardHeight = 300.0;

  /// Skyjo radial radius (0.75).
  static const double skyjoRadialRadius = 0.75;

  /// Skyjo offset (10.0).
  static const double skyjoOffset = 10.0;

  /// Card center offset X (35).
  static const double cardCenterOffsetX = 35.0;

  /// Card center offset Y (70).
  static const double cardCenterOffsetY = 70.0;

  static const int searchBoxFillAlpha = 77;
  static const int dividerAlpha = 51;
  static const double roomItemLeadingWidth = 40.0;
  static const int selectedRoomBackgroundAlpha = 128;
  static const int datePaddingLength = 2;
  static const int negativeNumberMaxLength = 2;
  static const double strokeWidth6 = 3.0;

  static const int joinGameStepCount = 3;
  static const double joinGamePlayerListMaxWidth = 400.0;
  static const double joinGameNameEntryWidth = 300.0;
  static const double joinGameContainerBorderRadius = 8.0;
  static const double joinGameButtonHorizontalPadding = 24.0;
  static const double joinGameButtonVerticalPadding = 12.0;
  static const double joinGameSpacing = 20.0;
  static const double circleAvatarRadius = 12.0;
  static const int playerDisplayPaddingWidth = 3;
}
