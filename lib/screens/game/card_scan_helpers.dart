import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/card_detection.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/tflite_rank_parser.dart';
import 'package:flutter/material.dart';

const double _half = 2.0;

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

/// Builds a user-facing rank label for the correction value dropdown.
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

/// Shows card value correction dialog and returns the selected value.
Future<int?> showCardCorrectionDialog({
  required BuildContext context,
  required AppLocalizations l10n,
  required int currentValue,
  required List<int> correctionValues,
}) async {
  int selectedValue = currentValue;
  return showDialog<int>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (_, setDialogState) {
          return AlertDialog(
            title: Text(l10n.scanCorrectCardValueTitle),
            content: DropdownButton<int>(
              value: selectedValue,
              isExpanded: true,
              items: correctionValues
                  .map(
                    (value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text(formatRankLabel(value, l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setDialogState(() => selectedValue = value);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(selectedValue),
                child: Text(l10n.save),
              ),
            ],
          );
        },
      );
    },
  );
}
