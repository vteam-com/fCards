import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/firebase_options.dart';
import 'package:cards/models/app/locale_controller.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/screens/game/card_scan_screen.dart';
import 'package:cards/screens/game/corrections_review_screen.dart';
import 'package:cards/screens/game/join_game_screen.dart';
import 'package:cards/screens/game/start_game_screen.dart';
import 'package:cards/screens/game/start_game_wizard_screen.dart';
import 'package:cards/screens/keepscore/golf_score_screen.dart';
import 'package:cards/screens/welcome/welcome_screen.dart';
import 'package:cards/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:the_splash/the_splash.dart';

const int _firebaseInitTimeoutSeconds = 30;

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
      // Add a timeout for Firebase initialization.
      // If it times out or fails on macOS, fall back to offline mode
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: _firebaseInitTimeoutSeconds));
      await AuthService.ensureSignedIn();
      backendReady = true;
      logger.i('Firebase initialized successfully');
    } catch (e) {
      backendReady = false;
      isRunningOffLine = true;
      logger.w(
        'Firebase initialization failed - falling back to offline mode: $e',
      );
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
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.locale,
      builder: (BuildContext _, Locale? locale, Widget? _) {
        return MaterialApp(
          locale: locale,
          onGenerateTitle: (BuildContext context) {
            return AppLocalizations.of(context).cardsTitle;
          },
          theme: AppTheme.theme,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/',
          routes: {
            '/': (BuildContext _) => const WelcomeScreen(),
            '/scan': (BuildContext _) => const CardScanScreen(),
            '/start': (BuildContext _) => const StartGameWizardScreen(),
            '/game': (BuildContext _) => const StartScreen(joinMode: false),
            '/join': (BuildContext _) => const JoinGameScreen(),
            '/score': (BuildContext _) => const GolfScoreScreen(),
            '/corrections': (BuildContext _) => const CorrectionsReviewScreen(),
          },
          onGenerateRoute: _handleGeneratedRoute,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  /// Swallows Firebase auth callback routes so they do not break navigation.
  static Route<dynamic>? _handleGeneratedRoute(RouteSettings settings) {
    if (!_isFirebaseAuthCallbackRoute(settings.name)) {
      return null;
    }

    logger.i('Ignoring Firebase auth callback route: ${settings.name}');
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext _) => const WelcomeScreen(),
    );
  }

  /// Detects the Firebase web auth redirect route emitted after sign-in.
  static bool _isFirebaseAuthCallbackRoute(String? routeName) {
    if (routeName == null) {
      return false;
    }

    final uri = Uri.tryParse(routeName);
    final deepLinkId = uri?.queryParameters['deep_link_id'];
    return uri?.path == '/link' &&
        deepLinkId != null &&
        deepLinkId.contains('firebaseapp.com/__/auth/');
  }
}
