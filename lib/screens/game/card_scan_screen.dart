import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/card_detection.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/tflite_service.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:universal_platform/universal_platform.dart';

/// Screen that opens the device camera, captures a photo on demand, and
/// runs the on-device YOLOv8 TFLite model to detect and label playing cards.
///
/// ## Prerequisites
/// - `assets/models/card_detector.tflite` — your trained model.
/// - `assets/models/labels.txt` — one class name per line.
/// - Camera permissions granted (see Android / iOS manifests).
class CardScanScreen extends StatefulWidget {
  const CardScanScreen({super.key});

  @override
  State<CardScanScreen> createState() => _CardScanScreenState();
}

class _CardScanScreenState extends State<CardScanScreen> {
  static const int _expectedDetectedCards = 9;
  static const double _nmsIouThreshold = 0.35;
  static const int _gridDimension = 3;
  static const double _modelImageSize = TfliteService.modelInputSize * 1.0;
  static const double _scoreFontScale = 3.0;

  CameraController? _controller;
  List<CardDetection> _detections = [];
  _GridInference? _gridInference;
  Uint8List? _capturedImageBytes;
  String? _errorMessage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isCameraReady = false;
  bool _isScanning = false;

  bool get _isShowingCapturedResult => _capturedImageBytes != null;
  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadModel();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Screen(
      title: l10n.scanCardTitle,
      isWaiting: false,
      child: _buildBody(l10n),
    );
  }

  /// Selects the correct top-level body widget based on current state.
  Widget _buildBody(AppLocalizations l10n) {
    if (UniversalPlatform.isMacOS) {
      return _buildMacOsBody(l10n);
    }
    if (_errorMessage != null) {
      return _buildErrorView();
    }
    if (!_isCameraReady) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Expanded(child: _buildPreviewWithOverlay()),
        _buildScoreAndScanRow(l10n),
        const SizedBox(height: ConstLayout.paddingL),
      ],
    );
  }

  Widget _buildScoreAndScanRow(AppLocalizations l10n) {
    final isReviewMode = _isShowingCapturedResult;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ConstLayout.paddingM,
        vertical: ConstLayout.paddingS,
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: isReviewMode
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_calculateDetectedScore()}',
                        style: _scoreNumberStyle(
                          context,
                          fontSize: ConstLayout.textXL * _scoreFontScale,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: _buildScanButton(l10n),
            ),
          ),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  /// Renders the error message centred on screen.
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ConstLayout.paddingXXL),
        child: Text(
          _errorMessage!,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: ConstLayout.textS,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Builds the fallback UI for macOS where `camera` is not available.
  Widget _buildMacOsBody(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.photo_library,
          color: Colors.white,
          size: ConstLayout.iconL,
        ),
        const SizedBox(height: ConstLayout.paddingM),
        Text(
          l10n.scanMacosPhotoHint,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: ConstLayout.textS,
          ),
        ),
        const SizedBox(height: ConstLayout.paddingM),
        _buildScoreAndScanRow(l10n),
      ],
    );
  }

  /// Stacks the camera preview with the detection bounding-box overlay.
  Widget _buildPreviewWithOverlay() {
    final capturedImageBytes = _capturedImageBytes;
    final overlayNumberStyle = _scoreNumberStyle(
      context,
      fontSize: ConstLayout.textS,
    );
    final cellNumberStyle = _scoreNumberStyle(
      context,
      fontSize: ConstLayout.textM * _scoreFontScale,
    );
    if (capturedImageBytes == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (_detections.isNotEmpty)
            CustomPaint(
              painter: _DetectionOverlayPainter(
                detections: _detections,
                gridInference: _gridInference,
                overlayNumberStyle: overlayNumberStyle,
                cellNumberStyle: cellNumberStyle,
              ),
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        final destinationRect = _containedRect(
          canvasSize,
          const Size(_modelImageSize, _modelImageSize),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fromRect(
              rect: destinationRect,
              child: Image.memory(capturedImageBytes, fit: BoxFit.fill),
            ),
            if (_detections.isNotEmpty)
              CustomPaint(
                painter: _DetectionOverlayPainter(
                  detections: _detections,
                  gridInference: _gridInference,
                  overlayNumberStyle: overlayNumberStyle,
                  cellNumberStyle: cellNumberStyle,
                  contentRect: destinationRect,
                ),
              ),
          ],
        );
      },
    );
  }

  Rect _containedRect(Size canvasSize, Size sourceSize) {
    final fittedSizes = applyBoxFit(BoxFit.contain, sourceSize, canvasSize);
    final destinationSize = fittedSizes.destination;
    final dx = (canvasSize.width - destinationSize.width) / 2;
    final dy = (canvasSize.height - destinationSize.height) / 2;
    return Rect.fromLTWH(dx, dy, destinationSize.width, destinationSize.height);
  }

  TextStyle _scoreNumberStyle(
    BuildContext context, {
    required double fontSize,
  }) {
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

  /// SCAN button — danger style in preview, primary style in review.
  Widget _buildScanButton(AppLocalizations l10n) {
    final isShowingCapturedResult = _isShowingCapturedResult;
    if (isShowingCapturedResult) {
      return MyButtonRectangle.primary(
        onTap: _isScanning ? null : _resetToScanMode,
        child: const Icon(Icons.camera_alt),
      );
    }

    return MyButtonRectangle.danger(
      onTap: _isScanning ? null : _scan,
      child: _isScanning
          ? const SizedBox(
              width: ConstLayout.iconXS,
              height: ConstLayout.iconXS,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: ConstLayout.strokeS,
              ),
            )
          : const Text('SCAN'),
    );
  }

  /// Returns to live camera scan mode after reviewing captured score overlay.
  void _resetToScanMode() {
    setState(() {
      _capturedImageBytes = null;
      _detections = [];
      _gridInference = null;
      _errorMessage = null;
    });
  }

  int _calculateDetectedScore() {
    final gridInference = _gridInference;
    if (gridInference == null) {
      return 0;
    }

    int total = 0;
    for (final value in gridInference.valuesByCell) {
      total += value ?? TfliteService.jokerRankValue;
    }
    return total;
  }

  _GridInference? _inferGridFromDetections(List<CardDetection> detections) {
    if (detections.isEmpty) {
      return null;
    }

    final centersX = detections
        .map((d) => d.left + (d.width / 2))
        .toList()
      ..sort();
    final centersY = detections
        .map((d) => d.top + (d.height / 2))
        .toList()
      ..sort();

    final gridLeft = centersX.first;
    final gridRight = centersX.last;
    final gridTop = centersY.first;
    final gridBottom = centersY.last;

    final gridWidth = gridRight - gridLeft;
    final gridHeight = gridBottom - gridTop;
    if (gridWidth <= 0 || gridHeight <= 0) {
      return null;
    }

    // Undetected cells default to Joker (-2).
    final valuesByCell = List<int?>.filled(_expectedDetectedCards, TfliteService.jokerRankValue);
    final confidenceByCell = List<double>.filled(_expectedDetectedCards, 0);
    final minTopByCell = List<double?>.filled(_expectedDetectedCards, null);
    final maxBottomByCell = List<double?>.filled(_expectedDetectedCards, null);

    for (final detection in detections) {
      final cx = detection.left + (detection.width / 2);
      final cy = detection.top + (detection.height / 2);
      final normalizedX = (cx - gridLeft) / gridWidth;
      final normalizedY = (cy - gridTop) / gridHeight;

      final col = (normalizedX * _gridDimension).floor().clamp(
        0,
        _gridDimension - 1,
      );
      final row = (normalizedY * _gridDimension).floor().clamp(
        0,
        _gridDimension - 1,
      );
      final index = row * _gridDimension + col;

          final topY = detection.top;
          final bottomY = detection.top + detection.height;
          final minTop = minTopByCell[index];
          final maxBottom = maxBottomByCell[index];
          minTopByCell[index] = minTop == null || topY < minTop ? topY : minTop;
          maxBottomByCell[index] =
            maxBottom == null || bottomY > maxBottom ? bottomY : maxBottom;

      if (detection.confidence < confidenceByCell[index]) {
        continue;
      }

      confidenceByCell[index] = detection.confidence;
      valuesByCell[index] = TfliteService.labelToRankValue(detection.label);
    }

    double tallestDetectedSpan = 0;
    for (int i = 0; i < _expectedDetectedCards; i++) {
      final minTop = minTopByCell[i];
      final maxBottom = maxBottomByCell[i];
      if (minTop == null || maxBottom == null) {
        continue;
      }
      final span = maxBottom - minTop;
      if (span > tallestDetectedSpan) {
        tallestDetectedSpan = span;
      }
    }

    if (tallestDetectedSpan <= 0) {
      for (final detection in detections) {
        if (detection.height > tallestDetectedSpan) {
          tallestDetectedSpan = detection.height;
        }
      }
    }

    return _GridInference(
      left: gridLeft,
      top: gridTop,
      width: gridWidth,
      height: gridHeight,
      badgeHeightNormalized: tallestDetectedSpan,
      valuesByCell: valuesByCell,
    );
  }

  List<CardDetection> _deduplicateDetections(List<CardDetection> detections) {
    if (detections.isEmpty) {
      return const [];
    }

    final sorted = [...detections]
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final kept = <CardDetection>[];

    for (final candidate in sorted) {
      final overlapsExisting = kept.any(
        (existing) => _iou(candidate, existing) >= _nmsIouThreshold,
      );
      if (!overlapsExisting) {
        kept.add(candidate);
      }
    }

    return kept;
  }

  double _iou(CardDetection a, CardDetection b) {
    final left = a.left > b.left ? a.left : b.left;
    final top = a.top > b.top ? a.top : b.top;
    final right =
        (a.left + a.width) < (b.left + b.width)
            ? (a.left + a.width)
            : (b.left + b.width);
    final bottom =
        (a.top + a.height) < (b.top + b.height)
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

  /// Decodes bytes, runs model inference, and stores sorted detections.
  Future<void> _detectFromRawBytes(
    Uint8List rawBytes,
    AppLocalizations l10n,
  ) async {
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw Exception(l10n.scanFailedDecode);
    }

    final oriented = img.bakeOrientation(decoded);

    final resized = img.copyResize(
      oriented,
      width: TfliteService.modelInputSize,
      height: TfliteService.modelInputSize,
    );
    final renderBytes = Uint8List.fromList(img.encodeJpg(resized));

    final rgbaBytes = resized.getBytes(order: img.ChannelOrder.rgba);
    final detections = await TfliteService.instance.detect(
      rgbaBytes,
      TfliteService.modelInputSize,
      TfliteService.modelInputSize,
    );
    final deduplicatedDetections = _deduplicateDetections(detections);
    // Use the full candidate set for cell inference to maximize recall.
    final gridInference =
        _inferGridFromDetections(detections) ??
        _inferGridFromDetections(deduplicatedDetections);

    if (mounted) {
      setState(() {
        _capturedImageBytes = renderBytes;
        _detections = deduplicatedDetections;
        _gridInference = gridInference;
      });
    }
  }

  /// Discovers available cameras and initializes the front-facing one.
  Future<void> _initCamera() async {
    if (UniversalPlatform.isMacOS) {
      setState(() => _isCameraReady = true);
      return;
    }
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(
          () => _errorMessage = AppLocalizations.of(context).scanNoCameraFound,
        );
        return;
      }
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isCameraReady = true;
      });
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage =
              '${AppLocalizations.of(context).scanCameraError}$e',
        );
      }
    }
  }

  /// Loads the TFLite model in the background; sets [_errorMessage] on failure.
  Future<void> _loadModel() async {
    try {
      await TfliteService.instance.loadModel();
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage =
              '${AppLocalizations.of(context).scanModelError}$e',
        );
      }
    }
  }

  /// Captures a still frame, runs TFLite inference, and updates [_detections].
  Future<void> _scan() async {
    if (UniversalPlatform.isMacOS) {
      await _scanFromPickedImage();
      return;
    }

    final controller = _controller;
    if (_isScanning || controller == null || !controller.value.isInitialized) {
      return;
    }
    // Capture all localizations before any async gap.
    final l10n = AppLocalizations.of(context);
    if (!TfliteService.instance.isLoaded) {
      setState(() => _errorMessage = l10n.scanModelLoading);
      return;
    }

    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      final xFile = await controller.takePicture();
      final rawBytes = await xFile.readAsBytes();

      await _detectFromRawBytes(rawBytes, l10n);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  /// Picks an image from the macOS photo library and runs TFLite inference.
  Future<void> _scanFromPickedImage() async {
    if (_isScanning) return;
    final l10n = AppLocalizations.of(context);
    if (!TfliteService.instance.isLoaded) {
      setState(() => _errorMessage = l10n.scanModelLoading);
      return;
    }

    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final rawBytes = await image.readAsBytes();

      await _detectFromRawBytes(rawBytes, l10n);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }
}

