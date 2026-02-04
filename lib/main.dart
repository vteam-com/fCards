import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/firebase_options.dart';
import 'package:cards/screens/game/join_game_screen.dart';
import 'package:cards/screens/game/start_game_screen.dart';
import 'package:cards/screens/keepscore/golf_score_screen.dart';
import 'package:cards/screens/welcome/main_menu.dart';
import 'package:cards/models/app/app_theme.dart';
import 'package:cards/utils/logger.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:the_splash/the_splash.dart';

/// The entry point of the application.
///
/// This function initializes the Flutter binding and then runs the `MyApp` widget,
/// which is the root of the application's widget tree.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SplashScreenData.preload();

  // Initialize Firebase for the entire app (if not offline)
  if (!isRunningOffLine) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await AuthService.ensureSignedIn();
      backendReady = true;
      logger.i('Firebase initialized successfully');
    } catch (e) {
      backendReady = false;
      logger.e('Firebase initialization error', e);
    }
  }

  runApp(const MyApp());
}

/// The root widget of the application.
///
/// Sets up the application's theme and navigates to the [StartScreen].
class MyApp extends StatelessWidget {
  /// Constructs a new instance of `MyApp` widget.
  ///
  /// The `super.key` parameter is passed to the parent class constructor.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards',
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainMenu(),
        '/game': (context) => const StartScreen(joinMode: false),
        '/join': (context) => const JoinGameScreen(),
        '/score': (context) => const GolfScoreScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
