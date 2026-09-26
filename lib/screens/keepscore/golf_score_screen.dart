// ignore_for_file: require_trailing_commas, deprecated_member_use

import 'dart:async';

import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/identity_service.dart';
import 'package:cards/models/game/game_constants.dart';
import 'package:cards/models/game/golf_score_model.dart';
import 'package:cards/models/game/score_session.dart';
import 'package:cards/models/game/score_session_participant.dart';
import 'package:cards/models/game/score_session_service.dart';
import 'package:cards/models/game/score_session_state.dart';
import 'package:cards/screens/game/card_scan_screen.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/buttons/my_button_round.dart';
import 'package:cards/widgets/helpers/app_bottom_sheet.dart';
import 'package:cards/widgets/helpers/input_keyboard.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/player/player_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum _NewGameAction { clearScores, startWithQr }

const String _manualScorePlayerIdPrefix = 'manual';

/// A screen for keeping score of 9 Cards Golf games.
class GolfScoreScreen extends StatefulWidget {
  /// Creates the Golf Score Screen widget.
  const GolfScoreScreen({super.key});

  @override
  State<GolfScoreScreen> createState() => _GolfScoreScreenState();
}

class _GolfScoreScreenState extends State<GolfScoreScreen> {
  BuildContext? _cellContext;
  final FocusNode _keyboardFocusNode = FocusNode();
  final Set<LogicalKeyboardKey> _keysPressed = {};
  late Future<GolfScoreModel> _scoreModelFuture;
  final ScrollController _scrollController = ScrollController();
  Map<String, int>? _selectedCell;
  ScoreSession? _activeScoreSession;
  final List<ScoreSessionParticipant> _scoreSessionParticipants = [];
  final List<String> _scoreSessionPlayerIds = [];
  StreamSubscription<List<ScoreSessionParticipant>>?
  _scoreSessionParticipantsSubscription;
  StreamSubscription<ScoreSessionState>? _scoreSessionStateSubscription;
  final double columnGap = ConstLayout.sizeS;
  final double columnWidth = ConstLayout.golfColumnWidth;
  @override
  void initState() {
    super.initState();
    _scoreModelFuture = GolfScoreModel.load().then((model) {
      if (!mounted) {
        return model;
      }

      // Request focus after the model is loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _keyboardFocusNode.requestFocus();
        }
      });
      _joinScoreSessionFromLink(model);
      return model;
    });
  }

  @override
  void dispose() {
    _scoreSessionParticipantsSubscription?.cancel();
    _scoreSessionStateSubscription?.cancel();
    _keyboardFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return FutureBuilder<GolfScoreModel>(
      future: _scoreModelFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return _buildLoadingOrErrorContent(snapshot, localizations);
        }
        final GolfScoreModel scoreModel = snapshot.data!;
        final List<int> ranks = scoreModel.getPlayerRanks();
        return _buildScoreContent(scoreModel, ranks, localizations);
      },
    );
  }

  /// Shows a confirmation dialog before deleting a round.
  Future<void> confirmDeleteRound(int i, GolfScoreModel model) async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations.deleteLastRow),
        content: Text(localizations.confirmDeleteRound(i + 1)),
        actions: [
          MyButtonRectangle.secondary(
            width: ConstLayout.dialogButtonWidth,
            height: ConstLayout.dialogButtonHeight,
            onTap: () => Navigator.of(ctx).pop(false),
            child: Text(localizations.cancel),
          ),
          MyButtonRectangle.danger(
            width: ConstLayout.dialogButtonWidth,
            height: ConstLayout.dialogButtonHeight,
            onTap: () => Navigator.of(ctx).pop(true),
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      model.removeRoundAt(i);
      _selectedCell = null;
    });
    final ScoreSession? session = _activeScoreSession;
    if (session != null) {
      unawaited(ScoreSessionService.removeRound(session.id, i));
    }
  }

  /// Offers a local clear or a QR-invited new score table.
  Future<void> confirmNewGame(GolfScoreModel model) async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final _NewGameAction? action = await showAppBottomSheet<_NewGameAction>(
      context: context,
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.all(ConstLayout.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: ConstLayout.sizeM,
          children: [
            Text(
              localizations.newGame,
              style: TextStyle(
                fontSize: ConstLayout.textL,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(localizations.confirmNewGame, textAlign: TextAlign.center),
            MyButtonRectangle.menu(
              label: localizations.clearScores,
              icon: Icons.clear,
              onTap: () =>
                  Navigator.of(sheetContext).pop(_NewGameAction.clearScores),
            ),
            MyButtonRectangle.menu(
              label: localizations.startNewGameWithQr,
              icon: Icons.qr_code,
              onTap: () =>
                  Navigator.of(sheetContext).pop(_NewGameAction.startWithQr),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == _NewGameAction.clearScores) {
      _clearScores(model);
    } else {
      await _startNewGameWithQr(model);
    }
  }

  void _addPlayer(GolfScoreModel model) {
    final String playerName =
        '${GameConstants.playerNumberPrefix}${model.playerNames.length + 1}';
    final String playerId =
        '${_manualScorePlayerIdPrefix}_${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      model.addPlayer(playerName);
    });
    final ScoreSession? session = _activeScoreSession;
    if (session != null) {
      unawaited(
        ScoreSessionService.addManualPlayer(session.id, playerId, playerName),
      );
    }
  }

  /// Builds controls for adding/removing rounds and current round count.
  Widget _buildAddOrRemoveRow(
    final BuildContext context,
    final GolfScoreModel scoreModel,
    final ColorScheme _ /* colorScheme*/,
  ) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return IntrinsicWidth(
      child: Container(
        margin: EdgeInsets.all(ConstLayout.sizeS),
        decoration: BoxDecoration(
          color: AppTheme.panelInputZone,
          borderRadius: const BorderRadius.all(
            Radius.circular(ConstLayout.radiusXL),
          ),
        ),
        padding: EdgeInsets.all(ConstLayout.paddingS),
        /* was 10, using 8 for consistency? Or should add 10? Using sizeS for now if close enough or add 10 */
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: ConstLayout.sizeS,
          children: [
            MyButtonRound(
              onTap: () {
                setState(() {
                  scoreModel.addRound();
                });
                final ScoreSession? session = _activeScoreSession;
                if (session != null) {
                  unawaited(ScoreSessionService.addRound(session.id));
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(
                      milliseconds: ConstLayout.animationDuration300,
                    ),
                    curve: Curves.easeInOut,
                  );
                });
              },
              child: Icon(Icons.add),
            ),

            Text(
              localizations.rounds(scoreModel.scores.length),
              style: TextStyle(fontSize: ConstLayout.textS),
            ),

            MyButtonRound(
              onTap: () {
                final lastRoundScores = scoreModel.scores.last;
                final allScoresAreZero = lastRoundScores.every(
                  (score) => score == 0,
                );
                if (allScoresAreZero) {
                  setState(() {
                    scoreModel.removeRoundAt(scoreModel.scores.length - 1);
                    _selectedCell = null;
                  });
                  final ScoreSession? session = _activeScoreSession;
                  if (session != null) {
                    unawaited(
                      ScoreSessionService.removeRound(
                        session.id,
                        scoreModel.scores.length,
                      ),
                    );
                  }
                } else {
                  confirmDeleteRound(scoreModel.scores.length - 1, scoreModel);
                }
              },
              child: Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the inline keypad and camera tools for editing the selected score.
  Widget _buildKeyboardAndCameraSection(GolfScoreModel scoreModel) {
    return Column(
      children: [
        InputKeyboard(onKeyPressed: (key) => _handleKeyPress(key, scoreModel)),
        // AI Camera Scanner Button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyButtonRound(
              onTap: () => _openCameraScanner(scoreModel),
              size: ConstLayout.iconL,
              child: const Icon(Icons.camera_alt),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the loading state or an error message when score data cannot be read.
  Widget _buildLoadingOrErrorContent(
    AsyncSnapshot<GolfScoreModel> snapshot,
    AppLocalizations l10n,
  ) {
    final bool isWaiting = snapshot.connectionState == ConnectionState.waiting;

    return Screen(
      title: l10n.golfScoreKeeper,
      isWaiting: isWaiting,
      child: Center(
        child: isWaiting
            ? CircularProgressIndicator()
            : Text(l10n.errorLoadingScores(snapshot.error.toString())),
      ),
    );
  }

  /// Builds the player header row with rank, score, and player actions.
  Widget _buildPlayersHeader(
    final GolfScoreModel scoreModel,
    final dynamic ranks,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: ConstLayout.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: columnGap,
        children: [
          for (int i = 0; i < scoreModel.playerNames.length; i++)
            SizedBox(
              width: columnWidth,
              child: PlayerHeader(
                key: Key('\$i\${scoreModel.playerNames[i]}'),
                playerName: scoreModel.playerNames[i],
                playerIndex: i,
                rank: ranks[i],
                numberOfPlayers: scoreModel.playerNames.length,
                totalScore: scoreModel.getPlayerTotalScore(i),
                onNameChanged: (newName) {
                  setState(() {
                    scoreModel.playerNames[i] = newName;
                  });
                  final ScoreSession? session = _activeScoreSession;
                  if (session != null) {
                    unawaited(
                      ScoreSessionService.updatePlayerName(
                        session.id,
                        i,
                        newName,
                      ),
                    );
                  }
                },
                onPlayerRemoved: () {
                  setState(() {
                    scoreModel.removePlayerAt(i);
                    _selectedCell = null;
                  });
                  final ScoreSession? session = _activeScoreSession;
                  if (session != null) {
                    unawaited(ScoreSessionService.removePlayer(session.id, i));
                  }
                },
                onPlayerAdded: () {
                  _addPlayer(scoreModel);
                },
                participantFirebaseId: _participantAt(i)?.firebaseId,
                participantAvatarUrl: _participantAt(i)?.avatarUrl,
                participantEmail: _participantAt(i)?.email,
                participantOAuthType: _participantAt(i)?.oAuthType,
                participantTitle: _participantAt(i)?.title,
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the round-by-round score grid with selectable score cells.
  Widget _buildRounds(
    final BuildContext _,
    final dynamic scoreModel,
    final dynamic ranks,
    final ColorScheme colorScheme,
  ) {
    List<Widget> widgets = [
      for (int i = 0; i < scoreModel.scores.length; i++)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: columnGap,
          children: [
            for (int j = 0; j < scoreModel.playerNames.length; j++)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedCell != null &&
                        _selectedCell!['row'] == i &&
                        _selectedCell!['col'] == j) {
                      _selectedCell = null;
                    } else {
                      _selectedCell = {'row': i, 'col': j};
                    }
                  });
                  if (_selectedCell != null &&
                      _selectedCell!['row'] == i &&
                      _selectedCell!['col'] == j) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final context = _cellContext;
                      if (context != null) {
                        _scrollController.position.ensureVisible(
                          context.findRenderObject() as RenderObject,
                          alignment: ConstLayout.scrollAlignmentCenter,
                          duration: Duration(
                            milliseconds: ConstLayout.animationDuration300,
                          ),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  }
                },
                child: Builder(
                  builder: (BuildContext context) {
                    final bool isSelectedCell =
                        _selectedCell != null &&
                        _selectedCell!['row'] == i &&
                        _selectedCell!['col'] == j;
                    if (isSelectedCell) {
                      _cellContext = context;
                    }

                    return Container(
                      width: columnWidth,
                      height: ConstLayout.height40,
                      margin: EdgeInsets.only(top: columnGap),
                      decoration: BoxDecoration(
                        color: AppTheme.panelInputZone,
                        border: Border.all(
                          color: isSelectedCell
                              ? Colors.yellow
                              : Colors.transparent,
                          width: ConstLayout.strokeS,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(ConstLayout.radiusS),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          scoreModel.scores[i][j] == 0
                              ? '0'
                              : scoreModel.scores[i][j].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ConstLayout.textM,
                            color: _getScoreColor(
                              colorScheme,
                              ranks[j],
                              scoreModel.playerNames.length,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: ConstLayout.strokeXS,
      children: widgets,
    );
  }

  /// Builds the complete scorekeeper layout once model data is available.
  Widget _buildScoreContent(
    GolfScoreModel scoreModel,
    List<int> ranks,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Screen(
      title: l10n.golfScoreKeeper,
      isWaiting: false,
      onRefresh: () => confirmNewGame(scoreModel),
      child: RawKeyboardListener(
        focusNode: _keyboardFocusNode,
        onKey: _handleKeyEvent,
        autofocus: true,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            setState(() {
              _selectedCell = null;
            });
          },
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_activeScoreSession != null)
                  Padding(
                    padding: const EdgeInsets.only(top: ConstLayout.paddingM),
                    child: Semantics(
                      button: true,
                      child: InkWell(
                        onTap: () {
                          _showScoreSessionQrCode(_activeScoreSession!);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(ConstLayout.paddingS),
                          child: FittedBox(
                            child: Text(
                              l10n.tableLabel(_activeScoreSession!.tableName),
                              style: TextStyle(
                                fontSize: ConstLayout.textS,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.tertiary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                FittedBox(child: _buildPlayersHeader(scoreModel, ranks)),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: FittedBox(
                      child: Column(
                        children: [
                          _buildRounds(context, scoreModel, ranks, colorScheme),
                          if (_selectedCell == null)
                            _buildAddOrRemoveRow(
                              context,
                              scoreModel,
                              colorScheme,
                            ),
                          if (_selectedCell != null)
                            _buildKeyboardAndCameraSection(scoreModel),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearScores(GolfScoreModel model) {
    setState(() {
      model.clearScores();
      _selectedCell = null;
    });
    final ScoreSession? session = _activeScoreSession;
    if (session != null) {
      unawaited(ScoreSessionService.clearScores(session.id));
    }
  }

  Future<void> _joinScoreSessionFromLink(GolfScoreModel model) async {
    final String? sessionId = ScoreSessionService.sessionIdFromUri(Uri.base);
    if (sessionId == null || sessionId.isEmpty) {
      return;
    }
    final ScoreSession? session = await ScoreSessionService.getSession(
      sessionId,
    );
    if (session == null) {
      return;
    }
    final String? identity = await IdentityService.resolveIdentityName();
    await ScoreSessionService.joinSession(sessionId, identity ?? '');
    if (mounted) {
      _watchScoreSession(session, model);
    }
  }

  Future<void> _startNewGameWithQr(GolfScoreModel model) async {
    final String? identity = await IdentityService.resolveIdentityName();
    final ScoreSession? session = await ScoreSessionService.createSession(
      identity ?? '',
    );
    if (!mounted || session == null) {
      return;
    }

    _watchScoreSession(session, model);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }

    await _showScoreSessionQrCode(session);
  }

  /// Displays an existing score-session invitation for additional players.
  Future<void> _showScoreSessionQrCode(ScoreSession session) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final AppLocalizations localizations = AppLocalizations.of(
          dialogContext,
        );
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ConstLayout.mainMenuMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(ConstLayout.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizations.tableLabel(session.tableName),
                    style: TextStyle(
                      fontSize: ConstLayout.textM,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ConstLayout.sizeM),
                  QrImageView(
                    data: session.inviteUrl,
                    size: ConstLayout.scoreQrCodeSize,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: ConstLayout.sizeM),
                  Text(localizations.scanQrToJoin, textAlign: TextAlign.center),
                  const SizedBox(height: ConstLayout.sizeM),
                  MyButtonRectangle.secondary(
                    width: ConstLayout.dialogButtonWidth,
                    height: ConstLayout.dialogButtonHeight,
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: Text(localizations.done),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _watchScoreSession(ScoreSession session, GolfScoreModel model) {
    _scoreSessionParticipantsSubscription?.cancel();
    _scoreSessionStateSubscription?.cancel();
    setState(() {
      _activeScoreSession = session;
      _scoreSessionParticipants.clear();
      _scoreSessionPlayerIds.clear();
    });
    _scoreSessionParticipantsSubscription =
        ScoreSessionService.participants(session.id).listen((
          List<ScoreSessionParticipant> participants,
        ) {
          if (!mounted) {
            return;
          }
          setState(() {
            _scoreSessionParticipants
              ..clear()
              ..addAll(participants);
          });
        });
    _scoreSessionStateSubscription = ScoreSessionService.scoreState(session.id)
        .listen((ScoreSessionState state) {
          if (!mounted) {
            return;
          }
          setState(() {
            _scoreSessionPlayerIds
              ..clear()
              ..addAll(state.playerIds);
            model.applySharedState(
              names: state.playerNames,
              sharedScores: state.scores,
            );
            if (_selectedCell != null &&
                (_selectedCell!['row']! >= model.scores.length ||
                    _selectedCell!['col']! >= model.playerNames.length)) {
              _selectedCell = null;
            }
          });
        });
  }

  ScoreSessionParticipant? _participantAt(int playerIndex) {
    if (playerIndex >= _scoreSessionPlayerIds.length) {
      return null;
    }
    final String playerId = _scoreSessionPlayerIds[playerIndex];
    for (final ScoreSessionParticipant participant
        in _scoreSessionParticipants) {
      if (participant.firebaseId == playerId) {
        return participant;
      }
    }
    return null;
  }

  /// Returns a score color based on leaderboard rank and player count.
  Color _getScoreColor(ColorScheme colorScheme, int rank, int numberOfPlayers) {
    if (rank == 1) {
      return colorScheme.primary;
    } else if (rank == numberOfPlayers) {
      return colorScheme.error;
    } else {
      return colorScheme.secondary;
    }
  }

  /// Handles physical keyboard input and routes supported keys to score edits.
  void _handleKeyEvent(RawKeyEvent event) async {
    if (_selectedCell == null) {
      return;
    }

    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;
      if (_keysPressed.contains(key)) {
        return;
      }
      _keysPressed.add(key);

      // Get the model from the future
      final model = await _scoreModelFuture;
      if (!mounted) {
        return;
      }

      if (key == LogicalKeyboardKey.backspace) {
        _handleKeyPress('⇐', model);
      } else if (key == LogicalKeyboardKey.minus) {
        _handleKeyPress('−', model);
      } else if (key.keyLabel.length == 1) {
        final keyLabel = key.keyLabel;
        if (RegExp(r'^[0-9]$').hasMatch(keyLabel)) {
          _handleKeyPress(keyLabel, model);
        }
      }
    } else if (event is RawKeyUpEvent) {
      _keysPressed.remove(event.logicalKey);
    }
  }

  /// Applies a keypad action to the currently selected score cell.
  void _handleKeyPress(String key, GolfScoreModel model) {
    if (_selectedCell == null) {
      return;
    }

    final int row = _selectedCell!['row']!;
    final int col = _selectedCell!['col']!;
    String currentValue = model.scores[row][col].toString();

    setState(() {
      if (key == keyBackspace) {
        if (currentValue.isNotEmpty) {
          if (currentValue.length == ConstLayout.negativeNumberMaxLength &&
              currentValue.startsWith('-')) {
            currentValue = '0';
          } else {
            currentValue = currentValue.substring(0, currentValue.length - 1);
          }
          if (currentValue.isEmpty) {
            currentValue = '0';
          }
        }
      } else if (key == keyChangeSign) {
        if (currentValue.startsWith('-')) {
          currentValue = currentValue.substring(1);
        } else if (currentValue == '0') {
          currentValue = '0'; // Start a negative number when at 0
        } else {
          currentValue = '-$currentValue';
        }
      } else {
        if (currentValue == '0' || currentValue == '-') {
          currentValue = currentValue == '-' ? '-$key' : key;
        } else {
          currentValue += key;
        }
      }
      // Only update the score if we have a valid number or are in the middle of typing a negative number
      if (currentValue != '-') {
        final int? parsedValue = int.tryParse(currentValue);
        final int score = parsedValue ?? 0;
        model.updateScore(row, col, score);
        final ScoreSession? session = _activeScoreSession;
        if (session != null) {
          unawaited(
            ScoreSessionService.updateScore(session.id, row, col, score),
          );
        }
      }
    });
  }

  /// Opens the AI camera scanner and sets the detected score in the active cell.
  Future<void> _openCameraScanner(GolfScoreModel model) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CardScanScreen(
          onScoreConfirmed: (score) => _setScoreFromCamera(score, model),
        ),
      ),
    );
  }

  /// Sets the active cell value directly (used after camera detection).
  void _setScoreFromCamera(int value, GolfScoreModel model) {
    if (_selectedCell == null) {
      return;
    }
    final int row = _selectedCell!['row']!;
    final int col = _selectedCell!['col']!;
    setState(() {
      model.updateScore(row, col, value);
      _selectedCell = null;
    });
    final ScoreSession? session = _activeScoreSession;
    if (session != null) {
      unawaited(ScoreSessionService.updateScore(session.id, row, col, value));
    }
  }
}
