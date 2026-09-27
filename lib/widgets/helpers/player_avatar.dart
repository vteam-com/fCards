import 'package:flutter/material.dart';

/// Circular avatar showing a profile photo, falling back to initials or icon.
///
/// Shared by every place that shows a user or player avatar so photo loading,
/// error handling, and fallback rendering stay consistent.
class PlayerAvatar extends StatelessWidget {
  /// Creates an avatar of the given [radius].
  const PlayerAvatar({
    super.key,
    required this.radius,
    this.photoUrl,
    this.initials,
    this.fallbackIcon,
    this.initialsStyle = _defaultInitialsStyle,
    this.backgroundColor,
    this.foregroundColor,
  });
  static const TextStyle _defaultInitialsStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );

  /// Circle fill color; defaults to the [CircleAvatar] theme color.
  final Color? backgroundColor;

  /// Icon shown when neither a photo nor initials are available.
  final IconData? fallbackIcon;

  /// Text and icon color; defaults to the [CircleAvatar] theme color.
  final Color? foregroundColor;

  /// Text shown when no photo is available or while it loads.
  final String? initials;

  /// Style for [initials]; the text is always scaled down to fit the circle.
  final TextStyle initialsStyle;

  /// Profile photo URL; ignored when null or empty.
  final String? photoUrl;

  /// Circle radius.
  final double radius;
  @override
  Widget build(BuildContext context) {
    final String? url = photoUrl;
    final bool hasPhoto = url != null && url.isNotEmpty;
    final String? text = initials;

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      foregroundImage: hasPhoto ? NetworkImage(url) : null,
      onForegroundImageError: hasPhoto ? (_, _) {} : null,
      child: text != null && text.isNotEmpty
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text, style: initialsStyle),
            )
          : fallbackIcon == null
          ? null
          : Icon(fallbackIcon),
    );
  }
}
