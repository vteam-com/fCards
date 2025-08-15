import 'package:cards/screens/golf_score_screen.dart';
import 'package:cards/screens/start_screen.dart';
import 'package:flutter/material.dart';

/// The entry point of the application.
///
/// This function initializes the Flutter binding and then runs the `MyApp` widget,
/// which is the root of the application's widget tree.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

/// The root widget of the application.
///
/// Sets up the application's theme and navigates to the [StartScreen].
class MyApp extends StatelessWidget {
  /// Constructs a new instance of the `MyApp` widget.
  ///
  /// The `super.key` parameter is passed to the parent class constructor.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.green[800],
        cardColor: Colors.green[800],
        fontFamilyFallback: const ['Roboto'],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
        hintColor: Colors.white70,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withAlpha(100),
          hintStyle: TextStyle(color: Colors.white70),
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.green.withAlpha(100), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow, width: 4.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          // Add TextButtonThemeData
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, // Text color
            textStyle: const TextStyle(fontSize: 16), // Text style
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
          backgroundColor: const Color.fromARGB(255, 32, 41, 33),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        primaryIconTheme: const IconThemeData(color: Colors.white),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartScreen(),
        '/score': (context) => const GolfScoreScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
