import 'package:cards/models/app/constants_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A compact Google-style mark for sign-in entry points.
class GoogleMarkIcon extends StatelessWidget {
  /// Creates a Google-style sign-in icon.
  const GoogleMarkIcon({super.key, this.size = ConstLayout.iconS});
  static const String _assetPath = 'assets/images/google.svg';

  /// The square size of the rendered icon.
  final double size;
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: SvgPicture.asset(
        _assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
