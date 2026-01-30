import 'package:cards/models/backend_model.dart';
import 'package:cards/models/firebase_options.dart';
import 'package:cards/screens/game/join_game_screen.dart';
import 'package:cards/screens/game/start_game_screen.dart';
import 'package:cards/screens/keepscore/golf_score_screen.dart';
import 'package:cards/screens/main_menu.dart';
import 'package:cards/models/app_theme.dart';

import 'package:firebase_auth/firebase_auth.dart';
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
      await FirebaseAuth.instance.signInAnonymously();
      backendReady = true;
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      backendReady = false;
      debugPrint('Firebase initialization error: $e');
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
      theme: AppTheme.darkTheme.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.green.shade900,
        cardColor: Colors.green.shade900,
        textTheme: AppTheme.darkTheme.textTheme
            .apply(fontFamily: 'Roboto')
            .copyWith(
              bodyMedium: const TextStyle(color: Colors.white),
              bodyLarge: const TextStyle(color: Colors.white),
              displayLarge: const TextStyle(color: Colors.white),
              displayMedium: const TextStyle(color: Colors.white),
              displaySmall: const TextStyle(color: Colors.white),
              headlineLarge: const TextStyle(color: Colors.white),
              headlineMedium: const TextStyle(color: Colors.white),
              headlineSmall: const TextStyle(color: Colors.white),
              titleLarge: const TextStyle(color: Colors.white),
              titleMedium: const TextStyle(color: Colors.white),
              titleSmall: const TextStyle(color: Colors.white),
              labelLarge: const TextStyle(color: Colors.white),
              labelMedium: const TextStyle(color: Colors.white),
              labelSmall: const TextStyle(color: Colors.white),
            ),
        hintColor: Colors.white70,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withAlpha(100),
          hintStyle: TextStyle(color: Colors.white70),
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green.withAlpha(100),
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow, width: 4.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade900,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          // Add TextButtonThemeData
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, // Text color
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ), //padding
            shape: RoundedRectangleBorder(
              // Rounded corners
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade900,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        primaryIconTheme: const IconThemeData(color: Colors.white),
      ),
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
