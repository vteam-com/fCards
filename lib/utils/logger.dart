import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'dart:io';

// Logger configuration constants
const int loggerMethodCount = 2;
const int loggerErrorMethodCount = 8;
const int loggerLineLength = 120;

/// Custom silent printer for tests
class SilentPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    return []; // Return empty list to silence all output
  }
}

/// Global logger instance for the entire application
final AppLogger logger = AppLogger();

/// Structured logging utility for the Cards application
///
/// Provides different log levels (debug, info, warning, error) with
/// proper formatting, timestamps, and stack traces when needed.
/// Automatically adjusts log level based on debug/release mode.
/// Silences output during tests to avoid cluttering test results.
class AppLogger {
  late final Logger _instance;

  AppLogger() {
    _instance = Logger(
      printer: kDebugMode && !_isRunningTests()
          ? PrettyPrinter(
              methodCount: loggerMethodCount,
              errorMethodCount: loggerErrorMethodCount,
              lineLength: loggerLineLength,
              colors: true,
              printEmojis: true,
              dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
            )
          : SilentPrinter(),
      level: kDebugMode ? Level.debug : Level.info,
      filter: ProductionFilter(),
    );
  }

  /// Check if we're running in test mode
  bool _isRunningTests() {
    // Check for Flutter test environment variable
    final flutterTest = const String.fromEnvironment('FLUTTER_TEST');
    if (flutterTest.isNotEmpty) return true;

    // Check platform environment variable
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return true;
    } catch (e) {
      // Platform not available (web), continue
    }

    // Default to false for regular app usage
    return false;
  }

  /// Log debug message - only shown in debug builds
  void d(String message, [Object? error, StackTrace? stackTrace]) {
    _instance.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info message - shown in all builds
  void i(String message, [Object? error, StackTrace? stackTrace]) {
    _instance.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message - shown in all builds
  void w(String message, [Object? error, StackTrace? stackTrace]) {
    _instance.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message - shown in all builds
  void e(String message, [Object? error, StackTrace? stackTrace]) {
    _instance.e(message, error: error, stackTrace: stackTrace);
  }
}
