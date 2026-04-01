import 'dart:async';

import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/screens/game/start_game_screen.dart';
import 'package:cards/screens/game/table_name_flow_helpers.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/edit_box.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:flutter/material.dart';

/// Dedicated create-table step that only handles table-name input/validation.
class CreateTableNameScreen extends StatefulWidget {
  ///
  const CreateTableNameScreen({required this.gameStyle, super.key});

  final GameStyles gameStyle;

  @override
  State<CreateTableNameScreen> createState() => _CreateTableNameScreenState();
}

class _CreateTableNameScreenState extends State<CreateTableNameScreen> {
  /// Controller for the table-name field.
  final TextEditingController _controllerTableName = TextEditingController();

  /// Whether the currently checked table name already exists.
  bool _doesTableNameExist = false;

  /// Last table name that was checked.
  String _lastCheckedTableName = '';

  /// Debounces backend checks while typing.
  Timer? _lookupDebounce;

  /// Whether a lookup is currently running.
  bool _lookupInProgress = false;

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    _controllerTableName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool isLookupReady =
        tableName.isNotEmpty &&
        _lastCheckedTableName == tableName &&
        !_lookupInProgress;
    final bool showJoinShortcut = isLookupReady && _doesTableNameExist;
    final bool canContinue = isLookupReady && !_doesTableNameExist;

    return Screen(
      isWaiting: false,
      title: localizations.createNewTable,
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(ConstLayout.paddingM),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ConstLayout.startGameScreenMaxWidth,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(ConstLayout.paddingS),
                    child: Text(
                      localizations.enterTableName,
                      style: TextStyle(
                        fontSize: ConstLayout.textS,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: ConstLayout.sizeM),
                  EditBox(
                    label: localizations.table,
                    controller: _controllerTableName,
                    onSubmitted: () {
                      _controllerTableName.text = _controllerTableName.text
                          .toUpperCase();
                      if (tableName.isEmpty) {
                        return;
                      }
                      _lookupTableName(tableName);
                    },
                    onChanged: (String _) {
                      _onTableNameChanged();
                    },
                    errorStatus: '',
                    rightSideChild: const SizedBox.shrink(),
                  ),
                  if (tableName.isNotEmpty && _lookupInProgress)
                    const Padding(
                      padding: EdgeInsets.all(ConstLayout.paddingS),
                      child: SizedBox(
                        width: ConstLayout.sizeXXL,
                        height: ConstLayout.sizeXXL,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (showJoinShortcut)
                    Padding(
                      padding: const EdgeInsets.all(ConstLayout.paddingS),
                      child: Text(
                        localizations.thisTableAlreadyHasPlayers,
                        style: TextStyle(
                          fontSize: ConstLayout.textS,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (showJoinShortcut)
                    MyButtonRectangle(
                      width: double.infinity,
                      onTap: () {
                        openJoinFlowForTable(
                          context: context,
                          tableName: tableName,
                          gameStyle: widget.gameStyle,
                        );
                      },
                      child: Text(
                        localizations.joinThisTable,
                        style: TextStyle(
                          fontSize: ConstLayout.textS,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  if (showJoinShortcut)
                    Padding(
                      padding: const EdgeInsets.all(ConstLayout.paddingS),
                      child: Text(
                        localizations.enterTableName,
                        style: TextStyle(
                          fontSize: ConstLayout.textS,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: ConstLayout.sizeS),
                  MyButtonRectangle(
                    width: double.infinity,
                    onTap: canContinue ? _continueToCreateTable : null,
                    child: Text(
                      localizations.next,
                      style: TextStyle(
                        fontSize: ConstLayout.textM,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Normalized table name.
  String get tableName => _controllerTableName.text.trim().toUpperCase();

  /// Continues to player setup once table name is confirmed unique.
  void _continueToCreateTable() {
    final bool canProceed =
        tableName.isNotEmpty &&
        _lastCheckedTableName == tableName &&
        !_doesTableNameExist &&
        !_lookupInProgress;
    if (!canProceed) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext _) => StartScreen(
          joinMode: false,
          initialGameStyle: widget.gameStyle,
          createRoomFlow: true,
          skipCreateTableNameStep: true,
          initialCreateRoomName: tableName,
        ),
      ),
    );
  }

  /// Looks up whether [tableToCheck] already exists.
  Future<void> _lookupTableName(String tableToCheck) async {
    final String normalizedTableName = tableToCheck.trim().toUpperCase();
    if (normalizedTableName.isEmpty) {
      return;
    }

    try {
      final TableNameLookupResult lookup = await lookupTableNameAvailability(
        normalizedTableName,
      );
      if (!mounted || tableName != normalizedTableName) {
        return;
      }
      setState(() {
        _lastCheckedTableName = normalizedTableName;
        _doesTableNameExist = lookup.exists;
        _lookupInProgress = false;
      });
    } catch (error) {
      logger.e(
        'Error validating create-table name $normalizedTableName: $error',
      );
      if (!mounted || tableName != normalizedTableName) {
        return;
      }
      setState(() {
        _lastCheckedTableName = normalizedTableName;
        _doesTableNameExist = false;
        _lookupInProgress = false;
      });
    }
  }

  /// Debounces table-name validation while user types.
  void _onTableNameChanged() {
    _lookupDebounce?.cancel();

    if (tableName.isEmpty) {
      setState(() {
        _lastCheckedTableName = '';
        _doesTableNameExist = false;
        _lookupInProgress = false;
      });
      return;
    }

    setState(() {
      _lastCheckedTableName = tableName;
      _doesTableNameExist = false;
      _lookupInProgress = true;
    });

    _lookupDebounce = Timer(
      const Duration(milliseconds: ConstLayout.animationDuration300),
      () {
        _lookupTableName(tableName);
      },
    );
  }
}
