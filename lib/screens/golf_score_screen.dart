// ignore_for_file: require_trailing_commas

import 'package:cards/models/golf_score_model.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/editable_player_name.dart';
import 'package:cards/widgets/input_keyboard.dart';
import 'package:flutter/material.dart';

/// A screen for keeping score of 9 Cards Golf games.
class GolfScoreScreen extends StatefulWidget {
  /// Creates the Golf Score Screen widget.
  const GolfScoreScreen({super.key});

  @override
  State<GolfScoreScreen> createState() => _GolfScoreScreenState();
}

class _GolfScoreScreenState extends State<GolfScoreScreen> {
  late Future<GolfScoreModel> _scoreModelFuture;
  final String _version = '1.0.+2';
  Map<String, int>? _selectedCell;

  @override
  void initState() {
    super.initState();
    _scoreModelFuture = GolfScoreModel.load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addPlayer(GolfScoreModel model) {
    setState(() {
      model.addPlayer('Player ${model.playerNames.length + 1}');
    });
  }

  void _clearScores(GolfScoreModel model) {
    setState(() {
      model.clearScores();
    });
  }

  void _handleKeyPress(String key, GolfScoreModel model) {
    if (_selectedCell == null) {
      return;
    }

    final int row = _selectedCell!['row']!;
    final int col = _selectedCell!['col']!;
    String currentValue = model.scores[row][col].toString();

    setState(() {
      if (key == '⇐') {
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
      } else if (key == '−') {
        if (currentValue.startsWith('-')) {
          currentValue = currentValue.substring(1);
        } else {
          currentValue = '-$currentValue';
        }
      } else {
        if (currentValue == '0') {
          currentValue = key;
        } else {
          currentValue += key;
        }
      }

      final int? parsedValue = int.tryParse(currentValue);
      model.updateScore(
        row,
        col,
        parsedValue ?? 0,
      );
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
            version: _version,
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
          version: _version,
          isWaiting: false,
          onRefresh: () => confirmNewGame(scoreModel),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: columnGap,
                    horizontalMargin: 0,
                    columns: [
                      // Player Names
                      for (int i = 0; i < scoreModel.playerNames.length; i++)
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth, // Adjust width as needed
                            child: EditablePlayerName(
                              key: Key('\$i\${scoreModel.playerNames[i]}'),
                              playerName: scoreModel.playerNames[i],
                              color: _getScoreColor(
                                      ranks[i], scoreModel.playerNames.length)
                                  .withAlpha(100),
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
                      DataColumn(
                        label: IconButton(
                            onPressed: () => _addPlayer(scoreModel),
                            icon: const Icon(Icons.add)),
                      ),
                    ],
                    // Player Names and Scores
                    rows: [
                      for (int i = 0; i < scoreModel.scores.length; i++)
                        DataRow(cells: [
                          for (int j = 0;
                              j < scoreModel.playerNames.length;
                              j++)
                            DataCell(
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCell = {'row': i, 'col': j};
                                  });
                                },
                                child: Container(
                                  width: columnWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    border: Border.all(
                                      color: _selectedCell != null &&
                                              _selectedCell!['row'] == i &&
                                              _selectedCell!['col'] == j
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                  ),
                                  child: Text(
                                    scoreModel.scores[i][j].toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: _getScoreColor(ranks[j],
                                            scoreModel.playerNames.length)),
                                  ),
                                ),
                              ),
                            ),
                          DataCell(
                            SizedBox(
                              width: columnWidth / 2,
                              child: (i == 0)
                                  ? const Text('')
                                  : IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        confirmDeleteRound(i, scoreModel);
                                      },
                                    ),
                            ),
                          ),
                        ]),
                    ],
                  ),
                ),
                if (_selectedCell != null)
                  InputKeyboard(
                    onKeyPressed: (key) => _handleKeyPress(key, scoreModel),
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
                                color: _getScoreColor(
                                    ranks[j], scoreModel.playerNames.length)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: columnWidth / 2,
                    )
                  ],
                ),
              ],
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
