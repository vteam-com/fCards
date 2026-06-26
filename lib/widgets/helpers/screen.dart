import 'dart:math' as math;

import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/constants_animation.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/identity_service.dart';
import 'package:cards/models/app/locale_controller.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/helpers/avatar_profile_dialog.dart';
import 'package:cards/widgets/helpers/google_mark_icon.dart';
import 'package:cards/widgets/helpers/initials_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

enum _AccountSignInProvider { google, apple }

/// Defines breakpoint constants for responsive design
class ResponsiveBreakpoints {
  /// Maximum width for phone layout
  static const double phone = ConstLayout.breakpointPhone;

  /// Maximum width for tablet layout
  static const double tablet = ConstLayout.breakpointTablet;

  /// Minimum width for desktop layout
  static const double desktop = ConstLayout.breakpointDesktop;
}

/// A scaffold widget that provides a common screen layout with app bar and background
class Screen extends StatefulWidget {
  /// Creates a Screen widget
  ///
  /// [title] - Text shown in app bar
  /// [child] - Main content widget
  /// [onRefresh] - Optional callback for refresh button
  /// [getLinkToShare] - Optional callback to get shareable link
  /// [rightText] - Optional text shown on right side of app bar
  /// [isWaiting] - Shows loading indicator when true
  const Screen({
    super.key,
    required this.title,
    required this.child,
    this.onRefresh,
    this.getLinkToShare,
    this.rightText = '',
    required this.isWaiting,
  });

  /// Main content widget displayed in the body
  final Widget child;

  /// Optional callback that returns a string URL/link for sharing
  final String Function()? getLinkToShare;

  /// When true, displays a loading indicator instead of the main content
  final bool isWaiting;

  /// Optional callback function triggered when refresh button is pressed
  final Function? onRefresh;

  /// Optional text shown on right side of app bar (e.g. user name)
  final String rightText;

  /// Title text shown in the app bar
  final String title;

  /// Resolves up to two initials for avatar fallback rendering.
  static String avatarFallbackInitials({
    required String? displayName,
    required String? email,
  }) {
    final String? trimmedDisplayName = displayName?.trim();
    if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
      final List<String> displayNameParts = trimmedDisplayName
          .split(RegExp(r'\s+'))
          .where((String part) => part.isNotEmpty)
          .toList();
      if (displayNameParts.length >= ConstLayout.sizeXS.toInt()) {
        return ('${displayNameParts.first.characters.first}'
                '${displayNameParts[1].characters.first}')
            .toUpperCase();
      }

      return trimmedDisplayName.characters
          .take(ConstLayout.sizeXS.toInt())
          .toString()
          .toUpperCase();
    }

