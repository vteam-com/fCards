import 'package:flutter/foundation.dart';

/// Logs a debug message if the app is running in debug mode.
///
/// The [text] parameter specifies the message to be logged.
void debugLog(final String text) {
  if (kDebugMode) {
    print(text);
  }
}
