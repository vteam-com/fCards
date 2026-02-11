// ignore_for_file: deprecated_member_use
// ignore: fcheck_magic_numbers
import 'dart:ui';
import 'package:cards/models/app/constants_animation.dart';
import 'package:flutter/material.dart';

/// A base widget for glass-like buttons with blur and ripple effects.
class MyButton extends StatelessWidget {
  /// Creates a [MyButton].
  const MyButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.isRound = false,
  });

  /// The corner radius of the button (ignored if [isRound] is true).
  final double? borderRadius;

  /// The widget displayed at the center of the button.
  final Widget child;

  /// The height of the button.
  final double height;

  /// Whether the button should be perfectly round (circular).
  final bool isRound;

  /// Called when the button is tapped.
  final VoidCallback? onTap;

  /// Padding around the button.
  final EdgeInsets padding;

  /// The width of the button.
  final double width;

  @override
  Widget build(BuildContext context) {
    final shape = isRound ? BoxShape.circle : BoxShape.rectangle;
    final radius = isRound ? null : BorderRadius.circular(borderRadius ?? 12);

    return Padding(
      padding: padding,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: radius ?? BorderRadius.zero,
          clipBehavior: isRound ? Clip.antiAlias : Clip.hardEdge,
          child: isRound
              ? ClipOval(child: _buildStack(context, shape, radius))
              : _buildStack(context, shape, radius),
        ),
      ),
    );
  }

  Widget _buildStack(BuildContext _, BoxShape shape, BorderRadius? radius) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blur whatever is behind the button
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: ConstAnimation.blurSigma,
            sigmaY: ConstAnimation.blurSigma,
          ),
          child: const SizedBox.shrink(),
        ),
        // Glassy layer
        Container(
          decoration: BoxDecoration(
            shape: shape,
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(ConstAnimation.blackOverlayOpacity),
                Colors.black.withOpacity(ConstAnimation.blackBackgroundOpacity),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(ConstAnimation.borderOpacity),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.8),
              ),
              BoxShadow(
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(-2, -2),
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
        // Ink ripple
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            enableFeedback: onTap != null,
            onTap: onTap,
            splashColor: Colors.white.withOpacity(
              ConstAnimation.whiteOverlayOpacity,
            ),
            highlightColor: Colors.white.withOpacity(
              ConstAnimation.whiteHighlightOpacity,
            ),
            borderRadius: radius,
            customBorder: isRound ? const CircleBorder() : null,
            child: Center(child: child),
          ),
        ),
      ],
    );
  }
}
