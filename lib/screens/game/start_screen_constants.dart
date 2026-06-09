import 'package:cards/models/app/constants_layout.dart';

/// Constants specific to the StartScreen UI and logic.
class StartScreenConstants {
  /// Offline demo default room name.
  static const String offlineDemoDefaultRoomName = 'KIWI';

  /// Offline demo room name for testing.
  static const String offlineDemoRoomName = 'BANANA';

  /// Offline demo player names.
  static const String offlineDemoPlayerBob = 'BOB';
  static const String offlineDemoPlayerJohn = 'JOHN';
  static const String offlineDemoPlayerSue = 'SUE';

  /// Set of all offline demo players.
  static const Set<String> offlineDemoPlayers = {
    offlineDemoPlayerBob,
    offlineDemoPlayerSue,
    offlineDemoPlayerJohn,
  };

  /// Debounce duration for room lookup in milliseconds.
  static const Duration roomLookupDebounce = Duration(
    milliseconds: ConstLayout.animationDuration300,
  );

  /// Default table name when checking availability.
  static const String defaultTableNameCheckValue = '';
}
