import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:flutter/material.dart';

/// Shows content in the app's shared dismissible bottom-sheet surface.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  const BorderRadius borderRadius = BorderRadius.vertical(
    top: Radius.circular(ConstLayout.radiusL),
  );
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isDismissible: true,
    isScrollControlled: isScrollControlled,
    useSafeArea: false,
    builder: (BuildContext sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: ConstLayout.paddingL,
          top: ConstLayout.paddingL,
          right: ConstLayout.paddingL,
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ConstLayout.mainMenuMaxWidth,
            ),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.secondary,
                  width: ConstLayout.strokeS,
                ),
                borderRadius: borderRadius,
                image: const DecorationImage(
                  image: AssetImage('assets/images/table_top.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.panelInputZone.withAlpha(ConstLayout.alphaL),
                  borderRadius: borderRadius,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGrabber(colorScheme),
                    Flexible(child: builder(sheetContext)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Builds the iOS-style handle that hints the sheet can be swiped away.
Widget _buildGrabber(ColorScheme colorScheme) {
  return Padding(
    padding: const EdgeInsets.only(top: ConstLayout.paddingS),
    child: Container(
      width: ConstLayout.sizeXL,
      height: ConstLayout.sizeS,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withAlpha(ConstLayout.alphaM),
        borderRadius: const BorderRadius.all(
          Radius.circular(ConstLayout.radiusXS),
        ),
      ),
    ),
  );
}
