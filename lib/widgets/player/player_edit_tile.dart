import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/player_avatar.dart';
import 'package:flutter/material.dart';

/// Compact player tile used while editing the Score Keeper player list.
class PlayerEditTile extends StatelessWidget {
  /// Creates an editable player tile with identity and remove action.
  const PlayerEditTile({
    super.key,
    required this.initials,
    required this.width,
    required this.editLabel,
    required this.removeTooltip,
    required this.onEditInitials,
    required this.onRemove,
    this.avatarUrl,
    this.email,
  });
  static const int _emailMaxLines = 2;

  /// Account avatar image URL, when available.
  final String? avatarUrl;

  /// Localized label describing the initials edit action.
  final String editLabel;

  /// Account email, when available.
  final String? email;

  /// Player initials shown when no avatar image is available.
  final String initials;

  /// Largest comfortable player tile width on roomy screens.
  static const double maxWidth = 233.0;

  /// Smallest tile width before the row switches to horizontal scrolling.
  static const double minWidth = 55.0;

  /// Called when the identity area is tapped.
  final VoidCallback onEditInitials;

  /// Called when the remove action is tapped.
  final VoidCallback onRemove;

  /// Accessible tooltip for the icon-only remove button.
  final String removeTooltip;

  /// Height shared by editable player and add-player cards.
  static const double tileHeight =
      ConstLayout.sizeXXL + ConstLayout.playerZoneCTAHeight;

  /// Responsive width selected by the parent player row.
  final double width;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String? playerEmail = email;

    return Container(
      width: width,
      height: tileHeight,
      padding: const EdgeInsets.all(ConstLayout.paddingM),
      decoration: BoxDecoration(
        color: AppTheme.panelInputZone,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(ConstLayout.radiusS),
      ),
      child: Column(
        children: [
          Expanded(
            child: Tooltip(
              message: editLabel,
              child: InkWell(
                borderRadius: BorderRadius.circular(ConstLayout.radiusS),
                onTap: onEditInitials,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: ConstLayout.sizeXS,
                        children: [
                          PlayerAvatar(
                            radius: ConstLayout.sizeL,
                            photoUrl: avatarUrl,
                            initials: initials,
                          ),
                          if (playerEmail != null && playerEmail.isNotEmpty)
                            Tooltip(
                              message: playerEmail,
                              child: Text(
                                playerEmail,
                                maxLines: _emailMaxLines,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: ConstLayout.textS,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: ConstLayout.paddingXS,
                      right: ConstLayout.paddingXS,
                      child: IgnorePointer(
                        child: Icon(
                          Icons.drag_indicator,
                          color: colorScheme.outline,
                          size: ConstLayout.iconXS,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: removeTooltip,
            color: colorScheme.error,
            constraints: const BoxConstraints.tightFor(
              width: ConstLayout.sizeXXL,
              height: ConstLayout.sizeXXL,
            ),
            iconSize: ConstLayout.iconM,
            padding: EdgeInsets.zero,
            onPressed: onRemove,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
