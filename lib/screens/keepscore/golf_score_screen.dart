// ignore_for_file: require_trailing_commas, deprecated_member_use

import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/golf_score_model.dart';
import 'package:cards/widgets/buttons/my_button_round.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/helpers/input_keyboard.dart';
import 'package:cards/widgets/player/player_header.dart';
import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final double columnGap = ConstLayout.sizeS;

  final double columnWidth = ConstLayout.golfColumnWidth;

  @override
  void initState() {
    super.initState();
    _scoreModelFuture = GolfScoreModel.load().then((model) {
      // Request focus after the model is loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _keyboardFocusNode.requestFocus();
      });
      return model;
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return FutureBuilder<GolfScoreModel>(
      future: _scoreModelFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return Screen(
            title: localizations.golfScoreKeeper,
            isWaiting: true,
            child: Center(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? CircularProgressIndicator()
                  : Text(
                      localizations.errorLoadingScores(
                        snapshot.error.toString(),
                      ),
                    ),
            ),
          );
        }

        final GolfScoreModel scoreModel = snapshot.data!;
        final List<int> ranks = scoreModel.getPlayerRanks();
        final colorScheme = Theme.of(context).colorScheme;

        return Screen(
          title: localizations.golfScoreKeeper,
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
                    // Header row with player names
                    FittedBox(child: _buildPlayersHeader(scoreModel, ranks)),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        // padding: EdgeInsets.all(8),
                        child: FittedBox(
                          child: Column(
                            children: [
                              _buildRounds(
                                context,
                                scoreModel,
                                ranks,
                                colorScheme,
                              ),
                              if (_selectedCell == null)
                                _buildAddOrRemoveRow(
                                  context,
                                  scoreModel,
                                  colorScheme,
                                ),
                              if (_selectedCell != null)
                                InputKeyboard(
                                  onKeyPressed: (key) =>
                                      _handleKeyPress(key, scoreModel),
                                ),
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        model.removeRoundAt(i);
      });
    }
  }

  /// Shows a confirmation dialog before deleting a round.
  Future<void> confirmNewGame(GolfScoreModel model) async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations.newGame),
        content: Text(localizations.confirmNewGame),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _clearScores(model);
      });
    }
  }

  void _addPlayer(GolfScoreModel model) {
    setState(() {
      model.addPlayer('Player${model.playerNames.length + 1}');
    });
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
        padding: EdgeInsets.all(ConstLayout.sizeS),
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
            if (scoreModel.scores.length > 1)
              MyButtonRound(
                onTap: () {
                  final lastRoundScores = scoreModel.scores.last;
                  final allScoresAreZero = lastRoundScores.every(
                    (score) => score == 0,
                  );
                  if (allScoresAreZero) {
                    setState(() {
                      scoreModel.removeRoundAt(scoreModel.scores.length - 1);
                    });
                  } else {
                    confirmDeleteRound(
                      scoreModel.scores.length - 1,
                      scoreModel,
                    );
                  }
                },
                child: Icon(Icons.remove),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the player header row with rank, score, and player actions.
  Widget _buildPlayersHeader(
    final GolfScoreModel scoreModel,
    final dynamic ranks,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
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
                },
                onPlayerRemoved: () {
                  setState(() {
                    scoreModel.removePlayerAt(i);
                  });
                },
                onPlayerAdded: () {
                  _addPlayer(scoreModel);
                },
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
                    _cellContext = context;
                    return Container(
                      width: columnWidth,
                      height: ConstLayout.height40,
                      margin: EdgeInsets.only(top: columnGap),
                      decoration: BoxDecoration(
                        color: AppTheme.panelInputZone,
                        border: Border.all(
                          color:
                              _selectedCell != null &&
                                  _selectedCell!['row'] == i &&
                                  _selectedCell!['col'] == j
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

  void _clearScores(GolfScoreModel model) {
    setState(() {
      model.clearScores();
    });
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
        model.updateScore(row, col, parsedValue ?? 0);
      }
    });
  }
}
