import 'package:flutter/material.dart';

/// Centralized locale state for runtime language switching.
class LocaleController {
  LocaleController._();

  /// Null means: follow platform locale resolution.
  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  /// Returns a stable locale tag for settings and UI (for example: en, fr, pt-PT).
  static String localeTagFor(Locale locale) {
    final String? countryCode = locale.countryCode;
    if (countryCode == null || countryCode.isEmpty) {
      return locale.languageCode;
    }

    return '${locale.languageCode}-$countryCode';
  }

  /// Parses a locale tag used by the app (for example: en, fr, pt-PT).
  static Locale parseLocaleTag(String localeTag) {
    final List<String> parts = localeTag.split(RegExp(r'[-_]'));
    final String languageCode = parts.first;
    final String? countryCode = parts.length > 1
        ? parts[1].toUpperCase()
        : null;

    return Locale.fromSubtags(
      languageCode: languageCode,
      countryCode: countryCode,
    );
  }

  /// Sets an explicit app locale from a locale tag (for example: en, fr, pt-PT).
  static void setLocaleTag(String localeTag) {
    locale.value = parseLocaleTag(localeTag);
  }
}
