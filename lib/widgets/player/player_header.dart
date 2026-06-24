import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/input_keyboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Constants for player header widget dimensions and styling
class PlayerHeaderConstants {
  /// Height of the winning position display
  static const double winningPositionHeight = 24.0;

  /// Height of the score display
  static const double scoreHeight = 30.0;

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

  /// Height for input field and buttons (44 -> 55)
  static const double inputHeight = 55.0;

  /// Border radius for dialogs
  static const double dialogBorderRadius = 16.0;

  /// Border width for dialogs
  static const double dialogBorderWidth = 1.0;

  /// Maximum width for the edit player dialog.
  static const double editDialogMaxWidth = 800.0;

  /// Maximum width for text action buttons in edit dialogs.
  static const double textActionButtonMaxWidth = 300.0;

  /// Number of characters allowed in the player acronym editor.
  static const int playerAcronymLength = 2;

  /// Width and height for each OTP-style slot.
  static const double pinSlotSize = ConstLayout.sizeXXL;

  /// Test key for first initials slot.
  static const Key pinSlotOneKey = Key('playerInitials.slot1');

  /// Test key for second initials slot.
  static const Key pinSlotTwoKey = Key('playerInitials.slot2');

  /// Test key for hidden text field backing the initials slots.
  static const Key hiddenInitialsFieldKey = Key('playerInitials.hiddenField');
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
  int _activePinSlotIndex = 0;

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
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ConstLayout.textM,
            ),
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

  /// Closes the dialog after committing the current acronym value.
  void _acceptPlayerAcronym(
    BuildContext dialogContext,
    TextEditingController controller,
  ) {
    _commitPlayerAcronym(controller);
    Navigator.of(dialogContext).pop();
  }

  /// Builds responsive action buttons for the edit-player dialog.
  Widget _buildEditDialogActionButtons(AppLocalizations localizations) {
    final addPlayerButton = MyButtonRectangle.secondary(
      width: null,
      height: PlayerHeaderConstants.inputHeight,
      onTap: () {
        Navigator.of(context).pop();
        widget.onPlayerAdded?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ConstLayout.sizeM),
        child: Text(
          localizations.addAnotherPlayer,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    final removePlayerButton = MyButtonRectangle.danger(
      width: null,
      height: PlayerHeaderConstants.inputHeight,
      onTap: () {
        Navigator.of(context).pop();
        _showRemoveConfirmationDialog();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ConstLayout.sizeM),
        child: Text(
          localizations.removeThisPlayer,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Wrap(
      spacing: PlayerHeaderConstants.wrapSpacing,
      runSpacing: PlayerHeaderConstants.wrapSpacing,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PlayerHeaderConstants.textActionButtonMaxWidth,
          ),
          child: addPlayerButton,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PlayerHeaderConstants.textActionButtonMaxWidth,
          ),
          child: removePlayerButton,
        ),
      ],
    );
  }

  /// Builds one visual slot for the two-character OTP-style input.
  Widget _buildPinSlot({
    required String value,
    required bool isActive,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
    required Key slotKey,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        key: slotKey,
        duration: Duration(milliseconds: ConstLayout.animationDuration300),
        width: PlayerHeaderConstants.pinSlotSize,
        height: PlayerHeaderConstants.pinSlotSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(
            ConstLayout.alphaH,
          ),
          borderRadius: BorderRadius.circular(ConstLayout.radiusM),
          border: Border.all(
            color: isActive ? colorScheme.primary : colorScheme.outline,
            width: isActive ? ConstLayout.strokeS : ConstLayout.strokeXS,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ConstLayout.paddingS),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ConstLayout.textL,
                height: ConstLayout.strokeXS,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an OTP-style two-character input that supports hardware keyboard input.
  Widget _buildTwoCharacterPinInput({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required AppLocalizations localizations,
    required VoidCallback onAccepted,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TargetPlatform platform = Theme.of(context).platform;
    final bool isWebMobilePlatform =
        kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final bool disableSystemKeyboard =
        platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        isWebMobilePlatform;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(ConstLayout.paddingS),
          child: Text(localizations.playerName),
        ),
        const SizedBox(height: ConstLayout.sizeS),
        ListenableBuilder(
          listenable: Listenable.merge([controller, focusNode]),
          builder: (_, _) {
            final String value = _normalizePlayerAcronym(controller.text);
            final String firstChar = value.isNotEmpty ? value[0] : '';
            final String secondChar =
                value.length >= ConstLayout.negativeNumberMaxLength
                ? value[1]
                : '';
            final bool firstActive = _activePinSlotIndex == 0;
            final bool secondActive = _activePinSlotIndex == 1;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: ConstLayout.sizeM,
              children: [
                _buildPinSlot(
                  value: firstChar,
                  isActive: firstActive,
                  colorScheme: colorScheme,
                  onTap: () => _setActivePinSlot(controller, focusNode, 0),
                  slotKey: PlayerHeaderConstants.pinSlotOneKey,
                ),
                _buildPinSlot(
                  value: secondChar,
                  isActive: secondActive,
                  colorScheme: colorScheme,
                  onTap: () => _setActivePinSlot(controller, focusNode, 1),
                  slotKey: PlayerHeaderConstants.pinSlotTwoKey,
                ),
              ],
            );
          },
        ),
        SizedBox(
          width: ConstLayout.sizeXS,
          height: ConstLayout.sizeXS,
          child: Opacity(
            opacity: ConstLayout.sizeXS / ConstLayout.paddingM,
            child: Focus(
              onKeyEvent: (_, KeyEvent event) {
                if (event is! KeyDownEvent) {
                  return KeyEventResult.ignored;
                }

                if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  _setActivePinSlot(controller, focusNode, 0);
                  return KeyEventResult.handled;
                }

                if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  _setActivePinSlot(controller, focusNode, 1);
                  return KeyEventResult.handled;
                }

                if (event.logicalKey == LogicalKeyboardKey.backspace) {
                  _handleVirtualKeyPress(controller, keyBackspace);
                  return KeyEventResult.handled;
                }

                if (event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                  onAccepted();
                  return KeyEventResult.handled;
                }

                final String? char = event.character;
                if (char != null && RegExp(r'^[a-zA-Z0-9]$').hasMatch(char)) {
                  _handleVirtualKeyPress(controller, char);
                  return KeyEventResult.handled;
                }

                return KeyEventResult.ignored;
              },
              child: TextField(
                key: PlayerHeaderConstants.hiddenInitialsFieldKey,
                autofocus: true,
                focusNode: focusNode,
                controller: controller,
                readOnly: disableSystemKeyboard,
                showCursor: !disableSystemKeyboard,
                enableInteractiveSelection: !disableSystemKeyboard,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                maxLength: PlayerHeaderConstants.playerAcronymLength,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(
                    PlayerHeaderConstants.playerAcronymLength,
                  ),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  final String normalized = _normalizePlayerAcronym(value);
                  if (normalized != value) {
                    controller.value = TextEditingValue(
                      text: normalized,
                      selection: TextSelection.collapsed(
                        offset: normalized.length,
                      ),
                    );
                  }
                  _commitPlayerAcronym(controller);
                  _moveSelectionToSecondSlotAfterFirstChar(controller);
                },
                onSubmitted: (_) => onAccepted(),
              ),
            ),
          ),
        ),
        const SizedBox(height: ConstLayout.sizeM),
        InputKeyboard.alpha(
          onKeyPressed: (String key) {
            if (!focusNode.hasFocus) {
              focusNode.requestFocus();
            }
            _handleVirtualKeyPress(controller, key);
          },
        ),
      ],
    );
  }

  /// Builds the rank badge for first, last, or middle leaderboard positions.
  Widget _buildWiningPosition(int rank, int numberOfPlayers) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    if (rank == 1) {
      return Text('👑', style: TextStyle(fontWeight: FontWeight.w900));
    } else if (rank == numberOfPlayers) {
      return Opacity(
        opacity: PlayerHeaderConstants.lastPlaceOpacity,
        child: Text(
          localizations.last,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: ConstLayout.textS,
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
            fontSize: ConstLayout.textS,
          ),
        ),
      );
    }
  }

  /// Commits the current acronym value to the parent callback.
  void _commitPlayerAcronym(TextEditingController controller) {
    widget.onNameChanged(_normalizePlayerAcronym(controller.text));
  }

  /// Returns a score color based on player rank.
  Color _getScoreColor(int rank, int numberOfPlayers) {
    if (rank == 1) {
      return Colors.green.shade300;
    } else if (rank == numberOfPlayers) {
      return Colors.red.shade300;
    } else {
      return Colors.orange.shade300;
    }
  }

  /// Applies a virtual keyboard key press to the acronym input.
  void _handleVirtualKeyPress(TextEditingController controller, String key) {
    final String current = _normalizePlayerAcronym(controller.text);
    final TextSelection activeSelection = _selectionForPinSlot(
      current,
      _activePinSlotIndex,
    );
    final int baseOffset = activeSelection.baseOffset;
    final int extentOffset = activeSelection.extentOffset;

    final int selectionStart = baseOffset <= extentOffset
        ? baseOffset
        : extentOffset;
    final int selectionEnd = baseOffset <= extentOffset
        ? extentOffset
        : baseOffset;

    String next = current;
    int nextOffset = selectionStart;

    if (key == keyBackspace) {
      if (selectionStart != selectionEnd) {
        next = current.replaceRange(selectionStart, selectionEnd, '');
        nextOffset = selectionStart;
      } else if (selectionStart > 0) {
        next = current.replaceRange(selectionStart - 1, selectionStart, '');
        nextOffset = selectionStart - 1;
      }
    } else if (key != keySpace && key.length == 1) {
      final String char = key.toUpperCase();
      final String replaced = selectionStart == selectionEnd
          ? selectionStart < current.length
                ? current.replaceRange(selectionStart, selectionStart + 1, char)
                : current.replaceRange(selectionStart, selectionStart, char)
          : current.replaceRange(selectionStart, selectionEnd, char);
      next = _normalizePlayerAcronym(replaced);
      nextOffset = (selectionStart + 1).clamp(0, next.length);
    }

    if (next == current && nextOffset == baseOffset) {
      return;
    }

    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: nextOffset),
    );
    final int resolvedSlot = nextOffset <= 0 ? 0 : 1;
    if (_activePinSlotIndex != resolvedSlot) {
      setState(() {
        _activePinSlotIndex = resolvedSlot;
      });
    }
    _commitPlayerAcronym(controller);
    _moveSelectionToSecondSlotAfterFirstChar(controller);
  }

  /// Moves the active selection to slot two when only the first character exists.
  void _moveSelectionToSecondSlotAfterFirstChar(
    TextEditingController controller,
  ) {
    final String value = _normalizePlayerAcronym(controller.text);
    final int secondSlotOffset = PlayerHeaderConstants.playerAcronymLength - 1;
    if (value.length == secondSlotOffset &&
        controller.selection.baseOffset != secondSlotOffset) {
      controller.selection = _selectionForPinSlot(value, secondSlotOffset);
      if (_activePinSlotIndex != secondSlotOffset) {
        setState(() {
          _activePinSlotIndex = secondSlotOffset;
        });
      }
    }
  }

  /// Normalizes a player acronym to uppercase alphanumeric with max length 2.
  String _normalizePlayerAcronym(String value) {
    final String normalized = value.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    if (normalized.length <= PlayerHeaderConstants.playerAcronymLength) {
      return normalized;
    }
    return normalized.substring(0, PlayerHeaderConstants.playerAcronymLength);
  }

  /// Returns a selection targeting one slot; existing char is selected to overwrite.
  TextSelection _selectionForPinSlot(String currentValue, int slotIndex) {
    final int requestedStart = slotIndex.clamp(
      0,
      PlayerHeaderConstants.playerAcronymLength - 1,
    );
    final int start = requestedStart > currentValue.length
        ? currentValue.length
        : requestedStart;
    final int end = (start + 1) <= currentValue.length ? start + 1 : start;
    return TextSelection(baseOffset: start, extentOffset: end);
  }

  /// Sets the active input slot so the next key updates that position.
  void _setActivePinSlot(
    TextEditingController controller,
    FocusNode focusNode,
    int slotIndex,
  ) {
    final String currentValue = _normalizePlayerAcronym(controller.text);
    final TextSelection targetSelection = _selectionForPinSlot(
      currentValue,
      slotIndex,
    );

    if (_activePinSlotIndex != slotIndex) {
      setState(() {
        _activePinSlotIndex = slotIndex;
      });
    }
    focusNode.requestFocus();
    controller.selection = targetSelection;
  }

  /// Shows the dialog used to rename, add, or remove a player.
  void _showEditPlayerDialog() {
    setState(() {
      _activePinSlotIndex = 0;
    });

    final controller = TextEditingController(
      text: _normalizePlayerAcronym(widget.playerName),
    );
    controller.selection = const TextSelection.collapsed(offset: 0);
    final focusNode = FocusNode();
    final colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool isSmallScreen =
        MediaQuery.of(context).size.width < ConstLayout.breakpointPhone;
    showDialog(
      context: context,
      builder: (context) {
        final editContent = Column(
          mainAxisSize: MainAxisSize.min,
          spacing: PlayerHeaderConstants.dialogContentSpacing,
          children: [
            _buildTwoCharacterPinInput(
              context: context,
              controller: controller,
              focusNode: focusNode,
              localizations: localizations,
              onAccepted: () => _acceptPlayerAcronym(context, controller),
            ),
            _buildEditDialogActionButtons(localizations),
          ],
        );

        final themedContent = Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: colorScheme.primaryContainer,
            ),
          ),
          child: editContent,
        );

        if (isSmallScreen) {
          return Dialog.fullscreen(
            backgroundColor: colorScheme.surface,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: colorScheme.surface,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(ConstLayout.paddingL),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: PlayerHeaderConstants.dialogContentSpacing,
                    children: [
                      themedContent,
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth:
                                PlayerHeaderConstants.textActionButtonMaxWidth,
                          ),
                          child: MyButtonRectangle(
                            width: double.infinity,
                            height: PlayerHeaderConstants.inputHeight,
                            onTap: () =>
                                _acceptPlayerAcronym(context, controller),
                            child: Text(
                              localizations.done,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: colorScheme.primaryContainer,
            ),
          ),
          child: AlertDialog(
            constraints: const BoxConstraints(
              maxWidth: PlayerHeaderConstants.editDialogMaxWidth,
            ),
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
            content: SingleChildScrollView(child: editContent),
          ),
        );
      },
    ).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.dispose();
        focusNode.dispose();
      });
    });

    // On open, activate slot 1 so users can type two initials immediately.
    _setActivePinSlot(controller, focusNode, 0);
  }

  /// Shows a confirmation dialog before removing the current player.
  void _showRemoveConfirmationDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations localizations = AppLocalizations.of(context);
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
          title: Text(localizations.removePlayer),
          content: Text(
            localizations.removePlayerConfirmation(widget.playerName),
          ),
          actions: [
            MyButtonRectangle.secondary(
              width: ConstLayout.dialogButtonWidth,
              height: ConstLayout.dialogButtonHeight,
              onTap: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            MyButtonRectangle.danger(
              width: ConstLayout.dialogButtonWidth,
              height: ConstLayout.dialogButtonHeight,
              onTap: () {
                Navigator.of(context).pop();
                widget.onPlayerRemoved();
              },
              child: Text(localizations.remove),
            ),
          ],
        );
      },
    );
  }
}
