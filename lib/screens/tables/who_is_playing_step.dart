import 'dart:async';

import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/identity_service.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/models/game/player_selection.dart';
import 'package:cards/models/game/score_session.dart';
import 'package:cards/models/game/score_session_service.dart';
import 'package:cards/models/game/score_session_state.dart';
import 'package:cards/models/game/table_service.dart';
import 'package:cards/widgets/helpers/edit_box.dart';
import 'package:cards/widgets/tables/player_pill.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Layout values for the who-is-playing step (Fibonacci).
class WhoIsPlayingConstants {
  /// QR code side, small enough to sit beside its caption on a phone.
  static const double qrSize = 144.0;
}

/// Physical-card step 2: gathers the players of a new score sheet.
///
/// Opens a shared sheet right away so its QR code can be scanned; players who
/// scan appear in the list live. The scorekeeper can also type names, which
/// become columns on the same sheet. Without a connection only typed names
/// are used. Reports every change through [onChanged].
class WhoIsPlayingStep extends StatefulWidget {
  /// Creates the step for [gameType].
  const WhoIsPlayingStep({
    super.key,
    required this.gameType,
    required this.onChanged,
  });

  /// Game about to be scored.
  final GameStyles gameType;

  /// Called with the players (and shared lobby) after every change.
  final ValueChanged<PlayerSelection> onChanged;

  @override
  State<WhoIsPlayingStep> createState() => _WhoIsPlayingStepState();
}

class _WhoIsPlayingStepState extends State<WhoIsPlayingStep> {
  GameLobby? _lobby;
  String _me = '';
  final TextEditingController _nameController = TextEditingController();
  bool _opening = true;
  List<String> _playerIds = <String>[];
  List<String> _players = <String>[];
  ScoreSession? _session;
  StreamSubscription<ScoreSessionState>? _stateSubscription;
  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: ConstLayout.sizeM,
      children: [
        Text(
          localizations.whoIsPlayingTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ConstLayout.textL,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        _buildInvite(localizations, colorScheme),
        Text(
          localizations.playerCount(_players.length),
          style: TextStyle(
            fontSize: ConstLayout.textS,
            fontWeight: FontWeight.bold,
            color: colorScheme.tertiary,
          ),
        ),
        Wrap(
          spacing: ConstLayout.sizeS,
          runSpacing: ConstLayout.sizeS,
          children: [
            for (int index = 0; index < _players.length; index++)
              PlayerPill(
                name: _players[index],
                highlighted: _players[index] == _me,
                onRemove: _players[index] == _me ? null : () => _remove(index),
              ),
          ],
        ),
        EditBox(
          key: const Key('startTable.playerField'),
          prefixIcon: const Icon(Icons.person_add),
          controller: _nameController,
          onSubmitted: _addTypedPlayers,
          errorStatus: '',
          showKeyboard: false,
          rightSideChild: IconButton(
            key: const Key('startTable.addPlayer'),
            tooltip: localizations.lobbyAddPlayer,
            onPressed: _addTypedPlayers,
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  /// Adds the comma-separated names typed in the field.
  void _addTypedPlayers() {
    final List<String> names = _nameController.text
        .toUpperCase()
        .split(',')
        .map((String name) => name.trim())
        .where((String name) => name.isNotEmpty && !_players.contains(name))
        .toSet()
        .toList();
    _nameController.clear();
    if (names.isEmpty) return;
    final ScoreSession? session = _session;
    if (session != null) {
      for (final String name in names) {
        unawaited(ScoreSessionService.addManualPlayer(session.id, name));
      }
      return;
    }
    setState(() => _players = <String>[..._players, ...names]);
    _report();
  }

  /// QR code beside its caption; a spinner while the shared sheet opens, and
  /// just the typing hint when it could not be opened.
  Widget _buildInvite(AppLocalizations localizations, ColorScheme colorScheme) {
    final ScoreSession? session = _session;
    if (_opening) {
      return const Center(child: CircularProgressIndicator());
    }
    if (session == null) {
      return Text(
        localizations.whoIsPlayingHint,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: ConstLayout.textS,
          color: colorScheme.onSurface,
        ),
      );
    }
    return Row(
      spacing: ConstLayout.sizeM,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(ConstLayout.radiusS),
          child: QrImageView(
            key: const Key('startTable.qrCode'),
            data: session.inviteUrl,
            size: WhoIsPlayingConstants.qrSize,
            backgroundColor: Colors.white,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: ConstLayout.sizeXS,
            children: [
              Text(
                localizations.scanQrToJoin,
                style: TextStyle(
                  fontSize: ConstLayout.textM,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                localizations.tableLabel(session.tableName),
                style: TextStyle(
                  fontSize: ConstLayout.textS,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
              Text(
                localizations.whoIsPlayingQrHint,
                style: TextStyle(
                  fontSize: ConstLayout.textS,
                  color: colorScheme.onSurface.withAlpha(ConstLayout.alphaL),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Adds this player, then opens the shared sheet players can scan into.
  Future<void> _open() async {
    _me = (await IdentityService.resolveIdentityName() ?? '')
        .trim()
        .toUpperCase();
    if (!mounted) return;
    setState(() => _players = <String>[if (_me.isNotEmpty) _me]);
    _report();
    if (isRunningOffLine) {
      setState(() => _opening = false);
      return;
    }
    final GameLobby lobby = await TableService.openLobby(
      gameType: widget.gameType,
      cards: CardMedium.physical,
    );
    final ScoreSession? session = await ScoreSessionService.createSession(
      _me,
      lobby: lobby,
    );
    if (!mounted) return;
    setState(() {
      _opening = false;
      _session = session;
      _lobby = session == null ? null : lobby;
    });
    if (session == null) return;
    final List<String> typedBeforeOpen = _players
        .where((String player) => player != _me)
        .toList();
    for (final String player in typedBeforeOpen) {
      await ScoreSessionService.addManualPlayer(session.id, player);
    }
    _stateSubscription = ScoreSessionService.scoreState(session.id).listen((
      ScoreSessionState state,
    ) {
      if (!mounted) return;
      setState(() {
        _players = List<String>.from(state.playerNames);
        _playerIds = List<String>.from(state.playerIds);
      });
      _report();
    });
  }

  /// Removes the player at [index] from the list and the shared sheet.
  void _remove(int index) {
    final ScoreSession? session = _session;
    if (session != null && index < _playerIds.length) {
      unawaited(
        ScoreSessionService.removePlayerById(session.id, _playerIds[index]),
      );
      return;
    }
    setState(() => _players = <String>[..._players]..removeAt(index));
    _report();
  }

  void _report() => widget.onChanged(
    PlayerSelection(players: List<String>.from(_players), lobby: _lobby),
  );
}
