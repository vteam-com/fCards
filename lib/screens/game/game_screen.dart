import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/card/card_dimensions.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/screens/game/game_over_dialog.dart';
import 'package:cards/widgets/cards/card_widget.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/player/player_zone_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

/// Widget for the main game screen.
///
/// Displays the game board and player information based on the [GameModel]
/// provided.  Adapts the layout dynamically to accommodate different screen
/// sizes, using a wrapping layout for larger screens and a vertical column for
/// smaller screens.  Manages scrolling to keep the active player visible.
///
/// Requires a [GameModel] to be passed in during construction.
class GameScreen extends StatefulWidget {
  /// Creates a new GameScreen widget.
  ///
  /// [gameModel]: The game model providing the game state and player data.
  const GameScreen({super.key, required this.gameModel});

  /// The game model containing the game state and player data.
  final GameModel gameModel;

  @override
  GameScreenState createState() => GameScreenState();
}

/// Widget for the main game screen.
///
/// Displays the game board and player information based on the [GameModel]
/// provided. Adapts the layout dynamically to accommodate different screen
/// sizes, using a wrapping layout for larger screens and a vertical column for
/// smaller screens. Manages scrolling to keep the active player visible.
///
/// Key features:
/// - Responsive layout that adapts between desktop/tablet and phone views
/// - Real-time synchronization with Firebase database
/// - Automatic scrolling to keep active player in view
/// - Game state management and updates
/// - Game over dialog display
///
/// The widget maintains several important state variables:
/// - [_streamSubscription]: Subscription for Firebase database updates
/// - [_scrollController]: Controls scrolling behavior of player list
/// - [_playerKeys]: Global keys for each player widget used in scrolling
/// - [phoneLayout]: Flag indicating if using phone-sized screen layout
/// - [isReady]: Flag indicating if initial data is loaded
///
/// The layout adapts based on screen width:
/// - Desktop/tablet: Horizontal wrapping layout
/// - Phone: Vertical scrolling column
///
/// Firebase integration:
/// - Listens for real-time updates to game state
/// - Handles data synchronization and model updates
/// - Supports offline mode for testing
///
/// Required parameters:
/// - [gameModel]: The [GameModel] containing game state and player data
///
/// Usage:
/// ```dart
/// GameScreen(
///   gameModel: myGameModel,
/// )
/// ```  /// Stream subscription for listening to changes in the Firebase database.
class GameScreenState extends State<GameScreen> {
  ({CardModel discardedCard, Offset? origin, bool wasHidden})?
  _activeSwapAnimationEvent;
  int _lastHandledSwapAnimationEventId = 0;

  /// List of GlobalKeys for each player widget, used for scrolling.
  List<GlobalKey> _playerKeys = [];

  /// Scroll controller for managing the scrolling behavior of the player list.
  late ScrollController _scrollController;
  late StreamSubscription _streamSubscription;
  Timer? _swapAnimationCleanupTimer;
  int _swapAnimationRunId = 0;

  /// Flag indicating whether the initial game data has been loaded and processed.
  /// Set to [isRunningOffLine] initially since offline mode doesn't need to wait for data loading.
  /// Used to control display of loading indicator and enable/disable game interactions.
  bool isReady = isRunningOffLine;

  /// Flag indicating whether the layout is for a phone-sized screen.
  bool phoneLayout = false;
  @override
  void initState() {
    super.initState();
    _createGlobalKeyForPlayers();
    widget.gameModel.addListener(_onGameModelUpdated);
    if (isRunningOffLine) {
      _getFirebaseData();
    } else {
      _initializeFirebaseListener();
    }

    /// Scroll to the active player after the layout is built.
    _scrollController = ScrollController();
    _setupScrollToActivePlayer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _swapAnimationCleanupTimer?.cancel();
    widget.gameModel.removeListener(_onGameModelUpdated);
    if (!isRunningOffLine) {
      _streamSubscription.cancel();
    }
    super.dispose();
  }

