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
                    colors: [
                      const Color.fromARGB(
                        255,
                        40,
                        80,
                        40,
                      ), //.withAlpha(ConstLayout.alphaM),
                      const Color.fromARGB(
                        255,
                        10,
                        20,
                        10,
                      ).withAlpha(ConstLayout.alphaL),
                    ],
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
