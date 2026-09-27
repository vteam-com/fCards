import 'package:cards/models/app/constants_animation.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:flutter/material.dart';

/// Compact player name with an optional remove button.
class PlayerPill extends StatelessWidget {
  /// Creates a pill for [name].
  const PlayerPill({
    super.key,
    required this.name,
    this.highlighted = false,
    this.onRemove,
  });

  /// Outlines the pill, for the player using this device.
  final bool highlighted;

  /// Player name.
  final String name;

  /// Removes the player; hidden when null.
  final VoidCallback? onRemove;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withAlpha(ConstLayout.alphaM),
        borderRadius: BorderRadius.circular(ConstLayout.radiusL),
        border: Border.all(
          color: highlighted
              ? colorScheme.tertiary
              : Colors.white.withValues(alpha: ConstAnimation.borderOpacity),
          width: highlighted ? ConstLayout.strokeS : ConstLayout.strokeXS,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: ConstLayout.paddingL,
          right: onRemove == null
              ? ConstLayout.paddingL
              : ConstLayout.paddingXS,
          top: ConstLayout.paddingS,
          bottom: ConstLayout.paddingS,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: ConstLayout.sizeXS,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: ConstLayout.textS,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onRemove != null)
              InkWell(
                key: Key('playerPill.remove.$name'),
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(ConstLayout.paddingXS),
                  child: Icon(Icons.close, size: ConstLayout.iconXS),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
