import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Constants for the avatar profile dialog.
class _AvatarProfileDialogConstants {
  static const double avatarRadius = 55.0; // Fibonacci number
  static const double headerVerticalPadding = 34.0;
  static const double headerHorizontalPadding = 21.0;
  static const double contentSpacing = 13.0;
  static const double sectionSpacing = 21.0;
  static const double buttonHeight = 55.0;
  static const int infoValueMaxLines = 2;
  static const int initialsSourcePartCount = 2;
}

/// A comprehensive profile dialog showing user information and editable settings.
///
/// Displays:
/// - Profile image/avatar
/// - Full name (if available)
/// - Email (if signed in)
/// - Editable initials
/// - Language selection (EN/FR)
/// - Sign in/out button
class AvatarProfileDialog extends StatefulWidget {
  /// Creates an [AvatarProfileDialog].
  const AvatarProfileDialog({
    required this.user,
    required this.guestInitials,
    required this.currentLanguageCode,
    required this.onInitialsChanged,
    required this.onLanguageChanged,
    required this.onSignInTap,
    required this.onSignOutTap,
    required this.onEditInitialsTap,
    super.key,
  });

  /// Current language code (en, fr, etc.).
  final String currentLanguageCode;

  /// Guest initials (for anonymous users).
  final String? guestInitials;

  /// Callback when edit initials button is tapped.
  final VoidCallback onEditInitialsTap;

  /// Callback when initials are changed.
  final ValueChanged<String> onInitialsChanged;

  /// Callback when language is changed.
  final ValueChanged<String> onLanguageChanged;

  /// Callback when sign in is tapped.
  final VoidCallback onSignInTap;

  /// Callback when sign out is tapped.
  final VoidCallback onSignOutTap;

  /// The Firebase user object.
  final User user;
  @override
  State<AvatarProfileDialog> createState() => _AvatarProfileDialogState();
}

