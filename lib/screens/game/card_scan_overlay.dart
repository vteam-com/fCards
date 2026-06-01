part of 'card_scan_screen.dart';

// ── Bounding box painter ───────────────────────────────────────────────────────

class _DetectionOverlayPainter extends CustomPainter {
  static const double _cellBadgeWidth = ConstLayout.iconXL;
  static const double _cellCenterOffset = 0.5;
  static const double _half = 2.0;

  const _DetectionOverlayPainter({
    required this.detections,
    required this.gridInference,
    required this.overlayNumberStyle,
    required this.cellNumberStyle,
    this.contentRect,
  });

  final List<CardDetection> detections;
  final _GridInference? gridInference;
  final TextStyle overlayNumberStyle;
  final TextStyle cellNumberStyle;
  final Rect? contentRect;

  @override
  void paint(Canvas canvas, Size size) {
    final drawRect = contentRect ?? Offset.zero & size;
    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ConstLayout.strokeM
      ..color = Colors.greenAccent;

    for (final d in detections) {
      final rect = Rect.fromLTWH(
        drawRect.left + d.left * drawRect.width,
        drawRect.top + d.top * drawRect.height,
        d.width * drawRect.width,
        d.height * drawRect.height,
      );

      canvas.drawRect(rect, boxPaint);
    }

    final grid = gridInference;
    if (grid != null) {
      final gridLeft = drawRect.left + grid.left * drawRect.width;
      final gridTop = drawRect.top + grid.top * drawRect.height;
      final gridWidth = grid.width * drawRect.width;
      final gridHeight = grid.height * drawRect.height;
      final cellWidth = gridWidth / _CardScanScreenState._gridDimension;
      final cellHeight = gridHeight / _CardScanScreenState._gridDimension;

      for (int row = 0; row < _CardScanScreenState._gridDimension; row++) {
        for (int col = 0; col < _CardScanScreenState._gridDimension; col++) {
          final index = row * _CardScanScreenState._gridDimension + col;
          final value = grid.valuesByCell[index];
          final displayText =
              value?.toString() ?? '${TfliteService.jokerRankValue}';

          final backTextPainter = TextPainter(
            text: TextSpan(
              text: displayText,
              style: cellNumberStyle.copyWith(
                color: Colors.grey.shade700,
                shadows: const <Shadow>[],
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          final frontTextPainter = TextPainter(
            text: TextSpan(
              text: displayText,
              style: cellNumberStyle.copyWith(
                color: Colors.white,
                shadows: const <Shadow>[],
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          final cellCenterX = gridLeft + (col + _cellCenterOffset) * cellWidth;
          final cellCenterY = gridTop + (row + _cellCenterOffset) * cellHeight;

          final backgroundPaint = Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.green.withValues(
              alpha: ConstLayout.cardStackOffsetLarge,
            );

          final circleRadius = _cellBadgeWidth / _half;
          canvas.drawCircle(
            Offset(cellCenterX, cellCenterY),
            circleRadius,
            backgroundPaint,
          );
          final textLeft = cellCenterX - (frontTextPainter.width / _half);
          final textTop = cellCenterY - (frontTextPainter.height / _half);

          backTextPainter.paint(
            canvas,
            Offset(
              textLeft + ConstLayout.strokeXS,
              textTop + ConstLayout.strokeXS,
            ),
          );

          frontTextPainter.paint(canvas, Offset(textLeft, textTop));
        }
      }
    }
  }

  @override
  bool shouldRepaint(_DetectionOverlayPainter old) =>
      old.detections != detections ||
      old.gridInference != gridInference ||
      old.overlayNumberStyle != overlayNumberStyle ||
      old.cellNumberStyle != cellNumberStyle ||
      old.contentRect != contentRect;
}

class _GridInference {
  _GridInference({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.badgeHeightNormalized,
    required this.valuesByCell,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double badgeHeightNormalized;
  final List<int?> valuesByCell;
}
