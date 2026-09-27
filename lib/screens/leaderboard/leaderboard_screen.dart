import 'dart:ui';

import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/constants_animation.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/game_result.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/models/game/leaderboard_entry.dart';
import 'package:cards/models/game/leaderboard_service.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/app_bottom_sheet.dart';
import 'package:cards/widgets/helpers/player_avatar.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:flutter/material.dart';

/// Layout values for the leaderboard screen (Fibonacci).
class LeaderboardScreenConstants {
  /// Widest the board grows on tablets and desktop.
  static const double maxWidth = 610.0;

  /// Height of the scope and style toggle buttons.
  static const double toggleHeight = 34.0;

  /// Width of one style filter button.
  static const double styleButtonWidth = 144.0;

  /// Width reserved for the rank or medal column.
  static const double rankWidth = 34.0;

  /// Avatar radius on each row.
  static const double avatarRadius = 21.0;

  /// Width reserved for the wins column.
  static const double winsWidth = 55.0;

  /// Multiplier turning a 0–1 rate into a percentage.
  static const int percentScale = 100;

  /// Decimals shown for an average score.
  static const int averageDecimals = 1;

  /// Characters of a name used for avatar initials.
  static const int initialsLength = 2;

  /// Rows that get a medal instead of a number.
  static const List<String> medals = <String>['🥇', '🥈', '🥉'];
}

enum _LeaderboardScope { global, tables }

/// Ranks players by games played, won, and scored.
///
/// Opens on the global board, or on [initialTableKey]'s board when given
/// (for example, from the room a game was just played in).
class LeaderboardScreen extends StatefulWidget {
  /// Creates the leaderboard screen.
  const LeaderboardScreen({super.key, this.initialTableKey});

