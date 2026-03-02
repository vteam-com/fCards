import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:flutter/material.dart';

/// A base widget for glass-like buttons with blur and ripple effects.
class MyButton extends StatelessWidget {
  /// Creates a [MyButton].
  const MyButton({
    super.key,
    required this.onTap,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.isRound = false,
    this.isAction = false,
  });

  /// Creates a [MyButton] with a more transparent background for primary actions.
  const MyButton.action({
    super.key,
    required this.onTap,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = ConstLayout.radiusL,
    this.padding = EdgeInsets.zero,
    this.isRound = false,
  }) : isAction = true;

  /// The corner radius of the button (ignored if [isRound] is true).
  final double? borderRadius;

  /// The widget displayed at the center of the button.
  final Widget child;

  /// The height of the button.
  final double? height;

  /// Whether this button should use the action style (more transparent).
  final bool isAction;

  /// Whether the button should be perfectly round (circular).
  final bool isRound;

  /// Called when the button is tapped.
  final VoidCallback? onTap;

  /// Padding around the button.
  final EdgeInsets padding;

  /// The width of the button.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final shape = isRound ? BoxShape.circle : BoxShape.rectangle;
    final radius = isRound
        ? null
        : BorderRadius.circular(borderRadius ?? ConstLayout.radiusM);

    final Color baseTopColor = AppTheme.buttonGradientTop;
    final Color baseBottomColor = AppTheme.buttonGradientBottom;
    final Color topColor = isAction
        ? AppTheme.buttonActionGradientTop
        : baseTopColor;
    final Color bottomColor = isAction
        ? AppTheme.buttonActionGradientBottom
        : baseBottomColor.withAlpha(ConstLayout.alphaL);

    return Padding(
      padding: padding,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: radius ?? BorderRadius.zero,
          clipBehavior: isRound ? Clip.antiAlias : Clip.hardEdge,
          child: Stack(
            children: [
              // Frosted layer and Content
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  shape: shape,
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [topColor, bottomColor],
                  ),
                  border: Border.all(
                    color: Colors.white.withAlpha(ConstLayout.alphaM),
                    width: ConstLayout.strokeXXS,
                  ),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    enableFeedback: onTap != null,
                    onTap: onTap,
                    splashColor: Colors.white.withAlpha(ConstLayout.alphaL),
                    highlightColor: Colors.white.withAlpha(ConstLayout.alphaL),
                    borderRadius: radius,
                    customBorder: isRound ? const CircleBorder() : null,
                    child: Center(child: child),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
