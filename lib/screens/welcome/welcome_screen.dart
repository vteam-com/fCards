import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/identity_service.dart';
import 'package:cards/models/app/reviewer_access.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/google_mark_icon.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Progress through the welcome flow.
enum _WelcomeStep {
  /// Checking stored identity – show spinner.
  loading,

  /// No identity known – show Google / Initials picker.
  identityPicker,

  /// Identity resolved – show Start-a-table / Join-a-table choice.
  choice,
}

/// Welcome screen that guides players into hosting or joining a table.
///
/// Follows an identity-first flow: before showing Start / Join options the
/// screen resolves who the player is (Google sign-in or two-character initials).
/// Returning players whose identity is already stored go straight to the
/// choice step; identity can be changed at any time from the avatar menu.
class WelcomeScreen extends StatefulWidget {
  ///
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _hasPendingDeepLink = false;
  bool _isSigningIn = false;
  _WelcomeStep _step = _WelcomeStep.loading;
  @override
  void initState() {
    super.initState();
    _loadIdentity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUrlParameters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Screen(
      title: localizations.appTitle,
      isWaiting: _step == _WelcomeStep.loading || _isSigningIn,
      child: LayoutBuilder(
        builder: (_, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ConstLayout.paddingM),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: ConstLayout.mainMenuMaxWidth,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [_buildCurrentStep(localizations)],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the Start / Join choice step shown after identity is resolved.
  Widget _buildChoiceStep(AppLocalizations localizations) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ConstLayout.paddingL),
          child: Text(
            localizations.identityChooseActionTitle,
            style: TextStyle(
              fontSize: ConstLayout.textL,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: ConstLayout.sizeL),
        MyButtonRectangle.menu(
          label: localizations.startTable,
          icon: Icons.add_circle_outline,
          subLabel: localizations.identityHostHint,
          onTap: () => Navigator.pushNamed(context, '/start'),
        ),
        SizedBox(height: ConstLayout.sizeM),
        MyButtonRectangle.menu(
          label: localizations.joinExistingGame,
          icon: Icons.group_add,
          subLabel: localizations.identityJoinHint,
          onTap: () => Navigator.pushNamed(context, '/join'),
        ),
        SizedBox(height: ConstLayout.sizeXL),
        Text(
          localizations.otherTools,
          style: TextStyle(
            fontSize: ConstLayout.textS,
            fontWeight: FontWeight.bold,
            color: colorScheme.tertiary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ConstLayout.sizeM),
        MyButtonRectangle.menu(
          label: localizations.scoreKeeper,
          icon: Icons.scoreboard,
          onTap: () => Navigator.pushNamed(context, '/score'),
        ),
        SizedBox(height: ConstLayout.sizeM),
        MyButtonRectangle.menu(
          label: localizations.scanCard,
          icon: Icons.camera_alt,
          onTap: () => Navigator.pushNamed(context, '/scan'),
        ),
        _buildCorrectionsMenuButton(localizations),
      ],
    );
  }

  /// Builds the Corrections menu entry (web-only, reviewer gate).
  Widget _buildCorrectionsMenuButton(AppLocalizations localizations) {
    if (isRunningOffLine || !kIsWeb) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        SizedBox(height: ConstLayout.sizeM),
        MyButtonRectangle.menu(
          label: localizations.corrections,
          icon: Icons.fact_check,
          onTap: _openCorrections,
        ),
      ],
    );
  }

  /// Returns the widget for the current welcome step.
  Widget _buildCurrentStep(AppLocalizations localizations) {
    switch (_step) {
      case _WelcomeStep.loading:
        return const SizedBox.shrink();
      case _WelcomeStep.identityPicker:
        return _buildIdentityPickerStep(localizations);
      case _WelcomeStep.choice:
        return _buildChoiceStep(localizations);
    }
  }

  /// Builds the identity picker shown when no identity is known.
  Widget _buildIdentityPickerStep(AppLocalizations localizations) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ConstLayout.paddingL),
          child: Text(
            localizations.identityFirstTitle,
            style: TextStyle(
              fontSize: ConstLayout.textL,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: ConstLayout.sizeM),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ConstLayout.paddingL),
          child: Text(
            localizations.identityFirstSubtitle,
            style: TextStyle(
              fontSize: ConstLayout.textS,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: ConstLayout.sizeXL),
        _buildIdentityProviderButton(
          label: localizations.identitySignInWithGoogle,
          leading: const GoogleMarkIcon(),
          onTap: _handleGoogleSignIn,
        ),
        if (AuthService.supportsAppleSignIn) ...[
          SizedBox(height: ConstLayout.sizeM),
          _buildIdentityProviderButton(
            label: localizations.identitySignInWithApple,
            leading: Icon(
              Icons.apple,
              size: ConstLayout.iconM,
              color: colorScheme.secondary,
            ),
            onTap: _handleAppleSignIn,
          ),
        ],
        SizedBox(height: ConstLayout.sizeL),
        Text(
          localizations.identityChangeableLater,
          style: TextStyle(
            fontSize: ConstLayout.textS,
            color: colorScheme.onSurface.withAlpha(ConstLayout.alphaM),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds a full-width identity provider button with a branded leading icon.
  Widget _buildIdentityProviderButton({
    required Widget leading,
    required String label,
    required VoidCallback onTap,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return MyButtonRectangle(
      onTap: onTap,
      width: double.infinity,
      height: ConstLayout.mainMenuButtonHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ConstLayout.paddingL),
        child: Row(
          children: [
            SizedBox.square(
              dimension: ConstLayout.iconM,
              child: Center(child: leading),
            ),
            SizedBox(width: ConstLayout.sizeM),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ConstLayout.textM,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Redirects web users when URL query parameters target a game deep link.
  ///
  /// If the user is already signed in, navigates immediately.
  /// Otherwise stores a flag so that [_handleGoogleSignIn] can redirect after
  /// authentication completes.
  void _checkForUrlParameters() {
    if (!kIsWeb) return;
    final uri = Uri.parse(Uri.base.toString());
    if (uri.queryParameters.isNotEmpty) {
      if (_step == _WelcomeStep.choice) {
        // Already signed in — go straight to the game.
        Future.delayed(Duration.zero, () {
          if (mounted) Navigator.pushReplacementNamed(context, '/game');
        });
      } else {
        // Not signed in — require Google sign-in first, then navigate.
        setState(() {
          _hasPendingDeepLink = true;
        });
      }
    }
  }

  /// Runs the selected account sign-in flow and advances on success.
  Future<void> _handleAccountSignIn({
    required Future<UserCredential> Function() signIn,
    required String fallbackErrorMessage,
  }) async {
    setState(() {
      _isSigningIn = true;
    });
    try {
      await signIn();
      if (!mounted) return;
      if (_hasPendingDeepLink) {
        Navigator.pushReplacementNamed(context, '/game');
      } else {
        setState(() {
          _isSigningIn = false;
          _step = _WelcomeStep.choice;
        });
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _isSigningIn = false);
      if (error.code != 'sign_in_canceled') {
        _showMessage(error.message ?? fallbackErrorMessage);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSigningIn = false);
      _showMessage(fallbackErrorMessage);
    }
  }

  /// Triggers Apple sign-in and advances to the choice step on success.
  Future<void> _handleAppleSignIn() async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    await _handleAccountSignIn(
      signIn: AuthService.signInWithApple,
      fallbackErrorMessage: localizations.appleSignInFailed,
    );
  }

  /// Triggers Google sign-in and advances to the choice step on success.
  Future<void> _handleGoogleSignIn() async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    await _handleAccountSignIn(
      signIn: AuthService.signInWithGoogle,
      fallbackErrorMessage: localizations.googleSignInFailed,
    );
  }

  /// Checks stored identity and advances to the correct step.
  Future<void> _loadIdentity() async {
    final googleName = IdentityService.googleDisplayName;
    if (googleName != null && googleName.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _step = _WelcomeStep.choice;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _step = _WelcomeStep.identityPicker;
    });
  }

  /// Signs in and navigates to the corrections reviewer screen.
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
    if (!mounted) return;

    if (!isReviewer) {
      _showMessage(localizations.correctionsReviewerOnly);
      return;
    }

    await Navigator.pushNamed(context, '/corrections');
  }

  void _showMessage(String message) {
    logger.e('Auth error: $message');
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