// ── Bounding box painter ───────────────────────────────────────────────────────

class _DetectionOverlayPainter extends CustomPainter {
  static const double _cellBadgeWidth = ConstLayout.iconXL;
  static const double _fallbackCellBadgeHeight = ConstLayout.iconL;

  const _DetectionOverlayPainter(
    {
      required this.detections,
      required this.gridInference,
      required this.overlayNumberStyle,
      required this.cellNumberStyle,
      this.contentRect,
    }
  );

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
        final inferredBadgeHeight = grid.badgeHeightNormalized * size.height;
        final cellBadgeHeight = inferredBadgeHeight > 0
          ? inferredBadgeHeight
          : _fallbackCellBadgeHeight;

      for (int row = 0; row < _CardScanScreenState._gridDimension; row++) {
        for (int col = 0; col < _CardScanScreenState._gridDimension; col++) {
          final index = row * _CardScanScreenState._gridDimension + col;
          final value = grid.valuesByCell[index];
          final displayText = value?.toString() ?? '${TfliteService.jokerRankValue}';

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

          final backgroundRect = RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(
                gridLeft + (col + 0.5) * cellWidth,
                gridTop + (row + 0.5) * cellHeight,
              ),
              width: _cellBadgeWidth,
              height: cellBadgeHeight,
            ),
            const Radius.circular(ConstLayout.radiusM),
          );

          final backgroundPaint = Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.green.withValues(
              alpha: ConstLayout.cardStackOffsetLarge,
            );

          canvas.drawRRect(backgroundRect, backgroundPaint);

          final cellCenterX = gridLeft + (col + 0.5) * cellWidth;
          final cellCenterY = gridTop + (row + 0.5) * cellHeight;
          final textLeft = cellCenterX - (frontTextPainter.width / 2);
          final textTop = cellCenterY - (frontTextPainter.height / 2);

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
