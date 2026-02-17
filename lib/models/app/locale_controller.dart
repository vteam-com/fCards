import 'package:flutter/material.dart';

/// Centralized locale state for runtime language switching.
class LocaleController {
  LocaleController._();

  /// Null means: follow platform locale resolution.
  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  /// Sets an explicit app locale from a language code (for example: en, fr).
  static void setLanguageCode(String languageCode) {
    locale.value = Locale(languageCode);
  }
}
