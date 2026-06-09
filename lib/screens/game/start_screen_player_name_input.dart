import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/edit_box.dart';
import 'package:flutter/material.dart';

/// Player name input section.
class StartScreenPlayerNameInput extends StatelessWidget {
  /// Creates a [StartScreenPlayerNameInput].
  const StartScreenPlayerNameInput({
    required this.controller,
    required this.onSubmitted,
    required this.onAddTap,
    this.errorStatus = '',
    super.key,
  });

  /// Text editing controller for the input.
  final TextEditingController controller;

  /// Optional error message.
  final String errorStatus;

  /// Callback for the add button.
  final VoidCallback onAddTap;

  /// Callback for submitting the field.
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(ConstLayout.paddingS),
          child: Text(l10n.whoAreYou),
        ),
        const SizedBox(height: ConstLayout.sizeS),
        EditBox(
          label: l10n.join,
          controller: controller,
          onSubmitted: onSubmitted,
          errorStatus: errorStatus,
          rightSideChild: IconButton(
            onPressed: onAddTap,
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
