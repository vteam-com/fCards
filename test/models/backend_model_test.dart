import 'package:cards/models/firebase_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'BackEndModel',
    () {
      test('mock backend', () {
        DefaultFirebaseOptions.currentPlatform;
        DefaultFirebaseOptions.web;
        DefaultFirebaseOptions.ios;
        DefaultFirebaseOptions.macos;
        DefaultFirebaseOptions.windows;
      });
    },
  );
}
