import 'dart:ui';

import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/card_detection.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/tflite_rank_parser.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:flutter/material.dart';

const double _half = 2.0;
const double _correctionCardWidth = 89.0;
const double _correctionCardHeight = 144.0;
const int _bottomCornerQuarterTurns = 2;
const double _cornerLabelWidthFactor = 0.55;

String _formatCardFaceLabel(int value, AppLocalizations l10n) {
  final label = formatRankLabel(value, l10n);
  final separatorIndex = label.indexOf(' (');
  if (separatorIndex == -1) {
    return label;
  }
  return label.substring(0, separatorIndex);
}

String _formatCorrectionTitleLabel(int value, AppLocalizations l10n) {
  return switch (value) {
    TfliteRankParser.rankValueAce => l10n.scanRankAceTitle,
    TfliteRankParser.rankValueJack => l10n.scanRankJackTitle,
    TfliteRankParser.rankValueQueen => l10n.scanRankQueenTitle,
    TfliteRankParser.rankValueKing => l10n.scanRankKingTitle,
    _ => formatRankLabel(value, l10n),
  };
}

/// Returns the accent color used by a correction card based on rank emphasis.
Color _correctionAccentColor({
  required bool isCurrentValue,
  required ColorScheme colorScheme,
}) {
  if (isCurrentValue) {
    return colorScheme.error;
  }

  return colorScheme.primary;
}

/// Builds a tappable card-face tile for one correction value.
Widget _buildCorrectionCard({
  required BuildContext context,
  required AppLocalizations l10n,
  required int value,
  required bool isCurrentValue,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final accentColor = _correctionAccentColor(
    isCurrentValue: isCurrentValue,
    colorScheme: colorScheme,
  );
  final scoreLabel = '$value';
  final faceLabel = _formatCardFaceLabel(value, l10n);
  final borderColor = isCurrentValue
      ? colorScheme.error.withAlpha(ConstLayout.alphaFull)
      : Colors.white.withAlpha(ConstLayout.alphaM);
  final cornerLabelStyle = theme.textTheme.titleLarge?.copyWith(
    color: accentColor,
    fontWeight: FontWeight.bold,
  );
  final cornerLabel = Text(
    faceLabel,
    maxLines: 1,
    softWrap: false,
    overflow: TextOverflow.visible,
    style: cornerLabelStyle,
  );

  return SizedBox(
    width: _correctionCardWidth,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ConstLayout.radiusM),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ConstLayout.radiusM),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withAlpha(ConstLayout.alphaL),
                colorScheme.surface.withAlpha(ConstLayout.alphaM),
              ],
            ),
            border: Border.all(
              color: borderColor,
              width: isCurrentValue
                  ? ConstLayout.strokeS
                  : ConstLayout.strokeXS,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(ConstLayout.alphaM),
                blurRadius: ConstLayout.sizeM,
                offset: const Offset(0, ConstLayout.sizeS),
              ),
            ],
          ),
          child: SizedBox(
            height: _correctionCardHeight,
            child: Padding(
              padding: const EdgeInsets.all(ConstLayout.paddingM),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: FractionallySizedBox(
                      widthFactor: _cornerLabelWidthFactor,
                      alignment: Alignment.topLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: cornerLabel,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      scoreLabel,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: RotatedBox(
                      quarterTurns: _bottomCornerQuarterTurns,
                      child: FractionallySizedBox(
                        widthFactor: _cornerLabelWidthFactor,
                        alignment: Alignment.topLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: cornerLabel,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Wraps correction picker content in the shared frosted panel surface.
Widget _buildCorrectionDialogSurface({
  required Widget child,
  required ColorScheme colorScheme,
  required bool isFullscreen,
}) {
  final borderRadius = BorderRadius.circular(
    isFullscreen ? 0 : ConstLayout.radiusL,
  );

  return ClipRRect(
    borderRadius: borderRadius,
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: ConstLayout.sizeM,
        sigmaY: ConstLayout.sizeM,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.panelInputZone.withAlpha(ConstLayout.alphaL),
              colorScheme.surface.withAlpha(ConstLayout.alphaL),
            ],
          ),
          border: Border.all(
            color: Colors.white.withAlpha(ConstLayout.alphaM),
            width: ConstLayout.strokeXS,
          ),
        ),
        child: child,
      ),
    ),
  );
}

