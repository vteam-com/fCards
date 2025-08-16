// ignore_for_file: require_trailing_commas

import 'package:cards/models/golf_score_model.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/editable_player_name.dart';
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
                    columnSpacing: 8,
                    horizontalMargin: 0,
                    columns: [
                      // Player Names
                      for (int i = 0; i < scoreModel.playerNames.length; i++)
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth, // Adjust width as needed
                            child: EditablePlayerName(
                              key: Key('$i${scoreModel.playerNames[i]}'),
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
                              SizedBox(
                                width: columnWidth,
                                child: TextFormField(
                                  key: Key(
                                      '$i,$j ${scoreModel.scores[i][j].toString()}'),
                                  // keyboardType:
                                  //     const TextInputType.numberWithOptions(
                                  //   signed: true,
                                  //   decimal: false,
                                  // ),
                                  initialValue:
                                      scoreModel.scores[i][j].toString(),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    fillColor: Colors.black,
                                  ),
                                  onChanged: (value) {
                                    final int? parsedValue =
                                        int.tryParse(value);
                                    if (parsedValue != null) {
                                      setState(() {
                                        scoreModel.updateScore(
                                          i,
                                          j,
                                          parsedValue,
                                        );
                                        if (!scoreModel.isLastRoundEmpty()) {
                                          scoreModel.addRound();
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
                                ? const Text('')
                                : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      confirmDeleteRound(i, scoreModel);
                                    },
                                  ),
                          ),
                        ]),

                      // Total Row
                      DataRow(
                        cells: [
                          for (int j = 0;
                              j < scoreModel.playerNames.length;
                              j++)
                            DataCell(
                              Container(
                                color: Colors.black38,
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
      return Colors.green;
    } else if (rank == numberOfPlayers) {
      return Colors.pink;
    } else {
      return Colors.orange;
    }
  }
}
