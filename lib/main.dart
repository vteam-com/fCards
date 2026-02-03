import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/app/firebase_options.dart';
import 'package:cards/screens/game/join_game_screen.dart';
import 'package:cards/screens/game/start_game_screen.dart';
import 'package:cards/screens/keepscore/golf_score_screen.dart';
import 'package:cards/screens/welcome/main_menu.dart';
import 'package:cards/models/app/app_theme.dart';
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
    final baseTheme = AppTheme.theme;
    final colorScheme = baseTheme.colorScheme;
    final onSurface = colorScheme.onSurface;
    final surfaceBackground = colorScheme.surface;
    final onSurfaceHint = onSurface.withAlpha(100);

    return MaterialApp(
      title: 'Cards',
      theme: baseTheme.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: surfaceBackground,
        cardColor: surfaceBackground,
        textTheme: baseTheme.textTheme.apply(
          fontFamily: 'Roboto',
          bodyColor: onSurface,
          displayColor: onSurface,
        ),
        hintColor: onSurfaceHint,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: onSurface.withAlpha(100),
          hintStyle: TextStyle(color: onSurfaceHint),
          labelStyle: TextStyle(color: onSurface),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.primary.withAlpha(100),
              width: ConstLayout.enabledBorderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.secondary,
              width: ConstLayout.focusedBorderWidth,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: surfaceBackground,
            foregroundColor: onSurface,
            padding: const EdgeInsets.symmetric(
              horizontal: ConstLayout.buttonHorizontalPadding,
              vertical: ConstLayout.buttonVerticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ConstLayout.borderRadius),
              side: BorderSide(
                color: colorScheme.primary.withAlpha(100),
                width: ConstLayout.enabledBorderWidth,
              ),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: onSurface,
            padding: const EdgeInsets.symmetric(
              horizontal: ConstLayout.buttonHorizontalPadding,
              vertical: ConstLayout.buttonVerticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ConstLayout.borderRadius),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceBackground,
          titleTextStyle: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: onSurface),
        ),
        iconTheme: IconThemeData(color: onSurface),
        primaryIconTheme: IconThemeData(color: onSurface),
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