  /// Table to show first; opens the global board when null.
  final String? initialTableKey;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> _entries;
  late _LeaderboardScope _scope;
  String _style = allStylesKey;
  static const List<String> _styles = <String>[
    allStylesKey,
    'frenchCards9',
    'skyjo',
    'miniPut',
    scoreKeeperStyleKey,
    'custom',
  ];
  String? _tableKey;
  List<LeaderboardTable> _tables = <LeaderboardTable>[];
  @override
  void initState() {
    super.initState();
    _tableKey = widget.initialTableKey;
    _scope = _tableKey == null
        ? _LeaderboardScope.global
        : _LeaderboardScope.tables;
    _entries = _load();
    _loadTables();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Screen(
      title: localizations.leaderboard,
      isWaiting: false,
      onRefresh: _refresh,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LeaderboardScreenConstants.maxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(ConstLayout.paddingL),
            child: Column(
              spacing: ConstLayout.sizeM,
              children: [
                _buildScopeToggle(localizations),
                _buildStyleFilter(localizations),
                if (_scope == _LeaderboardScope.tables && _tables.isNotEmpty)
                  _buildTablePicker(localizations),
                Expanded(child: _buildBoard(localizations)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the ranked list, or a message while empty or unavailable.
  Widget _buildBoard(AppLocalizations localizations) {
    if (_scope == _LeaderboardScope.tables && _tableKey == null) {
      return _buildMessage(localizations.leaderboardNoTables);
    }
    return FutureBuilder<List<LeaderboardEntry>>(
      future: _entries,
      builder: (BuildContext _, AsyncSnapshot<List<LeaderboardEntry>> snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<LeaderboardEntry> entries =
            snap.data ?? <LeaderboardEntry>[];
        if (entries.isEmpty) {
          return _buildMessage(localizations.leaderboardEmpty);
        }
        return ListView.separated(
          itemCount: entries.length,
          separatorBuilder: (BuildContext _, int _) =>
              const SizedBox(height: ConstLayout.sizeS),
          itemBuilder: (BuildContext _, int index) =>
              _buildRow(entries[index], index, localizations),
        );
      },
    );
  }

  /// Builds a centered empty-state message.
  Widget _buildMessage(String message) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: ConstLayout.textM),
      ),
    );
  }

  /// Builds one glass row: medal or rank, avatar, name, stats, and wins.
  ///
  /// The signed-in player's row is outlined in the primary color.
  Widget _buildRow(
    LeaderboardEntry entry,
    int index,
    AppLocalizations localizations,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isMe = entry.playerKey == _uid && _uid.isNotEmpty;
    final List<String> medals = LeaderboardScreenConstants.medals;
    return ClipRRect(
      borderRadius: BorderRadius.circular(ConstLayout.radiusM),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: ConstAnimation.blurSigma,
          sigmaY: ConstAnimation.blurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withAlpha(ConstLayout.alphaM),
            borderRadius: BorderRadius.circular(ConstLayout.radiusM),
            border: Border.all(
              color: isMe
                  ? colorScheme.primary
                  : Colors.white.withValues(
                      alpha: ConstAnimation.borderOpacity,
                    ),
              width: isMe ? ConstLayout.strokeS : ConstLayout.strokeXS,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ConstLayout.paddingM),
            child: Row(
              spacing: ConstLayout.sizeM,
              children: [
                SizedBox(
                  width: LeaderboardScreenConstants.rankWidth,
                  child: Text(
                    index < medals.length ? medals[index] : '${index + 1}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: ConstLayout.textM,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PlayerAvatar(
                  radius: LeaderboardScreenConstants.avatarRadius,
                  photoUrl: entry.avatarUrl,
                  initials: _initials(entry.name),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: ConstLayout.sizeXS,
                    children: [
                      Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: ConstLayout.textM,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _statsLine(entry, localizations),
                        style: TextStyle(
                          fontSize: ConstLayout.textS,
                          color: colorScheme.onSurface.withAlpha(
                            ConstLayout.alphaL,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: LeaderboardScreenConstants.winsWidth,
                  child: Column(
                    children: [
                      Text(
                        '${entry.wins}',
                        style: TextStyle(
                          fontSize: ConstLayout.textL,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        localizations.leaderboardWins,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: ConstLayout.textS),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the Global / My Tables switch.
  Widget _buildScopeToggle(AppLocalizations localizations) {
    return Row(
      spacing: ConstLayout.sizeS,
      children: [
        Expanded(
          child: _buildToggle(
            label: localizations.leaderboardGlobal,
            icon: Icons.public,
            selected: _scope == _LeaderboardScope.global,
            onTap: () => _update(() => _scope = _LeaderboardScope.global),
          ),
        ),
        Expanded(
          child: _buildToggle(
            label: localizations.leaderboardTables,
            icon: Icons.table_restaurant,
            selected: _scope == _LeaderboardScope.tables,
            onTap: () => _update(() => _scope = _LeaderboardScope.tables),
          ),
        ),
      ],
    );
  }

  /// Builds the horizontally scrolling game-style filter.
  Widget _buildStyleFilter(AppLocalizations localizations) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: ConstLayout.sizeS,
        children: _styles
            .map(
              (String style) => _buildToggle(
                label: _styleLabel(style, localizations),
                width: LeaderboardScreenConstants.styleButtonWidth,
                selected: _style == style,
                onTap: () => _update(() => _style = style),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Builds the button showing the selected table, which opens the picker.
  Widget _buildTablePicker(AppLocalizations localizations) {
    final LeaderboardTable? selected = _tables
        .where((LeaderboardTable table) => table.key == _tableKey)
        .firstOrNull;
    return MyButtonRectangle.menu(
      icon: Icons.table_restaurant,
      label: selected?.name ?? localizations.leaderboardChooseTable,
      subLabel: selected == null ? null : localizations.leaderboardChooseTable,
      onTap: () => _chooseTable(localizations),
    );
  }

  /// Builds a toggle button that is primary while [selected].
  Widget _buildToggle({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    double width = double.infinity,
    IconData? icon,
  }) {
    final Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: ConstLayout.sizeS,
      children: [
        if (icon != null) Icon(icon, size: ConstLayout.iconXS),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ConstLayout.textS,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
    return selected
        ? MyButtonRectangle.primary(
            width: width,
            height: LeaderboardScreenConstants.toggleHeight,
            onTap: onTap,
            child: child,
          )
        : MyButtonRectangle.secondary(
            width: width,
            height: LeaderboardScreenConstants.toggleHeight,
            onTap: onTap,
            child: child,
          );
  }

  /// Lets the player pick one of their tables from a bottom sheet.
  Future<void> _chooseTable(AppLocalizations localizations) async {
    final String? tableKey = await showAppBottomSheet<String>(
      context: context,
      builder: (BuildContext sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.all(ConstLayout.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: ConstLayout.sizeM,
          children: [
            Text(
              localizations.leaderboardChooseTable,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: ConstLayout.textL,
                fontWeight: FontWeight.bold,
              ),
            ),
            ..._tables.map(
              (LeaderboardTable table) => MyButtonRectangle.menu(
                icon: table.key == _tableKey
                    ? Icons.check_circle
                    : Icons.table_restaurant,
                label: table.name,
                subLabel: MaterialLocalizations.of(
                  sheetContext,
                ).formatMediumDate(table.lastPlayed),
                onTap: () => Navigator.of(sheetContext).pop(table.key),
              ),
            ),
          ],
        ),
      ),
    );
    if (tableKey != null && mounted) {
      _update(() => _tableKey = tableKey);
    }
  }

  /// Returns up to two leading characters of [name] for the avatar.
  String _initials(String name) {
    final String trimmed = name.trim().toUpperCase();
    return trimmed.length <= LeaderboardScreenConstants.initialsLength
        ? trimmed
        : trimmed.substring(0, LeaderboardScreenConstants.initialsLength);
  }

  /// Loads the board for the current scope, style, and table.
  Future<List<LeaderboardEntry>> _load() {
    if (_scope == _LeaderboardScope.global) {
      return LeaderboardService.globalLeaderboard(_style);
    }
    final String? tableKey = _tableKey;
    if (tableKey == null) {
      return Future<List<LeaderboardEntry>>.value(<LeaderboardEntry>[]);
    }
    return LeaderboardService.tableLeaderboard(tableKey, style: _style);
  }

  /// Loads the player's tables and selects the latest when none is chosen.
  Future<void> _loadTables() async {
    final List<LeaderboardTable> tables =
        await LeaderboardService.tablesForPlayer(_uid);
    if (!mounted) {
      return;
    }
    setState(() {
      _tables = tables;
      if (_tableKey == null && tables.isNotEmpty) {
        _tableKey = tables.first.key;
        if (_scope == _LeaderboardScope.tables) {
          _entries = _load();
        }
      }
    });
  }

  /// Reloads the board and the table list.
  void _refresh() {
    setState(() => _entries = _load());
    _loadTables();
  }

  /// Played and win rate always; best and average only within one style,
  /// since scores from different games are not comparable.
  String _statsLine(LeaderboardEntry entry, AppLocalizations localizations) {
    final List<String> parts = <String>[
      localizations.leaderboardGamesPlayed(entry.gamesPlayed),
      localizations.leaderboardWinRate(
        (entry.winRate * LeaderboardScreenConstants.percentScale).round(),
      ),
    ];
    final int? best = entry.bestScore;
    final double? average = entry.averageScore;
    if (_style != allStylesKey && best != null && average != null) {
      parts
        ..add(localizations.leaderboardBest(best))
        ..add(
          localizations.leaderboardAverage(
            average.toStringAsFixed(LeaderboardScreenConstants.averageDecimals),
          ),
        );
    }
    return parts.join(' · ');
  }

  /// Returns the localized filter label for a leaderboard [style] key.
  String _styleLabel(String style, AppLocalizations localizations) {
    if (style == allStylesKey) return localizations.leaderboardAllGames;
    if (style == scoreKeeperStyleKey) {
      return localizations.leaderboardScoreKeeper;
    }
    if (style == GameStyles.frenchCards9.name) return localizations.golf9Cards;
    if (style == GameStyles.skyjo.name) return localizations.skyjo;
    if (style == GameStyles.miniPut.name) return localizations.miniPut;
    return localizations.leaderboardCustom;
  }

  String get _uid => AuthService.currentUser?.uid ?? '';

  /// Applies a filter [change] and reloads the board.
  void _update(VoidCallback change) {
    setState(() {
      change();
      _entries = _load();
    });
  }
}