class _AvatarProfileDialogState extends State<AvatarProfileDialog> {
  late String _currentLanguage;
  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.currentLanguageCode;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);
    final isSignedIn = !widget.user.isAnonymous;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: _AvatarProfileDialogConstants.sectionSpacing,
        children: [
          // Header with avatar and basic info
          _buildHeaderSection(colorScheme, localizations),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _AvatarProfileDialogConstants.headerHorizontalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: _AvatarProfileDialogConstants.contentSpacing,
              children: [
                // Display name or email
                if (isSignedIn) ...[
                  _buildInfoSection(
                    colorScheme,
                    icon: Icons.person_outline,
                    label: localizations.fullName,
                    value: widget.user.displayName ?? '—',
                  ),
                  _buildInfoSection(
                    colorScheme,
                    icon: Icons.email_outlined,
                    label: localizations.email,
                    value: widget.user.email ?? '—',
                  ),
                ],

                SizedBox(height: _AvatarProfileDialogConstants.contentSpacing),

                // Editable initials button
                MyButtonRectangle.secondary(
                  width: double.infinity,
                  height: _AvatarProfileDialogConstants.buttonHeight,
                  onTap: widget.onEditInitialsTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: ConstLayout.sizeS,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: colorScheme.onPrimaryContainer,
                        size: ConstLayout.iconXS,
                      ),
                      Flexible(
                        child: Text(
                          localizations.editInitials,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ConstLayout.textS,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: _AvatarProfileDialogConstants.contentSpacing),

                // Language selection
                _buildLanguageSection(colorScheme, localizations),

                SizedBox(height: _AvatarProfileDialogConstants.contentSpacing),

                // Sign in/out button
                MyButtonRectangle.secondary(
                  width: double.infinity,
                  height: _AvatarProfileDialogConstants.buttonHeight,
                  onTap: isSignedIn ? widget.onSignOutTap : widget.onSignInTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: ConstLayout.sizeS,
                    children: [
                      Icon(
                        isSignedIn ? Icons.logout : Icons.login,
                        color: colorScheme.onPrimaryContainer,
                        size: ConstLayout.iconXS,
                      ),
                      Flexible(
                        child: Text(
                          isSignedIn
                              ? localizations.signOut
                              : localizations.signIn,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ConstLayout.textS,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: _AvatarProfileDialogConstants.headerHorizontalPadding,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the header section with avatar and account title.
  Widget _buildHeaderSection(ColorScheme colorScheme, AppLocalizations _) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _AvatarProfileDialogConstants.headerHorizontalPadding,
        vertical: _AvatarProfileDialogConstants.headerVerticalPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: _AvatarProfileDialogConstants.contentSpacing,
        children: [
          // Avatar circle
          CircleAvatar(
            radius: _AvatarProfileDialogConstants.avatarRadius,
            foregroundImage:
                widget.user.photoURL != null && widget.user.photoURL!.isNotEmpty
                ? NetworkImage(widget.user.photoURL!)
                : null,
            onForegroundImageError:
                widget.user.photoURL != null && widget.user.photoURL!.isNotEmpty
                ? (_, _) {}
                : null,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: Text(
              _displayInitials,
              style: TextStyle(
                fontSize: ConstLayout.textL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an info section with icon, label, and value.
  Widget _buildInfoSection(
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      spacing: ConstLayout.sizeM,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.secondary, size: ConstLayout.iconS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: ConstLayout.sizeXS,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ConstLayout.textS,
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: ConstLayout.textS,
                  color: colorScheme.onSurface,
                ),
                maxLines: _AvatarProfileDialogConstants.infoValueMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the language selection section.
  Widget _buildLanguageSection(
    ColorScheme colorScheme,
    AppLocalizations localizations,
  ) {
    final supportedLocales = AppLocalizations.supportedLocales;
    final englishLocale = supportedLocales.firstWhere(
      (locale) => locale.languageCode == 'en',
      orElse: () => supportedLocales.first,
    );
    final frenchLocale = supportedLocales.firstWhere(
      (locale) => locale.languageCode == 'fr',
      orElse: () => supportedLocales.last,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: ConstLayout.sizeM,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: ConstLayout.sizeS,
          children: [
            Icon(
              Icons.translate,
              color: colorScheme.secondary,
              size: ConstLayout.iconXS,
            ),
            Text(
              localizations.language,
              style: TextStyle(
                fontSize: ConstLayout.textS,
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
        Row(
          spacing: ConstLayout.sizeM,
          children: [
            Expanded(
              child:
                  (_currentLanguage == englishLocale.languageCode
                  ? MyButtonRectangle.primary
                  : MyButtonRectangle.secondary)(
                    height: _AvatarProfileDialogConstants.buttonHeight,
                    onTap: () => _changeLanguage(englishLocale.languageCode),
                    child: Text(
                      englishLocale.languageCode.toUpperCase(),
                      style: TextStyle(
                        fontSize: ConstLayout.textS,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
            ),
            Expanded(
              child:
                  (_currentLanguage == frenchLocale.languageCode
                  ? MyButtonRectangle.primary
                  : MyButtonRectangle.secondary)(
                    height: _AvatarProfileDialogConstants.buttonHeight,
                    onTap: () => _changeLanguage(frenchLocale.languageCode),
                    child: Text(
                      frenchLocale.languageCode.toUpperCase(),
                      style: TextStyle(
                        fontSize: ConstLayout.textS,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  void _changeLanguage(String languageCode) {
    setState(() => _currentLanguage = languageCode);
    widget.onLanguageChanged(languageCode);
  }

  /// Resolves avatar initials from guest initials, display name, or email.
  String get _displayInitials {
    if (widget.guestInitials != null && widget.guestInitials!.isNotEmpty) {
      return widget.guestInitials!;
    }

    final displayName = widget.user.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(RegExp(r'\s+'));
      if (parts.length >=
          _AvatarProfileDialogConstants.initialsSourcePartCount) {
        return ('${parts[0][0]}${parts[1][0]}').toUpperCase();
      }
      return displayName.substring(0, 1).toUpperCase();
    }

    final email = widget.user.email;
    if (email != null && email.isNotEmpty) {
      final localPart = email.split('@').first;
      final parts = localPart.split(RegExp(r'[._-]+'));
      if (parts.length >=
          _AvatarProfileDialogConstants.initialsSourcePartCount) {
        return ('${parts[0][0]}${parts[1][0]}').toUpperCase();
      }
      return localPart.substring(0, 1).toUpperCase();
    }

    return '👤';
  }
}

/// Provides a localized Material wrapper for the dialog widget preview.
Widget avatarProfileDialogPreviewWrapper(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

final Locale _avatarProfilePreviewLocale =
    AppLocalizations.supportedLocales.first;
final AppLocalizations _avatarProfilePreviewLocalizations =
    lookupAppLocalizations(_avatarProfilePreviewLocale);

@Preview(
  name: 'Avatar Profile Dialog',
  group: 'Dialogs',
  wrapper: avatarProfileDialogPreviewWrapper,
  size: Size(400, 1900),
)
/// Renders the avatar profile dialog preview with a signed-in sample user.
Widget avatarProfileDialogPreview() {
  return AvatarProfileDialog(
    user: _AvatarProfilePreviewUser(),
    guestInitials: null,
    currentLanguageCode: _avatarProfilePreviewLocale.languageCode,
    onInitialsChanged: (_) {},
    onLanguageChanged: (_) {},
    onSignInTap: () {},
    onSignOutTap: () {},
    onEditInitialsTap: () {},
  );
}

final class _AvatarProfilePreviewUser implements User {
  @override
  String? get displayName => _avatarProfilePreviewLocalizations.fullName;

  @override
  String? get email => _avatarProfilePreviewLocalizations.email;

  @override
  bool get isAnonymous => false;

  @override
  String? get photoURL => null;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
