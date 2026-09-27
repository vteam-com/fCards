import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/table_rename_result.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:flutter/material.dart';

/// Asks for a new table name, saves it with [rename], and reports conflicts.
///
/// Returns the saved name, or null when cancelled or rejected.
Future<String?> renameTableWithFeedback({
  required BuildContext context,
  required String currentName,
  required Future<TableRenameResult> Function(String) rename,
}) async {
  final AppLocalizations localizations = AppLocalizations.of(context);
  final String? name = await showDialog<String>(
    context: context,
    builder: (BuildContext _) => RenameTableDialog(currentName: currentName),
  );
  if (name == null || !context.mounted) {
    return null;
  }
  final TableRenameResult result = await rename(name);
  if (!context.mounted) {
    return null;
  }
  if (result == TableRenameResult.taken) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(localizations.tableNameTaken)));
    return null;
  }
  return result == TableRenameResult.renamed ? name.trim().toUpperCase() : null;
}

/// Text field dialog for renaming a table; pops the entered name.
class RenameTableDialog extends StatefulWidget {
  /// Creates the rename dialog prefilled with [currentName].
  const RenameTableDialog({super.key, required this.currentName});

  /// Name shown when the dialog opens.
  final String currentName;

  @override
  State<RenameTableDialog> createState() => _RenameTableDialogState();
}

class _RenameTableDialogState extends State<RenameTableDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.currentName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(localizations.tableRename, textAlign: TextAlign.center),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: ConstLayout.paddingM),
        decoration: BoxDecoration(
          color: AppTheme.panelInputZone,
          borderRadius: BorderRadius.circular(ConstLayout.radiusM),
        ),
        child: TextField(
          key: const Key('table.rename.field'),
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          onSubmitted: (_) => _submit(),
          style: const TextStyle(
            fontSize: ConstLayout.textM,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: localizations.table,
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
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
          child: Text(localizations.save),
        ),
      ],
    );
  }

  void _submit() {
    final String name = _controller.text.trim();
    if (name.isNotEmpty) {
      Navigator.of(context).pop(name);
    }
  }
}
