import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/identity_service.dart';
import 'package:cards/models/game/score_session.dart';
import 'package:cards/models/game/score_session_service.dart';
import 'package:cards/screens/welcome/join_score_sheet_dialog.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/google_mark_icon.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String _scoreSessionParameter = 'scoreSession';

/// Returns the app route targeted by the active web invitation.
String _deepLinkDestination() {
  return Uri.base.queryParameters.containsKey(_scoreSessionParameter)
      ? '/score'
      : '/game';
}

/// Progress through the welcome flow.
enum _WelcomeStep {
  /// Checking stored identity – show spinner.
  loading,

  /// No identity known – show Google / Initials picker.
  identityPicker,

  /// Identity resolved – ask how the group is playing.
  playMode,

  /// Remote play with virtual cards – show Start / Join a table.
  playOnline,

  /// Live play with real cards – show Start / Join a score sheet.
  playInPerson,
}

/// Welcome screen that guides players into hosting or joining a game.
///
/// Follows an identity-first flow: before showing any options the screen
/// resolves who the player is (Google or Apple sign-in). The player then picks
/// how the group is playing:
///
/// * Online – virtual cards on every device with automatic scoring.
/// * In person – real cards; the app keeps a score sheet that one person or
///   every player can update.
///
/// In both cases one player starts and the others join. Returning players whose
/// identity is already stored go straight to the play-mode step.
class WelcomeScreen extends StatefulWidget {
  ///
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _hasPendingDeepLink = false;
  bool _isBusy = false;
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
    return PopScope(
      canPop: !_isPlayModeDetailStep,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) {
          _showStep(_WelcomeStep.playMode);
        }
      },
      child: Screen(
        title: localizations.appTitle,
        isWaiting: _step == _WelcomeStep.loading || _isBusy,
        showVersion: true,
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
      ),
    );
  }

  /// Builds a "back to play mode" button shown under the detail steps.
  Widget _buildChangePlayModeButton(AppLocalizations localizations) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return MyButtonRectangle.secondary(
      key: const Key('welcome.changePlayMode'),
      width: double.infinity,
      height: ConstLayout.dialogButtonHeight,
      onTap: () => _showStep(_WelcomeStep.playMode),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: ConstLayout.sizeS,
        children: [
          Icon(
            Icons.arrow_back,
            size: ConstLayout.iconS,
            color: colorScheme.onSurface,
          ),
          Text(
            localizations.changePlayMode,
            style: TextStyle(
              fontSize: ConstLayout.textS,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the widget for the current welcome step.
  Widget _buildCurrentStep(AppLocalizations localizations) {
    switch (_step) {
      case _WelcomeStep.loading:
        return const SizedBox.shrink();
      case _WelcomeStep.identityPicker:
        return _buildIdentityPickerStep(localizations);
      case _WelcomeStep.playMode:
        return _buildPlayModeStep(localizations);
      case _WelcomeStep.playOnline:
        return _buildPlayOnlineStep(localizations);
      case _WelcomeStep.playInPerson:
        return _buildPlayInPersonStep(localizations);
    }
  }

  /// Builds the identity picker shown when no identity is known.
  Widget _buildIdentityPickerStep(AppLocalizations localizations) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepHeader(
          title: localizations.identityFirstTitle,
          subtitle: localizations.identityFirstSubtitle,
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

  /// Builds the in-person step: host or join a shared score sheet.
  Widget _buildPlayInPersonStep(AppLocalizations localizations) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepHeader(
          title: localizations.playInPerson,
          subtitle: localizations.playInPersonDescription,
        ),
        SizedBox(height: ConstLayout.sizeL),
        MyButtonRectangle.menu(
          key: const Key('welcome.startScoreSheet'),
          label: localizations.startScoreSheet,
          icon: Icons.scoreboard,
          subLabel: localizations.startScoreSheetHint,
          onTap: () => Navigator.pushNamed(context, '/score'),
        ),
        SizedBox(height: ConstLayout.sizeM),
        MyButtonRectangle.menu(
          key: const Key('welcome.joinScoreSheet'),
          label: localizations.joinScoreSheet,
          icon: Icons.qr_code_scanner,
          subLabel: localizations.joinScoreSheetHint,
          onTap: _joinScoreSheet,
        ),
        SizedBox(height: ConstLayout.sizeM),
        MyButtonRectangle.menu(
          key: const Key('welcome.scanCard'),
          label: localizations.scanCard,
          icon: Icons.camera_alt,
          subLabel: localizations.scanCardHint,
          onTap: () => Navigator.pushNamed(context, '/scan'),
        ),
        SizedBox(height: ConstLayout.sizeXL),
        _buildChangePlayModeButton(localizations),
      ],
    );
  }

  /// Builds the play-mode step shown once identity is resolved.
  Widget _buildPlayModeStep(AppLocalizations localizations) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepHeader(title: localizations.playModeTitle),
        SizedBox(height: ConstLayout.sizeL),
        MyButtonRectangle.menu(
          key: const Key('welcome.playOnline'),
          label: localizations.playOnline,
          icon: Icons.devices,
          subLabel: localizations.playOnlineHint,
          onTap: () => _showStep(_WelcomeStep.playOnline),
        ),
        SizedBox(height: ConstLayout.sizeM),
        MyButtonRectangle.menu(
          key: const Key('welcome.playInPerson'),
          label: localizations.playInPerson,
          icon: Icons.groups,
          subLabel: localizations.playInPersonHint,
          onTap: () => _showStep(_WelcomeStep.playInPerson),
        ),
        SizedBox(height: ConstLayout.sizeL),
        Text(
          localizations.playModeHint,
          style: TextStyle(
            fontSize: ConstLayout.textS,
            color: colorScheme.onSurface.withAlpha(ConstLayout.alphaM),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the online step: host or join a virtual-card table.
  Widget _buildPlayOnlineStep(AppLocalizations localizations) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepHeader(
          title: localizations.playOnline,
          subtitle: localizations.playOnlineDescription,
        ),
        SizedBox(height: ConstLayout.sizeL),
        MyButtonRectangle.menu(
          key: const Key('welcome.startTable'),
          label: localizations.startTable,
          icon: Icons.add_circle_outline,
          subLabel: localizations.identityHostHint,
          onTap: () => Navigator.pushNamed(context, '/start'),
        ),
        SizedBox(height: ConstLayout.sizeM),
        MyButtonRectangle.menu(
          key: const Key('welcome.joinTable'),
          label: localizations.joinExistingGame,
          icon: Icons.group_add,
          subLabel: localizations.identityJoinHint,
          onTap: () => Navigator.pushNamed(context, '/join'),
        ),
        SizedBox(height: ConstLayout.sizeXL),
        _buildChangePlayModeButton(localizations),
      ],
    );
  }

  /// Builds a centered step title with an optional explanatory subtitle.
  Widget _buildStepHeader({required String title, String? subtitle}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ConstLayout.paddingL),
      child: Column(
        spacing: ConstLayout.sizeM,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ConstLayout.textL,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: ConstLayout.textS,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
        ],
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
      if (_hasIdentity) {
        // Already signed in — go straight to the game.
        Future.delayed(Duration.zero, () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, _deepLinkDestination());
          }
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
      _isBusy = true;
    });
    try {
      await signIn();
      if (!mounted) return;
      if (_hasPendingDeepLink) {
        Navigator.pushReplacementNamed(context, _deepLinkDestination());
      } else {
        setState(() {
          _isBusy = false;
          _step = _WelcomeStep.playMode;
        });
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      if (error.code != 'sign_in_canceled') {
        _showMessage(error.message ?? fallbackErrorMessage);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showMessage(fallbackErrorMessage);
    }
  }

  /// Triggers Apple sign-in and advances to the play-mode step on success.
  Future<void> _handleAppleSignIn() async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    await _handleAccountSignIn(
      signIn: AuthService.signInWithApple,
      fallbackErrorMessage: localizations.appleSignInFailed,
    );
  }

  /// Triggers Google sign-in and advances to the play-mode step on success.
  Future<void> _handleGoogleSignIn() async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    await _handleAccountSignIn(
      signIn: AuthService.signInWithGoogle,
      fallbackErrorMessage: localizations.googleSignInFailed,
    );
  }

  /// True once the player's identity is known.
  bool get _hasIdentity =>
      _step != _WelcomeStep.loading && _step != _WelcomeStep.identityPicker;

  /// True on the Online / In-person steps, where back returns to the mode pick.
  bool get _isPlayModeDetailStep =>
      _step == _WelcomeStep.playOnline || _step == _WelcomeStep.playInPerson;

  /// Asks for a shared score sheet's table name and opens it when found.
  Future<void> _joinScoreSheet() async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final String? tableName = await showDialog<String>(
      context: context,
      builder: (BuildContext _) => const JoinScoreSheetDialog(),
    );
    if (!mounted || tableName == null) return;
    final String? sessionId = ScoreSessionService.sessionIdFromTableName(
      tableName,
    );
    if (sessionId == null) return;

    setState(() => _isBusy = true);
    final ScoreSession? session = await ScoreSessionService.getSession(
      sessionId,
    );
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (session == null) {
      _showSnackBar(localizations.scoreSheetNotFound);
      return;
    }
    await Navigator.pushNamed(context, '/score', arguments: session.id);
  }

  /// Checks stored identity and advances to the correct step.
  Future<void> _loadIdentity() async {
    final googleName = IdentityService.googleDisplayName;
    if (googleName != null && googleName.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _step = _WelcomeStep.playMode;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _step = _WelcomeStep.identityPicker;
    });
  }

  void _showMessage(String message) {
    logger.e('Auth error: $message');
    _showSnackBar(message);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Switches to [step], e.g. from the play-mode pick to its Start / Join list.
  void _showStep(_WelcomeStep step) {
    setState(() => _step = step);
  }
}
