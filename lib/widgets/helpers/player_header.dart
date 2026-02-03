import 'package:cards/models/app/constants_layout.dart';
import 'package:flutter/material.dart';
import 'package:cards/widgets/helpers/edit_box.dart';

/// Constants for player header widget dimensions and styling
class PlayerHeaderConstants {
  /// Height of the winning position display
  static const double winningPositionHeight = 24.0;

  /// Height of the score display
  static const double scoreHeight = 30.0;

  /// Font size for rank text
  static const double rankFontSize = 14.0;

  /// Opacity for non-first place players
  static const double nonFirstPlaceOpacity = 0.7;

  /// Opacity for last place player
  static const double lastPlaceOpacity = 0.5;

  /// Shadow blur radius for score text
  static const double scoreShadowBlurRadius = 2.0;

  /// Shadow offset for score text
  static const double scoreShadowOffset = 1.0;

  /// Selection color alpha value
  static const int selectionColorAlpha = 150;

  /// Dialog animation delay in milliseconds
  static const int dialogAnimationDelay = 150;

  /// Spacing between column children
  static const double columnSpacing = 8.0;

  /// Spacing between dialog content elements
  static const double dialogContentSpacing = 16.0;

  /// Spacing between wrap children
  static const double wrapSpacing = 16.0;

  /// Border radius for dialogs
  static const double dialogBorderRadius = 16.0;

  /// Border width for dialogs
  static const double dialogBorderWidth = 1.0;
}

/// A widget for editing a player's name.
///
/// This widget displays the player's name. When the user taps on it, a dialog
/// appears to edit the name or remove the player.
class PlayerHeader extends StatefulWidget {
  /// Creates an [PlayerHeader] widget.
  const PlayerHeader({
    super.key,
    required this.playerName,
    required this.onNameChanged,
    required this.onPlayerRemoved,
    this.onPlayerAdded,
    this.playerIndex,
    required this.rank,
    required this.numberOfPlayers,
    required this.totalScore,
  });

  /// The total number of players.
  final int numberOfPlayers;

  /// A callback that is called when the player's name is changed.
  final void Function(String) onNameChanged;

  /// A callback that is called when a new player should be added.
  final void Function()? onPlayerAdded;

  /// A callback that is called when the player is removed.
  final void Function() onPlayerRemoved;

  /// The index of the player.
  final int? playerIndex;

  /// The name of the player.
  final String playerName;

  /// The rank of the player.
  final int rank;

  /// The total score of the player.
  final int totalScore;

  @override
  State<PlayerHeader> createState() => _PlayerHeaderState();
}

class _PlayerHeaderState extends State<PlayerHeader> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _getScoreColor(
          widget.rank,
          widget.numberOfPlayers,
        ).withAlpha(PlayerHeaderConstants.selectionColorAlpha),
      ),
      onPressed: _showEditPlayerDialog,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: PlayerHeaderConstants.columnSpacing,
        children: [
          //
          // Running place King,2,3,4,Last
          //
          SizedBox(
            height: PlayerHeaderConstants.winningPositionHeight,
            child: Center(
              child: _buildWiningPosition(widget.rank, widget.numberOfPlayers),
            ),
          ),

          //
          // Name of the Player
          //
          Text(
            widget.playerName,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
            style: TextStyle(fontSize: ConstLayout.textS),
          ),

          //
          // Score
          //
          SizedBox(
            height: PlayerHeaderConstants.scoreHeight,
            child: FittedBox(
              child: Text(
                widget.totalScore.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ConstLayout.textM,
                  // Make the score color brighter by blending with white
                  color: Color.alphaBlend(
                    colorScheme.onSurface,
                    _getScoreColor(widget.rank, widget.numberOfPlayers),
                  ),
                  shadows: <Shadow>[
                    const Shadow(
                      color: Colors.white54,
                      offset: Offset(
                        -PlayerHeaderConstants.scoreShadowOffset,
                        -PlayerHeaderConstants.scoreShadowOffset,
                      ),
                      blurRadius: PlayerHeaderConstants.scoreShadowBlurRadius,
                    ),
                    const Shadow(
                      color: Colors.black54,
                      offset: Offset(
                        PlayerHeaderConstants.scoreShadowOffset,
                        PlayerHeaderConstants.scoreShadowOffset,
                      ),
                      blurRadius: PlayerHeaderConstants.scoreShadowBlurRadius,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWiningPosition(int rank, int numberOfPlayers) {
    if (rank == 1) {
      return Text('👑', style: TextStyle(fontWeight: FontWeight.w900));
    } else if (rank == numberOfPlayers) {
      return Opacity(
        opacity: PlayerHeaderConstants.lastPlaceOpacity,
        child: Text(
          'LAST',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: PlayerHeaderConstants.rankFontSize,
          ),
        ),
      );
    } else {
      return Opacity(
        opacity: PlayerHeaderConstants.nonFirstPlaceOpacity,
        child: Text(
          '#$rank',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: PlayerHeaderConstants.rankFontSize,
          ),
        ),
      );
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

  void _showEditPlayerDialog() {
    final controller = TextEditingController(text: widget.playerName);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
    final focusNode = FocusNode();
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: colorScheme.primaryContainer,
            ),
          ),
          child: AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                PlayerHeaderConstants.dialogBorderRadius,
              ),
              side: BorderSide(
                color: colorScheme.primary,
                width: PlayerHeaderConstants.dialogBorderWidth,
              ),
            ),
            title: Text(
              widget.playerIndex != null
                  ? 'Name for Player #${widget.playerIndex! + 1}'
                  : 'Player Name',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: PlayerHeaderConstants.dialogContentSpacing,
              children: [
                EditBox(
                  label: 'Player Name',
                  controller: controller,
                  onSubmitted: () {},
                  errorStatus: '',
                  rightSideChild: null,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      widget.onNameChanged(controller.text);
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
                Divider(color: colorScheme.primary),
                Wrap(
                  spacing: PlayerHeaderConstants.wrapSpacing,
                  runSpacing: PlayerHeaderConstants.wrapSpacing,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onPlayerAdded?.call();
                      },
                      child: Text(
                        'Add another player',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showRemoveConfirmationDialog();
                      },
                      child: Text(
                        'Remove this player',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (mounted) {
      focusNode.requestFocus();
    }
    Future.delayed(
      Duration(milliseconds: PlayerHeaderConstants.dialogAnimationDelay),
      () {
        if (mounted) {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        }
      },
    );
  }

  void _showRemoveConfirmationDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              PlayerHeaderConstants.dialogBorderRadius,
            ),
            side: BorderSide(
              color: colorScheme.primaryContainer,
              width: PlayerHeaderConstants.dialogBorderWidth,
            ),
          ),
          title: const Text('Remove Player'),
          content: Text(
            'Are you sure you want to remove "${widget.playerName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onPlayerRemoved();
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
