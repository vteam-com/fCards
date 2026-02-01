import 'package:cards/models/backend_model.dart';
import 'package:cards/models/firebase_options.dart';
import 'package:cards/screens/game/join_game_screen.dart';
import 'package:cards/screens/game/start_game_screen.dart';
import 'package:cards/screens/keepscore/golf_score_screen.dart';
import 'package:cards/screens/main_menu.dart';
import 'package:cards/models/app_theme.dart';
import 'package:cards/models/constants.dart';

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
        scaffoldBackgroundColor: Constants.appBackgroundColor,
        cardColor: Constants.cardColor,
        textTheme: AppTheme.darkTheme.textTheme
            .apply(fontFamily: 'Roboto')
            .copyWith(
              bodyMedium: TextStyle(color: Constants.textColor),
              bodyLarge: TextStyle(color: Constants.textColor),
              displayLarge: TextStyle(color: Constants.textColor),
              displayMedium: TextStyle(color: Constants.textColor),
              displaySmall: TextStyle(color: Constants.textColor),
              headlineLarge: TextStyle(color: Constants.textColor),
              headlineMedium: TextStyle(color: Constants.textColor),
              headlineSmall: TextStyle(color: Constants.textColor),
              titleLarge: TextStyle(color: Constants.textColor),
              titleMedium: TextStyle(color: Constants.textColor),
              titleSmall: TextStyle(color: Constants.textColor),
              labelLarge: TextStyle(color: Constants.textColor),
              labelMedium: TextStyle(color: Constants.textColor),
              labelSmall: TextStyle(color: Constants.textColor),
            ),
        hintColor: Constants.hintTextColor,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Constants.textColor.withAlpha(Constants.alpha100),
          hintStyle: TextStyle(color: Constants.hintTextColor),
          labelStyle: TextStyle(color: Constants.textColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Constants.greenWithAlpha100,
              width: Constants.enabledBorderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Constants.yellowColor,
              width: Constants.focusedBorderWidth,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.appBackgroundColor,
            foregroundColor: Constants.textColor,
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.buttonHorizontalPadding,
              vertical: Constants.buttonVerticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.borderRadius),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          // Add TextButtonThemeData
          style: TextButton.styleFrom(
            foregroundColor: Constants.textColor, // Text color
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.buttonHorizontalPadding,
              vertical: Constants.buttonVerticalPadding,
            ), //padding
            shape: RoundedRectangleBorder(
              // Rounded corners
              borderRadius: BorderRadius.circular(Constants.borderRadius),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Constants.appBackgroundColor,
          titleTextStyle: TextStyle(
            color: Constants.textColor,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Constants.textColor),
        ),
        iconTheme: IconThemeData(color: Constants.textColor),
        primaryIconTheme: IconThemeData(color: Constants.textColor),
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
