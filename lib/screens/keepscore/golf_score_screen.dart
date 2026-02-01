// ignore_for_file: require_trailing_commas, deprecated_member_use

import 'package:cards/models/constants.dart';
import 'package:cards/models/golf_score_model.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/input_keyboard.dart';
import 'package:cards/widgets/my_button.dart';
import 'package:cards/widgets/player_header.dart';
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

  final double columnGap = Constants.paddingSmall;

  final double columnWidth = Constants.golfColumnWidth;

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
                  : Text('Error loading scores: ${snapshot.error}'),
            ),
          );
        }

        final GolfScoreModel scoreModel = snapshot.data!;
        final List<int> ranks = scoreModel.getPlayerRanks();

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
                              _buildRounds(scoreModel, ranks),
                              if (_selectedCell == null)
                                _buildAddOrRemoveRow(scoreModel),
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
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Last Row'),
        content: Text('Are you sure you want to delete round ${i + 1}?'),
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
          'Are you sure you want to start a new game? All scores will be lost?',
        ),
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

  void _addPlayer(GolfScoreModel model) {
    setState(() {
      model.addPlayer('Player${model.playerNames.length + 1}');
    });
  }

  Widget _buildAddOrRemoveRow(final GolfScoreModel scoreModel) {
    return IntrinsicWidth(
      child: Container(
        margin: EdgeInsets.all(Constants.paddingSmall),
        decoration: BoxDecoration(
          color: Colors.black26,
          border: Border.all(color: Colors.black26),
          borderRadius: const BorderRadius.all(
            Radius.circular(Constants.borderRadius40),
          ),
        ),
        padding: EdgeInsets.all(Constants.paddingSmall),
        /* was 10, using 8 for consistency? Or should add 10? Using paddingSmall for now if close enough or add 10 */
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Constants.paddingSmall,
          children: [
            MyButton(
              size: Constants.iconSize30,
              onTap: () {
                setState(() {
                  scoreModel.addRound();
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(
                      milliseconds: Constants.animationDuration300,
                    ),
                    curve: Curves.easeInOut,
                  );
                });
              },
              child: Icon(Icons.add),
            ),
            Text(
              '${scoreModel.scores.length} Rounds',
              style: TextStyle(fontSize: Constants.labelLargeSize),
            ),
            if (scoreModel.scores.length > 1)
              MyButton(
                size: Constants.iconSize30,
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

  Widget _buildRounds(final dynamic scoreModel, final dynamic ranks) {
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
                          alignment: Constants.scrollAlignmentCenter,
                          duration: Duration(
                            milliseconds: Constants.animationDuration300,
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
                      height: Constants.height40,
                      margin: EdgeInsets.only(top: columnGap),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        border: Border.all(
                          color:
                              _selectedCell != null &&
                                  _selectedCell!['row'] == i &&
                                  _selectedCell!['col'] == j
                              ? Colors.yellow
                              : Colors.transparent,
                          width: Constants.borderWidth2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(Constants.borderRadius5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          scoreModel.scores[i][j] == 0
                              ? '0'
                              : scoreModel.scores[i][j].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Constants.fontSize20,
                            color: _getScoreColor(
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
      spacing: Constants.borderWidth1,
      children: widgets,
    );
  }

  void _clearScores(GolfScoreModel model) {
    setState(() {
      model.clearScores();
    });
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
          if (currentValue.length == Constants.negativeNumberMaxLength &&
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
