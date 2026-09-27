import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/table_service.dart';
import 'package:cards/screens/tables/lobby_screen.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/edit_box.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/tables/table_summary.dart';
import 'package:flutter/material.dart';

/// Finds a virtual-card table to join, by its name or among the open ones.
class JoinTableScreen extends StatefulWidget {
  /// Creates the join screen.
  const JoinTableScreen({super.key});

  @override
  State<JoinTableScreen> createState() => _JoinTableScreenState();
}

class _JoinTableScreenState extends State<JoinTableScreen> {
  late Future<List<GameLobby>> _openLobbies;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _openLobbies = TableService.recentLobbies(cards: CardMedium.virtual);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Screen(
      isWaiting: false,
      title: localizations.joinGameTitle,
      onRefresh: () => setState(
        () => _openLobbies = TableService.recentLobbies(
          cards: CardMedium.virtual,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ConstLayout.paddingM),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ConstLayout.mainMenuMaxWidth,
            ),
            child: Column(
              spacing: ConstLayout.sizeM,
              children: [
                Text(
                  localizations.selectTableToJoin,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ConstLayout.textL,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                EditBox(
                  label: localizations.findTableByName,
                  controller: _searchController,
                  onSubmitted: _search,
                  errorStatus: '',
                  rightSideChild: IconButton(
                    onPressed: _search,
                    icon: const Icon(Icons.search),
                  ),
                ),
                FutureBuilder<List<GameLobby>>(
                  future: _openLobbies,
                  builder:
                      (BuildContext _, AsyncSnapshot<List<GameLobby>> snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const CircularProgressIndicator();
                        }
                        final List<GameLobby> lobbies =
                            snap.data ?? <GameLobby>[];
                        if (lobbies.isEmpty) {
                          return Text(
                            localizations.noOpenTables,
                            style: const TextStyle(fontSize: ConstLayout.textS),
                          );
                        }
                        return Column(
                          spacing: ConstLayout.sizeS,
                          children: [
                            for (final GameLobby lobby in lobbies)
                              MyButtonRectangle.menu(
                                key: Key('joinTable.lobby.${lobby.id}'),
                                icon: Icons.table_restaurant,
                                label: lobby.name,
                                subLabel: gameTypeLabel(
                                  lobby.gameType,
                                  localizations,
                                ),
                                onTap: () => _open(lobby),
                              ),
                          ],
                        );
                      },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _open(GameLobby lobby) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/lobby', arguments: lobby.id),
        builder: (BuildContext _) => LobbyScreen(lobbyId: lobby.id),
      ),
    );
  }

  /// Opens the most recent lobby with the typed name.
  Future<void> _search() async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final String name = _searchController.text;
    if (name.trim().isEmpty) return;
    final List<GameLobby> found = await TableService.findLobbies(
      name,
      cards: CardMedium.virtual,
    );
    if (!mounted) return;
    if (found.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.tableNotFound)));
      return;
    }
    _open(found.first);
  }
}
