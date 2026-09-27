import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/game/game_styles.dart';

const String _summarySeparator = ' · ';
const String _playerSeparator = ', ';

/// Localized name of a game type.
String gameTypeLabel(GameStyles gameType, AppLocalizations localizations) {
  switch (gameType) {
    case GameStyles.frenchCards9:
      return localizations.golf9Cards;
    case GameStyles.skyjo:
      return localizations.skyjo;
  }
}

/// One-line description of a table, such as `Skyjo · BOB, SUE`.
String tableSummary(
  GameStyles gameType,
  List<String> players,
  AppLocalizations localizations,
) => players.isEmpty
    ? gameTypeLabel(gameType, localizations)
    : '${gameTypeLabel(gameType, localizations)}'
          '$_summarySeparator${players.join(_playerSeparator)}';