  /// Builds the widget for the game screen.
  ///
  /// Determines the screen width using [MediaQuery] and selects an appropriate
  /// layout based on the width.  Wraps the layout in a [Screen] widget
  /// which provides a title, active player display, and refresh functionality.  The
  /// displayed title reflects the current game state. A loading indicator is shown
  /// while the game data is being fetched.
  ///
  /// Returns:
  ///   The widget tree for the game screen.
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Screen(
      isWaiting: !isReady,
      title: widget.gameModel.getGameStateAsString(),
      rightText:
          '${widget.gameModel.roomName} [ ${widget.gameModel.loginUserName} ]',
      onRefresh: _onRefresh,
      getLinkToShare: () {
        return widget.gameModel.getLinkToGame();
      },
      child: _buildLayoutWithSwapAnimation(_adaptiveLayout(width)),
    );
  }

  /// Returns a simulated data snapshot for offline testing mode.
  ///
  /// This method creates a JSON representation of the current game model state
  /// that mimics what would normally be received from Firebase. Used only when
  /// [isRunningOffLine] is true to enable testing without a database connection.
  ///
  /// Returns:
  ///   A ```Map<String, dynamic>``` containing the game model data in JSON format
  Map<String, dynamic> fakeData() {
    return widget.gameModel.toJson();
  }

  /// Adapts the layout based on the screen width.
  ///
  /// Uses [ResponsiveBreakpoints] to determine the appropriate layout.
  /// Sets the [phoneLayout flag for adjusting scrolling behavior.
  ///
  /// Args:
  ///   width: The width of the screen.
  ///
  /// Returns:
  ///   The appropriate layout widget.
  Widget _adaptiveLayout(final double width) {
    // DESKTOP or TABLET
    if (width >= ResponsiveBreakpoints.desktop ||
        width >= ResponsiveBreakpoints.tablet) {
      phoneLayout = false;
      return _layoutForDesktop();
    }

    // PHONE
    phoneLayout = true;
    return _layoutForPhone();
  }

  /// Builds the floating discarded card and applies a flip effect during
  /// the upward flight animation.
  Widget _buildDiscardedCardFlip(
    CardModel card,
    double animationValue,
    bool _,
  ) {
    final bool showFront = animationValue >= ConstLayout.scaleSmall;
    final CardModel displayCard = CardModel(
      suit: card.suit,
      rank: card.rank,
      value: card.value,
      partOfSet: card.partOfSet,
      isRevealed: showFront,
    );
    final double rotationY = pi * (1.0 - animationValue);
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(rotationY),
      child: Opacity(
        opacity: max(
          ConstLayout.strokeXXS,
          1.0 - (animationValue / ConstLayout.strokeS),
        ),
        child: CardWidget(card: displayCard),
      ),
    );
  }

  /// Wraps the regular game layout with a transient overlay that animates the
  /// swapped-out hidden card vertically toward the top area of the screen.
  Widget _buildLayoutWithSwapAnimation(final Widget layout) {
    return Stack(
      children: [
        layout,
        if (_activeSwapAnimationEvent != null)
          Positioned.fill(
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                key: ValueKey<int>(_swapAnimationRunId),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(
                  milliseconds: ConstLayout.swapCardFlightAnimationDuration,
                ),
                curve: Curves.easeOutCubic,
                builder: (BuildContext _, double animationValue, Widget? _) {
                  final double viewportHeight = MediaQuery.of(
                    context,
                  ).size.height;
                  final double viewportWidth = MediaQuery.of(
                    context,
                  ).size.width;
                  final Offset? origin = _activeSwapAnimationEvent!.origin;
                  final double endTop = ConstLayout.sizeL;
                  final double startTop =
                      (origin?.dy ?? (viewportHeight - ConstLayout.sizeXXL)) -
                      (CardDimensions.height / ConstLayout.strokeS);
                  final double left =
                      ((origin?.dx ?? (viewportWidth / ConstLayout.strokeS)) -
                              (CardDimensions.width / ConstLayout.strokeS))
                          .clamp(
                            0.0,
                            max(0.0, viewportWidth - CardDimensions.width),
                          );
                  final double top =
                      lerpDouble(startTop, endTop, animationValue) ?? endTop;
                  return Stack(
                    children: [
                      Positioned(
                        top: top,
                        left: left,
                        child: _buildDiscardedCardFlip(
                          _activeSwapAnimationEvent!.discardedCard,
                          animationValue,
                          _activeSwapAnimationEvent!.wasHidden,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  /// Builds a horizontally wrapping layout of player zones.
  Widget _buildPlayersWrapLayout() {
    return Wrap(
      spacing: ConstLayout.sizeXL,
      runSpacing: ConstLayout.sizeXL,
      children: List.generate(widget.gameModel.numPlayers, (index) {
        return PlayerZoneWidget(
          key: _playerKeys[index],
          gameModel: widget.gameModel,
          player: widget.gameModel.players[index],
          heightZone: ConstLayout.desktopPlayerZoneHeight,
          heightOfCTA: ConstLayout.playerZoneCTAHeight,
          heightOfCardGrid: ConstLayout.desktopCardGridHeight,
        );
      }),
    );
  }

  void _createGlobalKeyForPlayers() {
    _playerKeys = List.generate(
      widget.gameModel.numPlayers,
      (_ /* index */) => GlobalKey(),
    );
  }

  /// Converts a Firebase snapshot payload into the in-memory game model.
  void _dataSnapshotToGameModel(final DataSnapshot snapshot) {
    if (!snapshot.exists) {
      return;
    }

    final Object? data = snapshot.value;
    if (data != null) {
      // Convert the data to a Map<String, dynamic>
      String jsonData = jsonEncode(data);
      Map<String, dynamic> mapData = jsonDecode(jsonData);
      _jsonToGameModel(mapData);
    }
  }

  /// Fetches game data from Firebase
  Future<void> _getFirebaseData() async {
    if (isRunningOffLine) {
      _jsonToGameModel(fakeData());
    } else {
      final DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref(_getFirebaseRef())
          .get();
      _dataSnapshotToGameModel(snapshot);
    }
  }

  /// Gets the Firebase database reference path for this game room
  String _getFirebaseRef() {
    return 'rooms/${widget.gameModel.roomName}';
  }

  /// Initializes the Firebase listener for game state updates.
  void _initializeFirebaseListener() {
    if (isRunningOffLine) {
      _jsonToGameModel(fakeData());
    } else {
      _streamSubscription = FirebaseDatabase.instance
          .ref(_getFirebaseRef())
          .onValue
          .listen((DatabaseEvent event) {
            _dataSnapshotToGameModel(event.snapshot);
          });
    }
  }

  /// Applies decoded game JSON to [widget.gameModel] and refreshes local UI.
  void _jsonToGameModel(Map<String, dynamic> mapData) {
    widget.gameModel.fromJson(mapData);
    setState(() {
      _createGlobalKeyForPlayers();
      if (widget.gameModel.gameState == GameStates.gameOver) {
        widget.gameModel.endedOn = DateTime.now();

        showGameOverDialog(context, widget.gameModel);
      }
      isReady = true;
    });
  }

  /// Builds the layout for desktop/tablet screens.  Uses a horizontal wrapping layout.
  Widget _layoutForDesktop() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: ConstLayout.paddingXL, bottom: 0.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: _buildPlayersWrapLayout(),
        ),
      ),
    );
  }

  /// Builds the layout for phone screens.  Uses a vertical column layout.
  Widget _layoutForPhone() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(widget.gameModel.numPlayers, (index) {
          return Padding(
            padding: const EdgeInsets.all(ConstLayout.paddingM),
            child: PlayerZoneWidget(
              key: _playerKeys[index],
              gameModel: widget.gameModel,
              player: widget.gameModel.players[index],
              heightZone: ConstLayout.phonePlayerZoneHeight,
              heightOfCTA: ConstLayout.playerZoneCTAHeight,
              heightOfCardGrid: ConstLayout.phoneCardGridHeight,
            ),
          );
        }),
      ),
    );
  }

  /// Updates local UI and triggers the discarded-card overlay animation when a
  /// new swap animation event is emitted by the game model.
  void _onGameModelUpdated() {
    if (!mounted) {
      return;
    }

    final int eventId = widget.gameModel.swapAnimationEventId;
    if (eventId > _lastHandledSwapAnimationEventId &&
        widget.gameModel.lastSwapAnimationEvent != null) {
      _lastHandledSwapAnimationEventId = eventId;
      _swapAnimationRunId += CardModel.nextPlayerIncrement;
      _activeSwapAnimationEvent = widget.gameModel.lastSwapAnimationEvent;
      _swapAnimationCleanupTimer?.cancel();
      _swapAnimationCleanupTimer = Timer(
        const Duration(
          milliseconds: ConstLayout.swapCardFlightAnimationDuration,
        ),
        () {
          if (!mounted) {
            return;
          }
          setState(() {
            _activeSwapAnimationEvent = null;
          });
        },
      );
    }

    setState(() {
      // Rebuild on model changes and animation event updates.
    });
  }

  /// Refreshes the game state by fetching the latest data from Firebase.
  ///
  /// Sets the loading state to true, retrieves the game data from the
  /// corresponding Firebase node, and then updates the game model with
  /// the retrieved data.  Finally, sets the loading state back to false
  /// after the data has been processed.
  void _onRefresh() {
    _getFirebaseData();
  }

  /// Scrolls to the currently active player.
  void _setupScrollToActivePlayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int playerIndex = widget.gameModel.playerIdPlaying;
      if (playerIndex < _playerKeys.length) {
        final RenderBox? containerBox =
            context.findRenderObject() as RenderBox?;
        final RenderBox? playerBox =
            _playerKeys[playerIndex].currentContext?.findRenderObject()
                as RenderBox?;

        if (containerBox != null && playerBox != null) {
          final double containerOffset = containerBox
              .localToGlobal(Offset.zero)
              .dy;
          final double playerOffset =
              playerBox.localToGlobal(Offset.zero).dy - containerOffset;
          final double offset = _scrollController.offset + playerOffset;

          // Calculate maximum scroll extent and clamp offset
          final double maxScrollExtent =
              _scrollController.position.maxScrollExtent;
          final double targetOffset =
              (offset -
                      (phoneLayout
                          ? ConstLayout.phoneScrollOffset
                          : ConstLayout.desktopScrollOffset))
                  .clamp(0.0, maxScrollExtent);

          _scrollController.animateTo(
            targetOffset,
            duration: Duration(
              milliseconds: ConstLayout.scrollAnimationDuration,
            ),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }
}
