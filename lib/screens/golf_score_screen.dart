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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  // Empty space for the "Round" column
                  const SizedBox(width: 100), // Adjust width as needed
                  for (int i = 0; i < _scoreModel.playerNames.length; i++)
                    SizedBox(
                      width: 100, // Adjust width as needed
                      child: TextField(
                        controller: TextEditingController(
                            text: _scoreModel.playerNames[i]),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                        onChanged: (newName) {},
                      ),
                    ),
                  IconButton(
                      onPressed: _addPlayer, icon: const Icon(Icons.add)),
                ],
              ),
            ),
            const SizedBox(
                height: 16.0), // Space between player names and table
            // Score Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('Round')),
                  for (int i = 0; i < _scoreModel.playerNames.length; i++)
                    const DataColumn(
                        label:
                            Text('')), // Empty label for player score columns
                ],
                rows: [
                  for (int i = 0; i < _scoreModel.scores.length; i++)
                    DataRow(cells: [
                      DataCell(
                        Row(
                          children: [
                            Text('${i + 1}'),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _scoreModel.removeRoundAt(i);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      for (int j = 0; j < _scoreModel.playerNames.length; j++)
                        DataCell(
                          TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue: _scoreModel.scores[i][j].toString(),
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
                    ]),
                  // Total Row
                  DataRow(cells: [
                    const DataCell(Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                    for (int j = 0; j < _scoreModel.playerNames.length; j++)
                      DataCell(
                        Text(
                          _scoreModel.getPlayerTotalScore(j).toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                          textAlign: TextAlign.end,
                        ),
                      ),
                  ]),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _addRound,
              child: const Text('Add Round'),
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
}
