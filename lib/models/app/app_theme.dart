import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    final textTheme = baseTheme.textTheme;

    return baseTheme.copyWith(
      textTheme: textTheme.copyWith(
        // Display styles
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: Constants.displayLargeSize,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontSize: Constants.displayMediumSize,
        ),
        displaySmall: textTheme.displaySmall?.copyWith(
          fontSize: Constants.displaySmallSize,
        ),

        // Headline styles
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: Constants.headlineLargeSize,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: Constants.headlineMediumSize,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: Constants.headlineSmallSize,
        ),

        // Title styles
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: Constants.titleLargeSize,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: Constants.titleMediumSize,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          fontSize: Constants.titleSmallSize,
        ),

        // Body styles
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: Constants.bodyLargeSize,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: Constants.bodyMediumSize,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: Constants.bodySmallSize,
        ),

        // Label styles
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: Constants.labelLargeSize,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontSize: Constants.labelMediumSize,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: Constants.labelSmallSize,
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
          fontSize: Constants.displayLargeSize,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontSize: Constants.displayMediumSize,
        ),
        displaySmall: textTheme.displaySmall?.copyWith(
          fontSize: Constants.displaySmallSize,
        ),

        // Headline styles
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: Constants.headlineLargeSize,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: Constants.headlineMediumSize,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: Constants.headlineSmallSize,
        ),

        // Title styles
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: Constants.titleLargeSize,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: Constants.titleMediumSize,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          fontSize: Constants.titleSmallSize,
        ),

        // Body styles
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: Constants.bodyLargeSize,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: Constants.bodyMediumSize,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: Constants.bodySmallSize,
        ),

        // Label styles
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: Constants.labelLargeSize,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontSize: Constants.labelMediumSize,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: Constants.labelSmallSize,
        ),
      ),
    );
  }
}
