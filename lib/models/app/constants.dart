// ignore: fcheck_magic_numbers

import 'package:flutter/material.dart';

/// Game constants for the SkyJo card game.
class Constants {
  /// Number of columns in a SkyJo player's hand.
  static const int skyjoColumns = 4;

  /// Number of rows in a SkyJo player's hand.
  static const int skyjoRows = 3;

  /// Number of columns in a standard player's hand.
  static const int standardColumns = 3;

  /// Number of rows in a standard player's hand.
  static const int standardRows = 3;

  /// Number of cards to reveal at startup for French Cards game style.
  static const int frenchCardsRevealCount = 2;

  /// Number of cards to reveal at startup for SkyJo game style.
  static const int skyjoRevealCount = 2;

  /// Number of cards to reveal at startup for Mini Put game style.
  static const int miniPutRevealCount = 1;

  /// Number of cards to reveal at startup for Custom game style.
  static const int customRevealCount = 0;

  /// The number of cards to remove when evaluating a SkyJo hand (3 cards in a set).
  static const int skyjoSetSize = 3;

  /// The number of players to reveal cards for in the final turn.
  static const int finalTurnRevealCount = 1;

  /// The increment value when moving to the next player.
  static const int nextPlayerIncrement = 1;

  /// The number of cards to deal to each player in a SkyJo game.
  static const int skyjoCardsToDeal = 12;

  /// The number of cards to deal to each player in a French Cards game.
  static const int frenchCardsToDeal = 9;

  /// The number of cards to deal to each player in a Mini Put game.
  static const int miniPutCardsToDeal = 4;

  /// Number of columns in a Mini Put player's hand.
  static const int miniPutColumns = 2;

  /// Number of rows in a Mini Put player's hand.
  static const int miniPutRows = 2;

  /// The size of a 2x2 grid for Golf scoring (4 cards).
  static const double golfGrid2x2Size = 4.0;

  /// The size of a 3x3 grid for Golf scoring (9 cards).
  static const double golfGrid3x3Size = 9.0;

  /// Number of cards in a 2-card matching set.
  static const int twoCardMatchSize = 2;

  /// Number of cards in a 3-card matching set.
  static const int threeCardMatchSize = 3;

  /// Duration for snackbars in seconds.
  static const int snackbarDurationSeconds = 2;

  /// Width for string padding in player display (3 characters).
  static const int playerDisplayPaddingWidth = 3;

  /// Width for player name padding in display (10 characters).
  static const int playerNamePaddingWidth = 10;

  /// Width for string padding in card display (2 characters).
  static const int cardDisplayPaddingWidth = 2;

  /// The number of indices to check for a set (3 for 3-card sets).
  static const int indicesInSet = 3;

  /// The offset for calculating set start position (1 for 3-card sets).
  static const int setStartOffset = 1;

  /// The index offset for the first card in a set.
  static const int firstCardIndexOffset = 0;

  /// The index offset for the second card in a set.
  static const int secondCardIndexOffset = 1;

  /// The index offset for the third card in a set.
  static const int thirdCardIndexOffset = 2;

  /// The minimum value for cards in a SkyJo deck (-2).
  static const int skyjoMinValue = -2;

  /// The maximum value for cards in a SkyJo deck (12).
  static const int skyjoMaxValue = 12;

  /// The count of cards with value 0 in a SkyJo deck (15).
  static const int skyjoZeroCardCount = 15;

  /// The count of cards with value -2 in a SkyJo deck (5).
  static const int skyjoNegativeTwoCardCount = 5;

  /// The count of cards with values other than 0 and -2 in a SkyJo deck (10).
  static const int skyjoOtherCardCount = 10;

  /// The number of Jokers to add to each deck in Golf style (2).
  static const int golfJokerCount = 2;

  /// The value of a joker is a deduction of -2
  static const int golfJokerValue = -2;

  /// The minimum number of players required to start a game.
  static const int minPlayersToStartGame = 2;

  /// The number of steps in the join game process.
  static const int joinGameStepCount = 3;

  /// The maximum width for the player list widget in the join game screen.
  static const double joinGamePlayerListMaxWidth = 400.0;

  /// The width for the name entry field in join game screen.
  static const double joinGameNameEntryWidth = 300.0;

  /// The border radius for container in join game screen.
  static const double joinGameContainerBorderRadius = 8.0;

  // Fibonacci-based sizing system

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

  /// The horizontal padding for the start game button.
  static const double joinGameButtonHorizontalPadding = 24.0;

  /// The vertical padding for the start game button.
  static const double joinGameButtonVerticalPadding = 12.0;

  /// The spacing between widgets in join game screen.
  static const double joinGameSpacing = 20.0;

  /// The radius for circle avatar in join game screen.
  static const double circleAvatarRadius = 12.0;

  // Normalized color system

