import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:flutter/material.dart';

/// Asks an in-person player for the table name of a shared score sheet.
///
/// Pops with the entered table name, or `null` when cancelled.
class JoinScoreSheetDialog extends StatefulWidget {
  ///
  const JoinScoreSheetDialog({super.key});

  @override
  State<JoinScoreSheetDialog> createState() => _JoinScoreSheetDialogState();
}

class _JoinScoreSheetDialogState extends State<JoinScoreSheetDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: ConstLayout.mainMenuMaxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.all(ConstLayout.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.joinScoreSheet,
                style: TextStyle(
                  fontSize: ConstLayout.textM,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ConstLayout.sizeM),
              Text(
                localizations.joinScoreSheetPrompt,
                style: TextStyle(
                  fontSize: ConstLayout.textS,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ConstLayout.sizeM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ConstLayout.paddingM,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.panelInputZone,
                  borderRadius: BorderRadius.circular(ConstLayout.radiusM),
                ),
                child: TextField(
                  key: const Key('welcome.joinScoreSheet.tableName'),
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  onSubmitted: (_) => _submit(),
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: ConstLayout.textM,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: localizations.table,
                  ),
                ),
              ),
              const SizedBox(height: ConstLayout.sizeL),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: ConstLayout.sizeM,
                children: [
                  MyButtonRectangle.secondary(
                    width: ConstLayout.dialogButtonWidth,
                    height: ConstLayout.dialogButtonHeight,
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(localizations.cancel),
                  ),
                  MyButtonRectangle.primary(
                    width: ConstLayout.dialogButtonWidth,
                    height: ConstLayout.dialogButtonHeight,
                    onTap: _submit,
                    child: Text(localizations.join),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final String tableName = _controller.text.trim();
    if (tableName.isEmpty) {
      return;
    }
    Navigator.of(context).pop(tableName);
  }
}
