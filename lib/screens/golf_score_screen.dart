// ignore_for_file: require_trailing_commas

import 'package:cards/models/golf_score_model.dart';
import 'package:cards/screens/screen.dart';
import 'package:flutter/material.dart';

/// A screen for keeping score of 9 Cards Golf games.
class GolfScoreScreen extends StatefulWidget {
  /// Creates the Golf Score Screen widget.
  const GolfScoreScreen({super.key});

  @override
  State<GolfScoreScreen> createState() => _GolfScoreScreenState();
}

class _GolfScoreScreenState extends State<GolfScoreScreen> {
  final GolfScoreModel _scoreModel =
      GolfScoreModel(playerNames: ['Player1', 'Player2', 'Player3', 'Player4']);

  @override
  void dispose() {
    super.dispose();
  }

  void _addPlayer() {
    setState(() {
      _scoreModel.addPlayer('Player ${_scoreModel.playerNames.length + 1}');
    });
  }

  void _clearScores() {
    setState(() {
      _scoreModel.clearScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<int> ranks = _scoreModel.getPlayerRanks();
    const double columnWidth = 80;
    return Screen(
      title: '9 Cards Golf Scorekeeper',
      version: '1.0.0',
      isWaiting: false,
      onRefresh: confirmNewGame,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
        child: Column(
          children: [
            // Player Name Edit Boxes
            // Score Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 1,
                horizontalMargin: 0,
                columns: [
                  for (int i = 0; i < _scoreModel.playerNames.length; i++)
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth, // Adjust width as needed
                        child: TextField(
                          controller: TextEditingController(
                              text: _scoreModel.playerNames[i]),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            fillColor: _getScoreColor(
                                    ranks[i], _scoreModel.playerNames.length)
                                .withAlpha(100),
                            contentPadding: EdgeInsets.all(8.0),
                          ),
                          onChanged: (newName) {
                            _scoreModel.playerNames[i] = newName;
                          },
                        ),
                      ),
                    ),
                  DataColumn(
                    label: IconButton(
                        onPressed: _addPlayer, icon: Icon(Icons.add)),
                  ),
                ],
                rows: [
                  for (int i = 0; i < _scoreModel.scores.length; i++)
                    DataRow(cells: [
                      for (int j = 0; j < _scoreModel.playerNames.length; j++)
                        DataCell(
                          SizedBox(
                            width: columnWidth,
                            child: TextFormField(
                              key: Key(
                                  '$i,$j ${_scoreModel.scores[i][j].toString()}'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                signed: true,
                                decimal: false,
                              ),
                              initialValue: _scoreModel.scores[i][j].toString(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                fillColor: Colors.black,
                              ),
                              onChanged: (value) {
                                final int? parsedValue = int.tryParse(value);
                                if (parsedValue != null) {
                                  setState(() {
                                    _scoreModel.updateScore(
                                      i,
                                      j,
                                      parsedValue,
                                    );
                                    if (!_scoreModel.isLastRoundEmpty()) {
                                      _scoreModel.addRound();
                                    }
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null ||
                                    int.tryParse(value) == null) {
                                  return ''; // Invalid
                                }
                                return null; // Valid
                              },
                            ),
                          ),
                        ),
                      DataCell(
                        (i == 0)
                            ? Text('')
                            : IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  confirmDeleteRound(i);
                                },
                              ),
                      ),
                    ]),

                  // Total Row
                  DataRow(
                    cells: [
                      for (int j = 0; j < _scoreModel.playerNames.length; j++)
                        DataCell(
                          Container(
                            color: Colors.black38,
                            width: columnWidth,
                            child: Text(
                              _scoreModel.getPlayerTotalScore(j).toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: _getScoreColor(ranks[j],
                                      _scoreModel.playerNames.length)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      const DataCell(SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a round.
  Future<void> confirmDeleteRound(int i) async {
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
        _scoreModel.removeRoundAt(i);
      });
    }
  }

  /// Shows a confirmation dialog before deleting a round.
  Future<void> confirmNewGame() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Game'),
        content: Text(
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
        _clearScores();
      });
    }
  }

  Color _getScoreColor(int rank, int numberOfPlayers) {
    if (rank == 1) {
      return Colors.green;
    } else if (rank == numberOfPlayers) {
      return Colors.pink;
    } else {
      return Colors.orange;
    }
  }
}
