import 'dart:ui';
import 'package:cards/models/app/constants_animation.dart';
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
  });

  /// The corner radius of the button (ignored if [isRound] is true).
  final double? borderRadius;

  /// The widget displayed at the center of the button.
  final Widget child;

  /// The height of the button.
  final double? height;

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
              // Blur whatever is behind the button
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: ConstAnimation.blurSigma,
                    sigmaY: ConstAnimation.blurSigma,
                  ),
                  child: const SizedBox.shrink(),
                ),
              ),
              // Glassy layer and Content
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  shape: shape,
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(
                        255,
                        0,
                        73,
                        16,
                      ).withAlpha(ConstLayout.alphaM),
                      const Color.fromARGB(
                        255,
                        8,
                        47,
                        1,
                      ).withAlpha(ConstLayout.alphaM),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withAlpha(ConstLayout.alphaL),
                    width: ConstLayout.strokeXXS,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: ConstLayout.radiusM,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                      color: Colors.black.withAlpha(ConstLayout.alphaL),
                    ),
                    BoxShadow(
                      blurRadius: ConstLayout.radiusS,
                      spreadRadius: 0,
                      offset: const Offset(-2, -2),
                      color: Colors.white.withAlpha(ConstLayout.alphaL),
                    ),
                  ],
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