/// Builds the shared correction picker content for dialog and fullscreen modes.
Widget _buildCorrectionDialogContent({
  required BuildContext dialogContext,
  required AppLocalizations l10n,
  required ThemeData theme,
  required ColorScheme colorScheme,
  required int currentValue,
  required List<int> correctionValues,
}) {
  return Padding(
    padding: const EdgeInsets.all(ConstLayout.paddingXL),
    child: SingleChildScrollView(
      child: LayoutBuilder(
        builder: (_, constraints) {
          final sectionWidth = constraints.maxWidth;

          return Wrap(
            alignment: WrapAlignment.center,
            runSpacing: ConstLayout.sizeL,
            children: [
              SizedBox(
                width: sectionWidth,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: ConstLayout.sizeS,
                  children: [
                    SizedBox(
                      width: sectionWidth,
                      child: Text(
                        l10n.scanCorrectCardValueTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: sectionWidth,
                      child: Text(
                        _formatCorrectionTitleLabel(currentValue, l10n),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: sectionWidth,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: ConstLayout.sizeM,
                  runSpacing: ConstLayout.sizeM,
                  children: [
                    ...correctionValues.map(
                      (value) => _buildCorrectionCard(
                        context: dialogContext,
                        l10n: l10n,
                        value: value,
                        isCurrentValue: value == currentValue,
                        onTap: () => Navigator.of(dialogContext).pop(value),
                      ),
                    ),
                    SizedBox(
                      width: _correctionCardWidth,
                      child: MyButtonRectangle.action(
                        width: _correctionCardWidth,
                        height: _correctionCardHeight,
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          l10n.cancel,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

/// Returns a bitmask of cells cancelled by matching triplets per row/column.
List<bool> computeZeroScoredCells(List<int?> values, int dim) {
  final isZeroScored = List<bool>.filled(dim * dim, false);

  // Check rows
  for (int row = 0; row < dim; row++) {
    final i0 = row * dim;
    final i1 = row * dim + 1;
    final i2 = row * dim + (dim - 1);
    final v0 = values[i0];
    if (v0 != null && v0 == values[i1] && v0 == values[i2]) {
      isZeroScored[i0] = true;
      isZeroScored[i1] = true;
      isZeroScored[i2] = true;
    }
  }

  // Check columns
  for (int col = 0; col < dim; col++) {
    final i0 = col;
    final i1 = dim + col;
    final i2 = (dim - 1) * dim + col;
    final v0 = values[i0];
    if (v0 != null && v0 == values[i1] && v0 == values[i2]) {
      isZeroScored[i0] = true;
      isZeroScored[i1] = true;
      isZeroScored[i2] = true;
    }
  }

  return isZeroScored;
}

/// Computes the centered destination rect that preserves source aspect ratio.
Rect containedRect(Size canvasSize, Size sourceSize) {
  final fittedSizes = applyBoxFit(BoxFit.contain, sourceSize, canvasSize);
  final destinationSize = fittedSizes.destination;
  final dx = (canvasSize.width - destinationSize.width) / _half;
  final dy = (canvasSize.height - destinationSize.height) / _half;
  return Rect.fromLTWH(dx, dy, destinationSize.width, destinationSize.height);
}

/// Computes the Intersection-over-Union ratio for two bounding boxes.
double iou(CardDetection a, CardDetection b) {
  final left = a.left > b.left ? a.left : b.left;
  final top = a.top > b.top ? a.top : b.top;
  final right = (a.left + a.width) < (b.left + b.width)
      ? (a.left + a.width)
      : (b.left + b.width);
  final bottom = (a.top + a.height) < (b.top + b.height)
      ? (a.top + a.height)
      : (b.top + b.height);

  final interWidth = right - left;
  final interHeight = bottom - top;
  if (interWidth <= 0 || interHeight <= 0) {
    return 0;
  }

  final intersection = interWidth * interHeight;
  final union = (a.width * a.height) + (b.width * b.height) - intersection;
  if (union <= 0) {
    return 0;
  }

  return intersection / union;
}

/// Builds a user-facing rank label for the correction picker.
String formatRankLabel(int value, AppLocalizations l10n) {
  return switch (value) {
    TfliteRankParser.jokerRankValue => l10n.scanRankJoker,
    TfliteRankParser.rankValueKing => l10n.scanRankKing,
    TfliteRankParser.rankValueAce => l10n.scanRankAce,
    TfliteRankParser.rankValueJack => l10n.scanRankJack,
    TfliteRankParser.rankValueQueen => l10n.scanRankQueen,
    _ => '$value',
  };
}

/// Returns the shared style used for score numbers in overlays and footer.
TextStyle scoreNumberStyle(BuildContext context, {required double fontSize}) {
  final colorScheme = Theme.of(context).colorScheme;
  final scoreFontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;
  return TextStyle(
    fontFamily: scoreFontFamily,
    fontWeight: FontWeight.bold,
    fontSize: fontSize,
    color: Color.alphaBlend(colorScheme.onSurface, Colors.green.shade300),
    shadows: const <Shadow>[
      Shadow(
        color: Colors.white54,
        offset: Offset(-ConstLayout.strokeXS, -ConstLayout.strokeXS),
        blurRadius: ConstLayout.strokeS,
      ),
      Shadow(
        color: Colors.black54,
        offset: Offset(ConstLayout.strokeXS, ConstLayout.strokeXS),
        blurRadius: ConstLayout.strokeS,
      ),
    ],
  );
}

/// Shows card value correction dialog and returns the tapped value.
Future<int?> showCardCorrectionDialog({
  required BuildContext context,
  required AppLocalizations l10n,
  required int currentValue,
  required List<int> correctionValues,
}) async {
  return showDialog<int>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final colorScheme = theme.colorScheme;
      final isSmallScreen =
          MediaQuery.of(dialogContext).size.width < ConstLayout.breakpointPhone;
      final content = _buildCorrectionDialogContent(
        dialogContext: dialogContext,
        l10n: l10n,
        theme: theme,
        colorScheme: colorScheme,
        currentValue: currentValue,
        correctionValues: correctionValues,
      );

      if (isSmallScreen) {
        return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: _buildCorrectionDialogSurface(
                colorScheme: colorScheme,
                isFullscreen: true,
                child: content,
              ),
            ),
          ),
        );
      }

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(ConstLayout.paddingXL),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ConstLayout.gameOverDialogWidth,
          ),
          child: _buildCorrectionDialogSurface(
            colorScheme: colorScheme,
            isFullscreen: false,
            child: content,
          ),
        ),
      );
    },
  );
}
