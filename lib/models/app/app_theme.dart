import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get theme {
    final baseTheme = ThemeData.dark();
    final textTheme = baseTheme.textTheme;
    final colorScheme = baseTheme.colorScheme.copyWith(
      primary: Constants.primaryGreen,
      surface: Constants.backgroundContainer,
    );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme.copyWith(
        // Display styles
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: Constants.textXL,
          color: Constants.textPrimary,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontSize: Constants.textL,
          color: Constants.textPrimary,
        ),
        displaySmall: textTheme.displaySmall?.copyWith(
          fontSize: Constants.textL,
          color: Constants.textPrimary,
        ),

        // Headline styles
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: Constants.textL,
          color: Constants.textPrimary,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: Constants.textM,
          color: Constants.textPrimary,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: Constants.textM,
          color: Constants.textPrimary,
        ),

        // Title styles
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: Constants.textM,
          color: Constants.textPrimary,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: Constants.textS,
          color: Constants.textPrimary,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          fontSize: Constants.textS,
          color: Constants.textPrimary,
        ),

        // Body styles
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: Constants.textS,
          color: Constants.textPrimary,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: Constants.textS,
          color: Constants.textPrimary,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: Constants.textXS,
          color: Constants.textPrimary,
        ),

        // Label styles
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: Constants.textS,
          color: Constants.textPrimary,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontSize: Constants.textXS,
          color: Constants.textPrimary,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: Constants.textXS,
          color: Constants.textPrimary,
        ),
      ),
    );
  }
}
