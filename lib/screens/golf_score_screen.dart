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
      GolfScoreModel(playerNames: ['Rabit', 'Monkey', 'Lion', 'Zebra']);

  @override
  void dispose() {
    super.dispose();
  }

  void _addPlayer() {
    // Add player to the score model
    _scoreModel.playerNames.add('Player${_scoreModel.playerNames.length + 1}');
    setState(() {});
  }

  void _addRound() {
    setState(() {
      _scoreModel.addRound();
    });
  }

  void _clearAll() {
    setState(() {
      _scoreModel.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: '9 Cards Golf Scorekeeper',
      version: '1.0.0', // Placeholder version
      isWaiting: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 20,
          children: [
            // Player Name Edit Boxes
            // Score Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: ElevatedButton(
                        onPressed: _addPlayer, child: const Text('Add player')),
                  ),
                  for (int i = 0; i < _scoreModel.playerNames.length; i++)
                    DataColumn(
                      label: SizedBox(
                        width: 100, // Adjust width as needed
                        child: TextField(
                          controller: TextEditingController(
                              text: _scoreModel.playerNames[i]),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            fillColor: Colors.black,
                            contentPadding: EdgeInsets.all(8.0),
                          ),
                          onChanged: (newName) {},
                        ),
                      ),
                    ),
                ],
                rows: [
                  for (int i = 0; i < _scoreModel.scores.length; i++)
                    DataRow(cells: [
                      DataCell(
                        Row(
                          children: [
                            Text('${i + 1}'),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.deepOrangeAccent.withAlpha(200),
                              ),
                              onPressed: () {
                                confirmDeleteRound(i);
                              },
                            ),
                          ],
                        ),
                      ),
                      for (int j = 0; j < _scoreModel.playerNames.length; j++)
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
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
                    ]),
                  // Total Row
                  DataRow(cells: [
                    DataCell(
                      ElevatedButton(
                        onPressed: _addRound,
                        child: const Text('Add Round'),
                      ),
                    ),
                    for (int j = 0; j < _scoreModel.playerNames.length; j++)
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(
                            _scoreModel.getPlayerTotalScore(j).toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                  ]),
                ],
              ),
            ),
            Spacer(),
            // Add Round Button
            ElevatedButton(
              onPressed: _clearAll,
              child: const Text('Clear All'),
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
}
