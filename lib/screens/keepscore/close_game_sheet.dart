import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/app_bottom_sheet.dart';
import 'package:cards/widgets/helpers/dialog.dart';
import 'package:flutter/material.dart';

/// Opacity of the Close Game button until a winner is picked.
const double _disabledOpacity = 0.5;

/// Asks the host to confirm closing the game and returns the winner's index.
///
/// Shows the final standings. When [leaders] (the players tied for the lowest
/// total) holds more than one index, the host must tap the single winner
/// before closing. Returns null when the host cancels.
Future<int?> showCloseGameSheet({
  required BuildContext context,
  required List<String> names,
  required List<int> totals,
  required List<int> leaders,
}) {
  return showAppBottomSheet<int>(
    context: context,
    builder: (BuildContext _) =>
        CloseGameSheet(names: names, totals: totals, leaders: leaders),
  );
}

/// Confirms, to every player at the table, that the game was closed.
void showGameClosedDialog(BuildContext context, String winnerName) {
  final AppLocalizations localizations = AppLocalizations.of(context);
  myDialog(
    context: context,
    title: localizations.gameClosed,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: ConstLayout.sizeM,
      children: [
        Icon(
          Icons.emoji_events,
          size: ConstLayout.iconL,
          color: Theme.of(context).colorScheme.primary,
        ),
        Text(
          localizations.gameClosedWinner(winnerName),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: ConstLayout.textL,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

/// Final standings with a confirm step; pops the chosen winner's index.
class CloseGameSheet extends StatefulWidget {
  /// Creates the close-game confirmation.
  const CloseGameSheet({
    super.key,
    required this.names,
    required this.totals,
    required this.leaders,
  });

  /// Seat indexes tied for the lowest total.
  final List<int> leaders;

  /// Player names in seat order.
  final List<String> names;

  /// Final totals in seat order; lower is better.
  final List<int> totals;
  @override
  State<CloseGameSheet> createState() => _CloseGameSheetState();
}

class _CloseGameSheetState extends State<CloseGameSheet> {
  int? _winner;
  @override
  void initState() {
    super.initState();
    if (widget.leaders.length == 1) {
      _winner = widget.leaders.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool isTie = widget.leaders.length > 1;
    final List<int> standings =
        List<int>.generate(widget.names.length, (int index) => index)..sort(
          (int a, int b) => widget.totals[a] != widget.totals[b]
              ? widget.totals[a].compareTo(widget.totals[b])
              : a.compareTo(b),
        );
    final int? winner = _winner;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ConstLayout.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: ConstLayout.sizeM,
        children: [
          Text(
            localizations.closeGameTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: ConstLayout.textL,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            isTie
                ? localizations.closeGamePickWinner
                : localizations.closeGameHint,
            textAlign: TextAlign.center,
          ),
          ...standings.map(
            (int index) => _buildStanding(index, isTie && _isLeader(index)),
          ),
          Row(
            spacing: ConstLayout.sizeM,
            children: [
              Expanded(
                child: MyButtonRectangle.secondary(
                  width: double.infinity,
                  height: ConstLayout.dialogButtonHeight,
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(localizations.cancel),
                ),
              ),
              Expanded(
                child: Opacity(
                  opacity: winner == null ? _disabledOpacity : 1,
                  child: MyButtonRectangle.primary(
                    width: double.infinity,
                    height: ConstLayout.dialogButtonHeight,
                    onTap: winner == null
                        ? null
                        : () => Navigator.of(context).pop(winner),
                    child: Text(
                      localizations.closeGame,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds one standings row; tied leaders are buttons that pick the winner.
  Widget _buildStanding(int index, bool selectable) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isWinner = _winner == index;
    final Widget row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: ConstLayout.paddingL),
      child: Row(
        spacing: ConstLayout.sizeM,
        children: [
          SizedBox(
            width: ConstLayout.iconS,
            child: isWinner
                ? Icon(
                    Icons.emoji_events,
                    size: ConstLayout.iconS,
                    color: colorScheme.primary,
                  )
                : null,
          ),
          Expanded(
            child: Text(
              widget.names[index],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ConstLayout.textM,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${widget.totals[index]}',
            style: TextStyle(
              fontSize: ConstLayout.textM,
              fontWeight: FontWeight.bold,
              color: isWinner ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
    if (!selectable) {
      return row;
    }
    void pick() => setState(() => _winner = index);
    return isWinner
        ? MyButtonRectangle.primary(
            width: double.infinity,
            height: ConstLayout.dialogButtonHeight,
            onTap: pick,
            child: row,
          )
        : MyButtonRectangle.secondary(
            width: double.infinity,
            height: ConstLayout.dialogButtonHeight,
            onTap: pick,
            child: row,
          );
  }

  bool _isLeader(int index) => widget.leaders.contains(index);
}
