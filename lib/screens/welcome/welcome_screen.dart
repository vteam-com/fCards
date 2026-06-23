import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/reviewer_access.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Welcome screen that provides options to start new game, join existing game, or keep scores.
class WelcomeScreen extends StatefulWidget {
  ///
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Check if we have URL parameters that should redirect to game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUrlParameters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Screen(
      title: localizations.appTitle,
      isWaiting: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ConstLayout.mainMenuMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(ConstLayout.paddingM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                MenuButton(
                  label: localizations.startNewGame,
                  icon: Icons.play_circle_fill,
                  onPressed: () => Navigator.pushNamed(context, '/start'),
                ),
                SizedBox(height: ConstLayout.sizeM),
                MenuButton(
                  label: localizations.joinExistingGame,
                  icon: Icons.group_add,
                  onPressed: () => Navigator.pushNamed(context, '/join'),
                ),
                SizedBox(height: ConstLayout.sizeM),
                MenuButton(
                  label: localizations.scoreKeeper,
                  icon: Icons.scoreboard,
                  onPressed: () => Navigator.pushNamed(context, '/score'),
                ),
                SizedBox(height: ConstLayout.sizeM),
                MenuButton(
                  label: localizations.scanCard,
                  icon: Icons.camera_alt,
                  onPressed: () => Navigator.pushNamed(context, '/scan'),
                ),
                _buildCorrectionsMenuButton(localizations),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows the Corrections menu action on web and requests sign-in only on use.
  Widget _buildCorrectionsMenuButton(AppLocalizations localizations) {
    if (isRunningOffLine || !kIsWeb) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: ConstLayout.sizeM),
        MenuButton(
          label: localizations.corrections,
          icon: Icons.fact_check,
          onPressed: _openCorrections,
        ),
      ],
    );
  }

  /// Redirects web users when URL query parameters target game deep links.
  void _checkForUrlParameters() {
    if (!kIsWeb) {
      return; // Only check on web
    }

    final uri = Uri.parse(Uri.base.toString());
    if (uri.queryParameters.isNotEmpty) {
      // We have query parameters, redirect to start screen which can handle them
      // Use Future.delayed to ensure context is available
      Future.delayed(Duration.zero, () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/game');
        }
      });
    }
  }

  /// Requests Google auth only when someone opens the reviewer workflow.
  Future<void> _openCorrections() async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    try {
      if (!AuthService.isSignedInWithAccount) {
        await AuthService.signInWithGoogle();
      }
    } on FirebaseAuthException catch (error) {
      if (error.code != 'sign_in_canceled') {
        _showMessage(error.message ?? localizations.googleSignInFailed);
      }
      return;
    } catch (_) {
      _showMessage(localizations.googleSignInFailed);
      return;
    }

    final bool isReviewer = await isCurrentUserReviewer();
    if (!mounted) {
      return;
    }

    if (!isReviewer) {
      _showMessage(localizations.correctionsReviewerOnly);
      return;
    }

    await Navigator.pushNamed(context, '/corrections');
  }

  /// Logs an auth message and shows it as a snackbar.
  void _showMessage(String message) {
    logger.e('Auth error: $message');
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// A styled button for the main menu.
class MenuButton extends StatelessWidget {
  ///
  const MenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  ///
  final IconData icon;

  ///
  final String label;

  ///
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MyButtonRectangle(
      width: double.infinity,
      height: ConstLayout.mainMenuButtonHeight,
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: ConstLayout.iconM,
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(width: ConstLayout.sizeM),
          SizedBox(
            width: ConstLayout.mainMenuButtonTextWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ConstLayout.textM,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
