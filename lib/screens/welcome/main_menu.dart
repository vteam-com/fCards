import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Welcome screen that provides options to start new game, join existing game, or keep scores.
class MainMenu extends StatefulWidget {
  ///
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool _isAuthWorking = false;

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
    return Screen(
      title: 'VTeam Cards',
      isWaiting: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ConstLayout.mainMenuMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(ConstLayout.sizeM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                _authSection(),
                const Spacer(),
                MenuButton(
                  label: 'Start a New Game',
                  icon: Icons.play_circle_fill,
                  onPressed: () => Navigator.pushNamed(context, '/game'),
                ),
                SizedBox(height: ConstLayout.sizeM),
                MenuButton(
                  label: 'Join an Existing Game',
                  icon: Icons.group_add,
                  onPressed: () => Navigator.pushNamed(context, '/join'),
                ),
                SizedBox(height: ConstLayout.sizeM),
                MenuButton(
                  label: 'Score Keeper',
                  icon: Icons.scoreboard,
                  onPressed: () => Navigator.pushNamed(context, '/score'),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _authSection() {
    if (isRunningOffLine) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      builder: (BuildContext _, snapshot) {
        final user = snapshot.data;
        final bool isAnonymous = user?.isAnonymous ?? false;
        final bool isSignedIn = user != null && !isAnonymous;
        final String status = isSignedIn
            ? (user.email ?? user.displayName ?? 'Signed in')
            : (isAnonymous ? 'Playing as Guest' : 'Not signed in');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ConstLayout.sizeM),
          decoration: BoxDecoration(
            color: AppTheme.panelInputZone,
            borderRadius: BorderRadius.circular(ConstLayout.radiusM),
            border: Border.all(
              color: colorScheme.onPrimary,
              width: ConstLayout.strokeS,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Account',
                style: TextStyle(
                  fontSize: ConstLayout.textS,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
              SizedBox(height: ConstLayout.sizeS),
              Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurface),
              ),
              SizedBox(height: ConstLayout.sizeM),
              if (!isSignedIn)
                MyButtonRectangle(
                  width: double.infinity,
                  height: 48, // Standard height or from constants
                  onTap: _isAuthWorking ? null : _handleGoogleSignIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isAuthWorking)
                        SizedBox(
                          width: ConstLayout.iconS,
                          height: ConstLayout.iconS,
                          child: CircularProgressIndicator(
                            strokeWidth: ConstLayout.strokeS,
                            color: colorScheme.secondary,
                          ),
                        )
                      else
                        const Icon(Icons.mail_outline),
                      SizedBox(width: ConstLayout.sizeS),
                      Text(
                        _isAuthWorking
                            ? 'Signing in...'
                            : 'Sign in with Google',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                MyButtonRectangle(
                  width: double.infinity,
                  height: 48,
                  onTap: _isAuthWorking ? null : _handleSignOut,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout),
                      SizedBox(width: ConstLayout.sizeS),
                      Text(
                        _isAuthWorking ? 'Signing out...' : 'Sign out',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

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

  Future<void> _handleGoogleSignIn() async {
    await _performAuthAction(
      AuthService.signInWithGoogle,
      'Google sign-in failed.',
    );
  }

  Future<void> _handleSignOut() async {
    await _performAuthAction(() async {
      await AuthService.signOut();
      await AuthService.ensureSignedIn();
    }, 'Sign out failed.');
  }

  Future<void> _performAuthAction(
    Future<void> Function() action,
    String defaultErrorMessage,
  ) async {
    setState(() {
      _isAuthWorking = true;
    });

    try {
      await action();
    } on FirebaseAuthException catch (error) {
      _showAuthError(error.message ?? defaultErrorMessage);
    } catch (_) {
      _showAuthError(defaultErrorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isAuthWorking = false;
        });
      }
    }
  }

  void _showAuthError(String message) {
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
