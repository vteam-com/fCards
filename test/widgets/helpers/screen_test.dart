import 'package:cards/widgets/helpers/screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Screen.avatarFallbackText', () {
    test('returns trimmed display name when available', () {
      expect(
        Screen.avatarFallbackText(
          displayName: '  Jane Doe  ',
          email: 'player@example.com',
        ),
        'Jane Doe',
      );
    });

    test('falls back to trimmed email when display name is missing', () {
      expect(
        Screen.avatarFallbackText(
          displayName: null,
          email: '  player@example.com  ',
        ),
        'player@example.com',
      );
    });

    test('falls back to placeholder when display name and email are blank', () {
      expect(Screen.avatarFallbackText(displayName: '   ', email: '   '), '🤔');
    });
  });
}
