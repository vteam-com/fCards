import 'dart:async';
import 'dart:convert';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/app/constants.dart';
import 'package:cards/screens/game/game_over_dialog.dart';
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
  /// List of GlobalKeys for each player widget, used for scrolling.
  List<GlobalKey> _playerKeys = [];

  /// Scroll controller for managing the scrolling behavior of the player list.
  late ScrollController _scrollController;

  late StreamSubscription _streamSubscription;

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
    if (isRunningOffLine) {
      _getFirebaseData();
      widget.gameModel.addListener(() {
        // Update the UI when the game model changes
        setState(() {
          // Update the UI
        });
      });
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
    _streamSubscription.cancel();
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
      child: _adaptiveLayout(width),
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

  /// Builds a horizontally wrapping layout of player zones.
  Widget _buildPlayersWrapLayout() {
    return Wrap(
      spacing: Constants.playerZoneSpacing,
      runSpacing: Constants.playerZoneSpacing,
      children: List.generate(widget.gameModel.numPlayers, (index) {
        return PlayerZoneWidget(
          key: _playerKeys[index],
          gameModel: widget.gameModel,
          player: widget.gameModel.players[index],
          heightZone: Constants.desktopPlayerZoneHeight,
          heightOfCTA: Constants.playerZoneCTAHeight,
          heightOfCardGrid: Constants.desktopCardGridHeight,
        );
      }),
    );
  }

  void _createGlobalKeyForPlayers() {
    _playerKeys = List.generate(
      widget.gameModel.numPlayers,
      (index) => GlobalKey(),
    );
  }

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
        padding: const EdgeInsets.only(
          top: Constants.desktopTopPadding,
          bottom: 0.0,
        ),
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
            padding: const EdgeInsets.all(Constants.phonePlayerZonePadding),
            child: PlayerZoneWidget(
              key: _playerKeys[index],
              gameModel: widget.gameModel,
              player: widget.gameModel.players[index],
              heightZone: Constants.phonePlayerZoneHeight,
              heightOfCTA: Constants.playerZoneCTAHeight,
              heightOfCardGrid: Constants.phoneCardGridHeight,
            ),
          );
        }),
      ),
    );
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
                          ? Constants.phoneScrollOffset
                          : Constants.desktopScrollOffset))
                  .clamp(0.0, maxScrollExtent);

          _scrollController.animateTo(
            targetOffset,
            duration: Duration(milliseconds: Constants.scrollAnimationDuration),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }
}