    final String? trimmedEmail = email?.trim();
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) {
      final String localPart = trimmedEmail.split('@').first;
      final List<String> emailParts = localPart
          .split(RegExp(r'[._-]+'))
          .where((String part) => part.isNotEmpty)
          .toList();
      if (emailParts.length >= ConstLayout.sizeXS.toInt()) {
        return ('${emailParts.first.characters.first}'
                '${emailParts[1].characters.first}')
            .toUpperCase();
      }

      return localPart.characters
          .take(ConstLayout.sizeXS.toInt())
          .toString()
          .toUpperCase();
    }

    return avatarFallbackText(displayName: displayName, email: email);
  }

  /// Resolves avatar text for users without a profile photo.
  static String avatarFallbackText({
    required String? displayName,
    required String? email,
  }) {
    final String? trimmedDisplayName = displayName?.trim();
    if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
      return trimmedDisplayName;
    }

    final String? trimmedEmail = email?.trim();
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) {
      return trimmedEmail;
    }

    return '🤔';
  }

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> with SingleTickerProviderStateMixin {
  late final AnimationController _ambientAnimationController;
  String? _guestInitials;
  String _version = '';
  @override
  void initState() {
    super.initState();
    _ambientAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: ConstAnimation.tableTopAmbientDuration,
      ),
    )..repeat();
    _getAppVersion();
    _loadGuestInitials();
  }

  @override
  void dispose() {
    _ambientAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.title,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        actions: [
          ///
          /// VERSION & LICENSES
          ///
          TextButton(
            child: Text(_version),
            onPressed: () async {
              if (context.mounted) {
                final AppLocalizations localizations = AppLocalizations.of(
                  context,
                );
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (
                          BuildContext _,
                          Animation<double> _,
                          Animation<double> _,
                        ) => LicensePage(
                          applicationName: localizations.appTitle,
                          applicationVersion: _version,
                        ),
                  ),
                );
              }
            },
          ),

          ///
          /// REFRESH
          ///
          if (widget.onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => widget.onRefresh!(),
            ),

          /// USER AVATAR
          if (Firebase.apps.isNotEmpty)
            StreamBuilder<User?>(
              stream: AuthService.authStateChanges(),
              builder: (BuildContext _, AsyncSnapshot<User?> snapshot) {
                final User? user = snapshot.data;
                if (user == null) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ConstLayout.sizeS,
                  ),
                  child: _buildAvatar(user),
                );
              },
            ),

          /// RIGHT SIDE TEXT (User Name)
          if (widget.rightText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(ConstLayout.paddingS),
              child: Text(
                widget.rightText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),

          //
          // Share link
          //
          if (widget.getLinkToShare != null)
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(text: widget.getLinkToShare!()),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/table_top.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(child: _buildTableTopAmbientOverlay()),
          SafeArea(
            child: SizedBox.expand(
              child: widget.isWaiting ? _displayWaiting() : widget.child,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds one animated radial glow element for the tabletop ambiance.
  Widget _buildAmbientCircle({
    required Alignment alignment,
    required double diameter,
  }) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withAlpha(
                  ConstAnimation.tableTopAmbientCircleAlpha,
                ),
                Colors.white.withAlpha(
                  ConstAnimation.tableTopAmbientCircleAlpha,
                ),
                Colors.transparent,
                Colors.transparent,
              ],
              center: Alignment.center,
              radius: ConstAnimation.tableTopAmbientCircleRadius,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an avatar for authenticated users with guest and fallback handling.
  Widget _buildAvatar(User user) {
    if (user.isAnonymous) {
      final String? initials =
          (_guestInitials != null && _guestInitials!.isNotEmpty)
          ? _guestInitials
          : null;
      return GestureDetector(
        onTap: () => _showAccountMenu(user),
        child: CircleAvatar(
          radius: ConstLayout.radiusXL,
          backgroundColor: initials != null
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          foregroundColor: initials != null
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          child: initials != null
              ? Text(initials)
              : const Icon(Icons.person_outline),
        ),
      );
    }

    final String fallbackInitials = Screen.avatarFallbackInitials(
      displayName: user.displayName,
      email: user.email,
    );
    final String displayInitials =
        (_guestInitials != null && _guestInitials!.isNotEmpty)
        ? _guestInitials!
        : fallbackInitials;

    final photoUrl = user.photoURL;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return GestureDetector(
        onTap: () => _showAccountMenu(user),
        child: CircleAvatar(
          radius: ConstLayout.radiusXL,
          foregroundImage: NetworkImage(photoUrl),
          onForegroundImageError: (_, _) {},
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: Text(displayInitials),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showAccountMenu(user),
      child: CircleAvatar(
        radius: ConstLayout.radiusXL,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Text(displayInitials),
      ),
    );
  }

  /// Builds the moving ambient light overlay shown over the tabletop texture.
  Widget _buildTableTopAmbientOverlay() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ambientAnimationController,
        builder: (BuildContext _, Widget? _) {
          final double progress = _ambientAnimationController.value;
          final double shortestSide = MediaQuery.sizeOf(context).shortestSide;
          final double circleSizeHuge =
              shortestSide * (ConstLayout.sizeL / ConstLayout.sizeM);

          return Stack(
            children: [
              _buildAmbientCircle(
                alignment: _orbitAlignment(
                  progress: progress,
                  phaseX: ConstLayout.sizeS / ConstLayout.sizeM,
                  phaseY: ConstLayout.sizeXS / ConstLayout.sizeS,
                  amplitudeX: ConstLayout.scaleSmall,
                  amplitudeY: ConstLayout.scaleTiny,
                ),
                diameter:
                    circleSizeHuge /
                    ConstAnimation.tableTopPrimaryCircleDivisor,
              ),
              _buildAmbientCircle(
                alignment: _orbitAlignment(
                  progress: progress,
                  phaseX:
                      (ConstLayout.sizeS / ConstLayout.sizeM) /
                      ConstAnimation.tableTopSecondaryCircleDivisor,
                  phaseY:
                      (ConstLayout.sizeXS / ConstLayout.sizeS) /
                      ConstAnimation.tableTopSecondaryCircleDivisor,
                  amplitudeX: ConstLayout.scaleSmall,
                  amplitudeY: ConstLayout.scaleTiny,
                ),
                diameter:
                    circleSizeHuge /
                    ConstAnimation.tableTopSecondaryCircleDivisor,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Opens the initials dialog and persists the new value.
  ///
  /// Pre-populates with stored initials when available, otherwise derives them
  /// from [user]'s display name or email as a starting suggestion.
  Future<void> _changeInitials({User? user}) async {
    final existing = await IdentityService.getStoredInitials();
    if (!mounted) return;
    final String prefill = (existing != null && existing.isNotEmpty)
        ? existing
        : Screen.avatarFallbackInitials(
            displayName: user?.displayName,
            email: user?.email,
          );
    final String? result = await showDialog<String>(
      context: context,
      builder: (_) => InitialsDialog(initialValue: prefill),
    );
    if (result == null || result.isEmpty) return;
    await IdentityService.saveInitials(result);
    _loadGuestInitials();
  }

  /// Lets the user pick a sign-in provider when multiple account flows exist.
  Future<_AccountSignInProvider?> _chooseAccountSignInProvider(
    AppLocalizations localizations,
  ) async {
    if (!AuthService.supportsAppleSignIn) {
      return _AccountSignInProvider.google;
    }

    return showDialog<_AccountSignInProvider>(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: Text(localizations.signIn),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_AccountSignInProvider.google),
              child: Row(
                spacing: ConstLayout.sizeM,
                children: [
                  const GoogleMarkIcon(),
                  Expanded(child: Text(localizations.identitySignInWithGoogle)),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_AccountSignInProvider.apple),
              child: Row(
                spacing: ConstLayout.sizeM,
                children: [
                  Icon(Icons.apple, size: ConstLayout.iconS),
                  Expanded(child: Text(localizations.identitySignInWithApple)),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations.cancel),
            ),
          ],
        );
      },
    );
  }

  /// Builds the waiting-state loading indicator used by [Screen].
  Widget _displayWaiting() {
    return SizedBox(
      width: ConstLayout.waitingWidgetSize,
      height: ConstLayout.waitingWidgetSize,
      child: Center(
        child: CupertinoActivityIndicator(
          radius: ConstLayout.sizeXL,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Fetches the application version from the platform package info.
  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = packageInfo.version;
        });
      }
    } catch (e) {
      logger.e('Error getting package info: $e');
      if (mounted) {
        setState(() {
          _version = '1.0.0';
        });
      }
    }
  }

  /// Loads and caches the guest player initials from shared preferences.
  Future<void> _loadGuestInitials() async {
    final initials = await IdentityService.getStoredInitials();
    if (mounted) setState(() => _guestInitials = initials);
  }

  /// Computes orbital alignment coordinates for ambient overlay animations.
  Alignment _orbitAlignment({
    required double progress,
    required double phaseX,
    required double phaseY,
    required double amplitudeX,
    required double amplitudeY,
  }) {
    final double fullTurn = math.pi * ConstLayout.strokeS;
    final double x = math.sin((progress + phaseX) * fullTurn) * amplitudeX;
    final double y = math.cos((progress + phaseY) * fullTurn) * amplitudeY;
    return Alignment(x, y);
  }

  /// Opens the account profile dialog showing user info and settings.
  Future<void> _showAccountMenu(User user) async {
    final String currentLanguageCode = Localizations.localeOf(
      context,
    ).languageCode;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    const BorderRadius accountSheetBorderRadius = BorderRadius.vertical(
      top: Radius.circular(ConstLayout.radiusL),
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.only(
            left: ConstLayout.paddingL,
            top: ConstLayout.paddingL,
            right: ConstLayout.paddingL,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ConstLayout.mainMenuMaxWidth,
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: accountSheetBorderRadius,
                  border: Border.all(
                    color: colorScheme.secondary,
                    width: ConstLayout.strokeS,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/table_top.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    ConstLayout.paddingL,
                    ConstLayout.paddingL,
                    ConstLayout.paddingL,
                    ConstLayout.paddingL +
                        MediaQuery.paddingOf(bottomSheetContext).bottom,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.panelInputZone.withAlpha(
                      ConstLayout.alphaL,
                    ),
                    borderRadius: accountSheetBorderRadius,
                  ),
                  child: AvatarProfileDialog(
                    user: user,
                    guestInitials: _guestInitials,
                    currentLanguageCode: currentLanguageCode,
                    onInitialsChanged: (String initials) async {
                      await IdentityService.saveInitials(initials);
                      await _loadGuestInitials();
                    },
                    onLanguageChanged: (String languageCode) {
                      LocaleController.setLanguageCode(languageCode);
                    },
                    onSignInTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _signIn();
                    },
                    onSignOutTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _signOut();
                    },
                    onEditInitialsTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _changeInitials(user: user);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows auth errors without leaving the current screen.
  void _showAuthError(String message) {
    logger.e('Auth error: $message');
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Signs in from the avatar account menu.
  Future<void> _signIn() async {
    final AppLocalizations localizations = AppLocalizations.of(context);

    final _AccountSignInProvider? provider = await _chooseAccountSignInProvider(
      localizations,
    );
    if (!mounted || provider == null) {
      return;
    }

    try {
      switch (provider) {
        case _AccountSignInProvider.google:
          await AuthService.signInWithGoogle();
          break;
        case _AccountSignInProvider.apple:
          await AuthService.signInWithApple();
          break;
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'sign_in_canceled') {
        return;
      }

      _showAuthError(
        error.message ??
            (provider == _AccountSignInProvider.apple
                ? localizations.appleSignInFailed
                : localizations.googleSignInFailed),
      );
    } catch (_) {
      _showAuthError(
        provider == _AccountSignInProvider.apple
            ? localizations.appleSignInFailed
            : localizations.googleSignInFailed,
      );
    }
  }

  /// Signs out and restores the anonymous guest session.
  Future<void> _signOut() async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    try {
      await AuthService.signOut();
      await AuthService.ensureSignedIn();
    } on FirebaseAuthException catch (error) {
      _showAuthError(error.message ?? localizations.signOutFailed);
    } catch (_) {
      _showAuthError(localizations.signOutFailed);
    }
  }
}
