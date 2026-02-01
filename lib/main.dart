import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/app/firebase_options.dart';
import 'package:cards/screens/game/join_game_screen.dart';
import 'package:cards/screens/game/start_game_screen.dart';
import 'package:cards/screens/keepscore/golf_score_screen.dart';
import 'package:cards/screens/welcome/main_menu.dart';
import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants.dart';
import 'package:cards/utils/logger.dart';

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
      theme: AppTheme.darkTheme.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Constants.backgroundPrimary,
        cardColor: Constants.backgroundCard,
        textTheme: AppTheme.darkTheme.textTheme
            .apply(fontFamily: 'Roboto')
            .copyWith(
              bodyMedium: TextStyle(color: Constants.textPrimary),
              bodyLarge: TextStyle(color: Constants.textPrimary),
              displayLarge: TextStyle(color: Constants.textPrimary),
              displayMedium: TextStyle(color: Constants.textPrimary),
              displaySmall: TextStyle(color: Constants.textPrimary),
              headlineLarge: TextStyle(color: Constants.textPrimary),
              headlineMedium: TextStyle(color: Constants.textPrimary),
              headlineSmall: TextStyle(color: Constants.textPrimary),
              titleLarge: TextStyle(color: Constants.textPrimary),
              titleMedium: TextStyle(color: Constants.textPrimary),
              titleSmall: TextStyle(color: Constants.textPrimary),
              labelLarge: TextStyle(color: Constants.textPrimary),
              labelMedium: TextStyle(color: Constants.textPrimary),
              labelSmall: TextStyle(color: Constants.textPrimary),
            ),
        hintColor: Constants.textHint,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Constants.textPrimary.withAlpha(Constants.alpha100),
          hintStyle: TextStyle(color: Constants.textHint),
          labelStyle: TextStyle(color: Constants.textPrimary),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Constants.accentGreenAlpha,
              width: Constants.enabledBorderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Constants.accentYellow,
              width: Constants.focusedBorderWidth,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.backgroundPrimary,
            foregroundColor: Constants.textPrimary,
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
            foregroundColor: Constants.textPrimary, // Text color
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
          backgroundColor: Constants.backgroundPrimary,
          titleTextStyle: TextStyle(
            color: Constants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Constants.textPrimary),
        ),
        iconTheme: IconThemeData(color: Constants.textPrimary),
        primaryIconTheme: IconThemeData(color: Constants.textPrimary),
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
