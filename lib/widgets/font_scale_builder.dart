import 'package:flutter/material.dart';
import 'package:cards/utils/font_scale_helper.dart';

/// A widget that rebuilds when font scale changes
class FontScaleBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, double fontScale) builder;

  const FontScaleBuilder({super.key, required this.builder});

  @override
  State<FontScaleBuilder> createState() => _FontScaleBuilderState();
}

class _FontScaleBuilderState extends State<FontScaleBuilder> {
  double _currentFontScale = 0.0;

  @override
  void initState() {
    super.initState();
    _currentFontScale = FontScaleHelper.currentScale;
    FontScaleHelper.addListener(_onFontScaleChanged);
  }

  @override
  void dispose() {
    FontScaleHelper.removeListener(_onFontScaleChanged);
    super.dispose();
  }

  void _onFontScaleChanged() {
    if (mounted) {
      setState(() {
        _currentFontScale = FontScaleHelper.currentScale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentFontScale);
  }
}
