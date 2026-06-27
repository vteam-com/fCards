import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/locale_controller.dart';
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
  static const double languageSegmentMinWidth = 55.0;
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
/// - Language selection
/// - Sign in/out button
class AvatarProfileDialog extends StatefulWidget {
  /// Creates an [AvatarProfileDialog].
  const AvatarProfileDialog({
    required this.user,
    required this.guestInitials,
    required this.currentLocaleTag,
    required this.onInitialsChanged,
    required this.onLocaleChanged,
    required this.onSignInTap,
    required this.onSignOutTap,
    required this.onEditInitialsTap,
    super.key,
  });
  static const double avatarRadius = 55.0;

  /// Current locale tag (for example: en, fr, pt-PT).
  final String currentLocaleTag;

  /// Guest initials (for anonymous users).
  final String? guestInitials;

  /// Callback when edit initials button is tapped.
  final VoidCallback onEditInitialsTap;

  /// Callback when initials are changed.
  final ValueChanged<String> onInitialsChanged;

  /// Callback when locale is changed.
  final ValueChanged<String> onLocaleChanged;
  final VoidCallback onSignInTap;

  /// Callback when sign out is tapped.
  final VoidCallback onSignOutTap;

  /// The Firebase user object.
  final User user;
  @override
  State<AvatarProfileDialog> createState() => _AvatarProfileDialogState();
}

class _AvatarProfileDialogState extends State<AvatarProfileDialog> {
  late String _currentLocaleTag;
  @override
  void initState() {
    super.initState();
    _currentLocaleTag = widget.currentLocaleTag;
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
    final Set<String> availableLocaleTags = _selectableLocales()
        .map(LocaleController.localeTagFor)
        .toSet();
    final Map<String, String> localeLabels = <String, String>{
      'en': localizations.languageEnglish,
      'fr': localizations.languageFrench,
      'es': localizations.languageSpanish,
      'pt-PT': localizations.languagePortuguesePortugal,
    };

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
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: localeLabels.entries
              .where(
                (MapEntry<String, String> entry) =>
                    availableLocaleTags.contains(entry.key),
              )
              .map(
                (MapEntry<String, String> entry) => ButtonSegment<String>(
                  value: entry.key,
                  label: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    maxLines: _AvatarProfileDialogConstants.infoValueMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ConstLayout.textS,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
          selected: <String>{_currentLocaleTag},
          onSelectionChanged: (Set<String> value) {
            _changeLocale(value.first);
          },
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(
                horizontal: ConstLayout.paddingM,
                vertical: ConstLayout.paddingL,
              ),
            ),
            minimumSize: const WidgetStatePropertyAll<Size>(
              Size(
                _AvatarProfileDialogConstants.languageSegmentMinWidth,
                _AvatarProfileDialogConstants.buttonHeight,
              ),
            ),
            side: WidgetStateProperty.resolveWith<BorderSide>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return BorderSide(
                  color: colorScheme.secondary,
                  width: ConstLayout.strokeS,
                );
              }

              return BorderSide(
                color: colorScheme.secondary.withAlpha(ConstLayout.alphaM),
                width: ConstLayout.strokeXS,
              );
            }),
            shape: const WidgetStatePropertyAll<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(ConstLayout.radiusM),
                ),
              ),
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.onPrimaryContainer;
              }

              return colorScheme.secondary;
            }),
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.buttonPrimaryTop;
              }

              return AppTheme.buttonSecondaryBottom.withAlpha(
                ConstLayout.alphaL,
              );
            }),
            overlayColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed)) {
                return colorScheme.secondary.withAlpha(ConstLayout.alphaH);
              }

              return Colors.transparent;
            }),
          ),
        ),
      ],
    );
  }

  void _changeLocale(String localeTag) {
    setState(() => _currentLocaleTag = localeTag);
    widget.onLocaleChanged(localeTag);
  }

  /// Resolves avatar initials from guest initials, display name, or email.
  String get _displayInitials {
    if (widget.guestInitials != null && widget.guestInitials!.isNotEmpty) {
      return widget.guestInitials!;
    }

    final String? displayName = widget.user.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      final List<String> parts = displayName.split(RegExp(r'\s+'));
      if (parts.length >=
          _AvatarProfileDialogConstants.initialsSourcePartCount) {
        return ('${parts[0][0]}${parts[1][0]}').toUpperCase();
      }
      return displayName.substring(0, 1).toUpperCase();
    }

    final String? email = widget.user.email;
    if (email != null && email.isNotEmpty) {
      final String localPart = email.split('@').first;
      final List<String> parts = localPart.split(RegExp(r'[._-]+'));
      if (parts.length >=
          _AvatarProfileDialogConstants.initialsSourcePartCount) {
        return ('${parts[0][0]}${parts[1][0]}').toUpperCase();
      }
      return localPart.substring(0, 1).toUpperCase();
    }

    return '👤';
  }

  /// Returns the locales that should be visible in the language picker.
  List<Locale> _selectableLocales() {
    final List<Locale> supportedLocales = AppLocalizations.supportedLocales;

    return supportedLocales.where((Locale locale) {
      final String? countryCode = locale.countryCode;
      if (countryCode != null && countryCode.isNotEmpty) {
        return true;
      }

      return !supportedLocales.any((Locale candidate) {
        final String? candidateCountryCode = candidate.countryCode;
        return candidate.languageCode == locale.languageCode &&
            candidateCountryCode != null &&
            candidateCountryCode.isNotEmpty;
      });
    }).toList();
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
    currentLocaleTag: LocaleController.localeTagFor(
      _avatarProfilePreviewLocale,
    ),
    onInitialsChanged: (_) {},
    onLocaleChanged: (_) {},
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
