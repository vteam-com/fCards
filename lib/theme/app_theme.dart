import 'package:flutter/material.dart';
import 'package:cards/utils/font_scale_helper.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    final textTheme = baseTheme.textTheme;

    return baseTheme.copyWith(
      textTheme: textTheme.copyWith(
        // Display styles
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(57),
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(45),
        ),
        displaySmall: textTheme.displaySmall?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(36),
        ),

        // Headline styles
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(32),
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(28),
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(24),
        ),

        // Title styles
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(22),
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(16),
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(14),
        ),

        // Body styles
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(16),
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(14),
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(12),
        ),

        // Label styles
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(14),
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(12),
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(10),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    final textTheme = baseTheme.textTheme;

    return baseTheme.copyWith(
      textTheme: textTheme.copyWith(
        // Display styles
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(57),
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(45),
        ),
        displaySmall: textTheme.displaySmall?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(36),
        ),

        // Headline styles
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(32),
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(28),
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(24),
        ),

        // Title styles
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(22),
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(16),
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(14),
        ),

        // Body styles
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(16),
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(14),
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(12),
        ),

        // Label styles
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(14),
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(12),
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: FontScaleHelper.getScaledFontSize(10),
        ),
      ),
    );
  }
}