  // Primary colors (green theme)
  static final Color primaryGreen = Colors.green.shade900;
  static final Color primaryGreenLight = Colors.green[600]!;
  static final Color primaryGreenDark = Color.fromARGB(255, 19, 67, 22);

  // Text colors
  static final Color textPrimary = Colors.white;
  static final Color textHint = Colors.white70;
  static final Color textSuccess = Colors.green[400]!;

  // Background colors
  static final Color backgroundContainer = primaryGreen;

  // Accent colors
  static const Color accentYellow = Colors.yellow;
  static final Color accentGreenAlpha = Colors.green.withAlpha(100);

  /// The border width for enabled borders
  static const double enabledBorderWidth = 1.0;

  /// The border width for focused borders
  static const double focusedBorderWidth = 4.0;

  /// The horizontal padding for buttons
  static const double buttonHorizontalPadding = 16.0;

  /// The vertical padding for buttons
  static const double buttonVerticalPadding = 12.0;

  /// The border radius for buttons and containers
  static const double borderRadius = 8.0;

  /// The border radius multiplier for selected room container
  static const double selectedRoomBorderRadiusMultiplier = 1.5;

  /// Alpha value for search box fill color (77/255 ≈ 0.3)
  static const int searchBoxFillAlpha = 77;

  /// Alpha value for divider color (51/255 ≈ 0.2)
  static const int dividerAlpha = 51;

  /// Width for room item leading icon container
  static const double roomItemLeadingWidth = 40.0;

  /// Alpha value for selected room background (128/255 ≈ 0.5)
  static const int selectedRoomBackgroundAlpha = 128;

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

  /// Alpha value 100.
  static const int alpha100 = 100;

  /// Alpha value 200.
  static const int alpha200 = 200;

  /// Opacity 0.8.
  static const double opacity80 = 0.8;

  /// Scale 1.5.
  static const double scale15 = 1.5;

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

  /// Date padding length (2).
  static const int datePaddingLength = 2;

  /// Scroll alignment center (0.5).
  static const double scrollAlignmentCenter = 0.5;

  /// Negative number max length (2).
  static const int negativeNumberMaxLength = 2;

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

  /// Stroke width 6.
  static const double strokeWidth6 = strokeM; // 6.0 -> 3.0 (closest Fibonacci)

  /// Skyjo value threshold 5.
  static const int skyjoValueThreshold5 = 5;

  /// Skyjo value threshold 9.
  static const int skyjoValueThreshold9 = 9;

  /// Card value joker (-2).
  static const int cardValueJoker = -2;

  /// Card value king (0).
  static const int cardValueKing = 0;

  /// Card value queen (12).
  static const int cardValueQueen = 12;

  /// Card value jack (11).
  static const int cardValueJack = 11;

  /// Card value Ace.
  static const int cardValueAce = 1;

  /// Card value 2.
  static const int cardValue2 = 2;

  /// Card value 3.
  static const int cardValue3 = 3;

  /// Card value 4.
  static const int cardValue4 = 4;

  /// Card offset 30.
  static const double cardOffset30 = 30.0;

  /// Card offset 20.
  static const double cardOffset20 = 20.0;

  /// Card value 5.
  static const int cardValue5 = 5;

  /// Card value 6.
  static const int cardValue6 = 6;

  /// Card offset 15.
  static const double cardOffset15 = 15.0;

  /// Card value 7.
  static const int cardValue7 = 7;

  /// Card value 8.
  static const int cardValue8 = 8;

  /// Card value 9.
  static const int cardValue9 = 9;

  /// Card value 10.
  static const int cardValue10 = 10;

  /// Card offset 10.
  static const double cardOffset10 = 10.0;

  /// Card offset 50.
  static const double cardOffset50 = 50.0;

  /// Card center offset X (35).
  static const double cardCenterOffsetX = 35.0;

  /// Card center offset Y (70).
  static const double cardCenterOffsetY = 70.0;

  // Blur and shadow constants for my_button.dart
  static const double blurSigma = 14.0;
  static const double shadowBlurRadius = 10.0;
  static const double shadowOffset = 4.0;
  static const double shadowSpreadRadius = 0.0;
  static const double highlightShadowBlurRadius = 6.0;
  static const double highlightShadowOffset = 2.0;
  static const double highlightShadowSpreadRadius = 0.0;
  static const double borderOpacity = 0.5;
  static const double blackOverlayOpacity = 0.28;
  static const double blackBackgroundOpacity = 0.12;
  static const double whiteOverlayOpacity = 0.25;
  static const double whiteHighlightOpacity = 0.1;

  // Animation constants for wiggle_widget.dart
  static const int wiggleAnimationDuration = 750;
  static const double wiggleAngleMin = -0.05;
  static const double wiggleAngleMax = 0.05;
}
