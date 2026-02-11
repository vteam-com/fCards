import 'package:cards/models/app/constants_layout.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const seedColor = Color.fromARGB(255, 25, 111, 31);
  static const panelInputZone = Color.fromARGB(200, 0, 59, 0);
  static final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );

  static final onSurface = colorScheme.onSurface;
  static final surfaceBackground = colorScheme.surface;
  static final onSurfaceHint = onSurface.withAlpha(ConstLayout.alphaH);

  static ThemeData get theme {
    final baseTheme = ThemeData.dark();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ).copyWith(secondary: Colors.yellow, tertiary: Colors.teal.shade300);

    final baseTextTheme = baseTheme.textTheme;
    final sizedTextTheme = baseTextTheme
        .copyWith(
          displayLarge: baseTextTheme.displayLarge?.copyWith(
            fontSize: ConstLayout.textXL,
            color: onSurface,
          ),
          displayMedium: baseTextTheme.displayMedium?.copyWith(
            fontSize: ConstLayout.textL,
            color: onSurface,
          ),
          displaySmall: baseTextTheme.displaySmall?.copyWith(
            fontSize: ConstLayout.textL,
            color: onSurface,
          ),
          headlineLarge: baseTextTheme.headlineLarge?.copyWith(
            fontSize: ConstLayout.textL,
            color: onSurface,
          ),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            fontSize: ConstLayout.textM,
            color: onSurface,
          ),
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            fontSize: ConstLayout.textM,
            color: onSurface,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontSize: ConstLayout.textM,
            color: onSurface,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            fontSize: ConstLayout.textS,
            color: onSurface,
          ),
          titleSmall: baseTextTheme.titleSmall?.copyWith(
            fontSize: ConstLayout.textS,
            color: onSurface,
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
            fontSize: ConstLayout.textS,
            color: onSurface,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            fontSize: ConstLayout.textS,
            color: onSurface,
          ),
          bodySmall: baseTextTheme.bodySmall?.copyWith(
            fontSize: ConstLayout.textXS,
            color: onSurface,
          ),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            fontSize: ConstLayout.textS,
            color: onSurface,
          ),
          labelMedium: baseTextTheme.labelMedium?.copyWith(
            fontSize: ConstLayout.textXS,
            color: onSurface,
          ),
          labelSmall: baseTextTheme.labelSmall?.copyWith(
            fontSize: ConstLayout.textXS,
            color: onSurface,
          ),
        )
        .apply(
          fontFamily: 'GameFont',
          bodyColor: onSurface,
          displayColor: onSurface,
        );

    return baseTheme.copyWith(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceBackground,
      cardColor: surfaceBackground,
      textTheme: sizedTextTheme,
      hintColor: onSurfaceHint,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.secondary,
        selectionColor: colorScheme.secondary.withAlpha(ConstLayout.alphaM),
        selectionHandleColor: colorScheme.secondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: onSurface.withAlpha(ConstLayout.alphaH),
        hintStyle: TextStyle(color: onSurfaceHint),
        labelStyle: TextStyle(color: onSurface),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.primary.withAlpha(ConstLayout.alphaM),
            width: ConstLayout.strokeXS,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.secondary,
            width: ConstLayout.strokeM,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ConstLayout.sizeM,
          vertical: ConstLayout.sizeS,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceBackground,
          foregroundColor: onSurface,
          padding: const EdgeInsets.symmetric(
            horizontal: ConstLayout.paddingXL,
            vertical: ConstLayout.paddingL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ConstLayout.radiusM),
            side: BorderSide(
              color: colorScheme.primary.withAlpha(ConstLayout.alphaH),
              width: ConstLayout.strokeXS,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: onSurface,
          padding: const EdgeInsets.symmetric(
            horizontal: ConstLayout.paddingXL,
            vertical: ConstLayout.paddingL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ConstLayout.radiusM),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceBackground,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      iconTheme: IconThemeData(color: onSurface),
      primaryIconTheme: IconThemeData(color: onSurface),
    );
  }
}
