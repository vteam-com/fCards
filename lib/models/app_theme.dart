import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    final textTheme = baseTheme.textTheme;

    return baseTheme.copyWith(
      textTheme: textTheme.copyWith(
        // Display styles
        displayLarge: textTheme.displayLarge?.copyWith(fontSize: 57),
        displayMedium: textTheme.displayMedium?.copyWith(fontSize: 45),
        displaySmall: textTheme.displaySmall?.copyWith(fontSize: 36),

        // Headline styles
        headlineLarge: textTheme.headlineLarge?.copyWith(fontSize: 32),
        headlineMedium: textTheme.headlineMedium?.copyWith(fontSize: 28),
        headlineSmall: textTheme.headlineSmall?.copyWith(fontSize: 24),

        // Title styles
        titleLarge: textTheme.titleLarge?.copyWith(fontSize: 22),
        titleMedium: textTheme.titleMedium?.copyWith(fontSize: 16),
        titleSmall: textTheme.titleSmall?.copyWith(fontSize: 14),

        // Body styles
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 16),
        bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 14),
        bodySmall: textTheme.bodySmall?.copyWith(fontSize: 12),

        // Label styles
        labelLarge: textTheme.labelLarge?.copyWith(fontSize: 14),
        labelMedium: textTheme.labelMedium?.copyWith(fontSize: 12),
        labelSmall: textTheme.labelSmall?.copyWith(fontSize: 10),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    final textTheme = baseTheme.textTheme;

    return baseTheme.copyWith(
      textTheme: textTheme.copyWith(
        // Display styles
        displayLarge: textTheme.displayLarge?.copyWith(fontSize: 57),
        displayMedium: textTheme.displayMedium?.copyWith(fontSize: 45),
        displaySmall: textTheme.displaySmall?.copyWith(fontSize: 36),

        // Headline styles
        headlineLarge: textTheme.headlineLarge?.copyWith(fontSize: 32),
        headlineMedium: textTheme.headlineMedium?.copyWith(fontSize: 28),
        headlineSmall: textTheme.headlineSmall?.copyWith(fontSize: 24),

        // Title styles
        titleLarge: textTheme.titleLarge?.copyWith(fontSize: 22),
        titleMedium: textTheme.titleMedium?.copyWith(fontSize: 16),
        titleSmall: textTheme.titleSmall?.copyWith(fontSize: 14),

        // Body styles
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 16),
        bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 14),
        bodySmall: textTheme.bodySmall?.copyWith(fontSize: 12),

        // Label styles
        labelLarge: textTheme.labelLarge?.copyWith(fontSize: 14),
        labelMedium: textTheme.labelMedium?.copyWith(fontSize: 12),
        labelSmall: textTheme.labelSmall?.copyWith(fontSize: 10),
      ),
    );
  }
}
