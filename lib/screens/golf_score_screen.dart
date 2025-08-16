// ignore_for_file: require_trailing_commas, deprecated_member_use

import 'package:cards/models/golf_score_model.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/editable_player_name.dart';
import 'package:cards/widgets/input_keyboard.dart';
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
  late Future<GolfScoreModel> _scoreModelFuture;
  Map<String, int>? _selectedCell;
  final FocusNode _keyboardFocusNode = FocusNode();
  final Set<LogicalKeyboardKey> _keysPressed = {};

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
    super.dispose();
  }

  void _addPlayer(GolfScoreModel model) {
    setState(() {
      model.addPlayer('Player${model.playerNames.length + 1}');
    });
  }

  void _clearScores(GolfScoreModel model) {
    setState(() {
      model.clearScores();
    });
  }

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
          if (currentValue.length == 2 && currentValue.startsWith('-')) {
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
        model.updateScore(
          row,
          col,
          parsedValue ?? 0,
        );
      }
      if (!model.isLastRoundEmpty()) {
        model.addRound();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GolfScoreModel>(
      future: _scoreModelFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return Screen(
            title: '9 Cards Golf Scorekeeper',
            isWaiting: true,
            child: Center(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? CircularProgressIndicator()
                    : Text('Error loading scores: ${snapshot.error}')),
          );
        }

        final GolfScoreModel scoreModel = snapshot.data!;
        final List<int> ranks = scoreModel.getPlayerRanks();
        const double columnWidth = 90;
        const double columnGap = 8;

        return Screen(
          title: '9 Cards Golf Scorekeeper',
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
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row with player names
                          Row(
                            children: [
                              for (int i = 0;
                                  i < scoreModel.playerNames.length;
                                  i++)
                                Padding(
                                  padding: EdgeInsets.only(right: columnGap),
                                  child: SizedBox(
                                    width: columnWidth,
                                    child: EditablePlayerName(
                                      key: Key(
                                          '\$i\${scoreModel.playerNames[i]}'),
                                      playerName: scoreModel.playerNames[i],
                                      color: _getScoreColor(
                                        ranks[i],
                                        scoreModel.playerNames.length,
                                      ).withAlpha(100),
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
                                    ),
                                  ),
                                ),
                              // Add player button
                              IconButton(
                                onPressed: () => _addPlayer(scoreModel),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Score rows
                          for (int i = 0; i < scoreModel.scores.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  for (int j = 0;
                                      j < scoreModel.playerNames.length;
                                      j++)
                                    Padding(
                                      padding:
                                          EdgeInsets.only(right: columnGap),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedCell = {
                                              'row': i,
                                              'col': j
                                            };
                                          });
                                        },
                                        child: Container(
                                          width: columnWidth,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.black26,
                                            border: Border.all(
                                              color: _selectedCell != null &&
                                                      _selectedCell!['row'] ==
                                                          i &&
                                                      _selectedCell!['col'] == j
                                                  ? Colors.yellow
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              scoreModel.scores[i][j] == 0
                                                  ? '0'
                                                  : scoreModel.scores[i][j]
                                                      .toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: _getScoreColor(
                                                  ranks[j],
                                                  scoreModel.playerNames.length,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Delete round button
                                  SizedBox(
                                    width: columnWidth / 2,
                                    child: i == 0
                                        ? const SizedBox.shrink()
                                        : IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.close,
                                                size: 20),
                                            onPressed: () {
                                              confirmDeleteRound(i, scoreModel);
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_selectedCell != null)
                      Padding(
                        padding: const EdgeInsets.only(right: columnWidth / 2),
                        child: InputKeyboard(
                          onKeyPressed: (key) =>
                              _handleKeyPress(key, scoreModel),
                        ),
                      ),
                    // Total Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: columnGap,
                      children: [
                        for (int j = 0; j < scoreModel.playerNames.length; j++)
                          SizedBox(
                            width: columnWidth,
                            child: Container(
                              // color: Colors.black12,
                              margin: EdgeInsets.only(top: 20),
                              width: columnWidth,
                              child: Text(
                                scoreModel.getPlayerTotalScore(j).toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: _getScoreColor(ranks[j],
                                        scoreModel.playerNames.length)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: columnWidth / 2,
                        ),
                      ],
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
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Round'),
        content: Text('Are you sure you want to delete this round $i?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
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
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Game'),
        content: const Text(
            'Are you sure you want to start a new game? All scores will be lost?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
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

  Color _getScoreColor(int rank, int numberOfPlayers) {
    if (rank == 1) {
      return Colors.green.shade300;
    } else if (rank == numberOfPlayers) {
      return Colors.red.shade300;
    } else {
      return Colors.orange.shade300;
    }
  }
}
