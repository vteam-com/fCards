import 'package:cards/models/app/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    LocaleController.locale.value = null;
  });

  test('setLocaleTag preserves region-specific locales', () {
    LocaleController.setLocaleTag('pt-PT');

    expect(LocaleController.locale.value, isNotNull);
    expect(LocaleController.locale.value!.languageCode, 'pt');
    expect(LocaleController.locale.value!.countryCode, 'PT');
  });

  test('localeTagFor includes the country code when present', () {
    const Locale locale = Locale.fromSubtags(
      languageCode: 'pt',
      countryCode: 'PT',
    );

    expect(LocaleController.localeTagFor(locale), 'pt-PT');
  });
}
