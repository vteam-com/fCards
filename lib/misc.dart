import 'package:flutter/foundation.dart';

void debugLog(final String text) {
  if (kDebugMode) {
    print(text);
  }
}
