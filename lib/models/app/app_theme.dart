import 'package:cards/models/app/constants_layout.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    const seedColor = Color.fromARGB(255, 63, 244, 75);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ).copyWith(secondary: Colors.yellow);
    final textColor = Colors.yellow;
    final baseTheme = ThemeData.dark();
    final textTheme = baseTheme.textTheme;

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: ConstLayout.textXL,
          color: textColor,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontSize: ConstLayout.textL,
          color: textColor,
        ),
        displaySmall: textTheme.displaySmall?.copyWith(
          fontSize: ConstLayout.textL,
          color: textColor,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: ConstLayout.textL,
          color: textColor,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: ConstLayout.textM,
          color: textColor,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: ConstLayout.textM,
          color: textColor,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: ConstLayout.textM,
          color: textColor,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: ConstLayout.textS,
          color: textColor,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          fontSize: ConstLayout.textS,
          color: textColor,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: ConstLayout.textS,
          color: textColor,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: ConstLayout.textS,
          color: textColor,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: ConstLayout.textXS,
          color: textColor,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: ConstLayout.textS,
          color: textColor,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontSize: ConstLayout.textXS,
          color: textColor,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: ConstLayout.textXS,
          color: textColor,
        ),
      ),
    );
  }
}
