import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/card_detection.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/correction_sample_store.dart';
import 'package:cards/models/app/correction_sample_store_factory.dart';
import 'package:cards/models/app/tflite_rank_parser.dart';
import 'package:cards/models/app/tflite_service.dart';
import 'package:cards/screens/game/card_scan_helpers.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/buttons/my_button_round.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:universal_platform/universal_platform.dart';

part 'card_scan_overlay.dart';

/// Screen that opens the device camera, captures a photo on demand, and
/// runs the on-device YOLOv8 TFLite model to detect and label playing cards.
///
/// ## Prerequisites
/// - `assets/models/card_detector.tflite` — your trained model.
/// - `assets/models/labels.txt` — one class name per line.
/// - Camera permissions granted (see Android / iOS manifests).
class CardScanScreen extends StatefulWidget {
  const CardScanScreen({super.key, this.onScoreConfirmed});

  /// Optional callback invoked when the user confirms a detected score.
  /// When provided, a confirm button appears in review mode that passes
  /// the calculated score to this callback and pops the screen.
  final void Function(int score)? onScoreConfirmed;

  @override
  State<CardScanScreen> createState() => _CardScanScreenState();
}

class _CardScanScreenState extends State<CardScanScreen> {
  CameraDescription? _activeCamera;
  Uint8List? _capturedImageBytes;
  CameraController? _controller;
  final CorrectionSampleStore _correctionStore = createCorrectionSampleStore();
  static const List<int> _correctionValues = <int>[
    TfliteService.jokerRankValue,
    TfliteRankParser.rankValueKing,
    TfliteRankParser.rankValueAce,
    _minNumericCardValue,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    TfliteRankParser.rankValueJack,
    TfliteRankParser.rankValueQueen,
  ];
  List<CardDetection> _detections = [];
  String? _errorMessage;
  static const int _expectedDetectedCards = 9;
  static const int _gridDimension = 3;
  _GridInference? _gridInference;
  static const double _half = 2.0;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isCameraReady = false;
  bool _isModelLoading = false;
  bool _isScanning = false;
  static const int _minNumericCardValue = 2;
  static const double _modelImageSize = TfliteService.modelInputSize * 1.0;
  static const double _nmsIouThreshold = 0.35;
  static const double _scoreFontScale = 3.0;
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
    if (_isShowingCapturedResult) {
      return _buildCapturedResultBody(l10n);
    }
    if (UniversalPlatform.isMacOS) {
      return _buildMacOsBody(l10n);
    }
    if (UniversalPlatform.isWeb) {
      return _buildWebBody(l10n);
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

  /// Shows the captured image with detection overlays on all platforms.
  Widget _buildCapturedResultBody(AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(child: _buildPreviewWithOverlay()),
        _buildScoreAndScanRow(l10n),
        if (_gridInference != null)
          Text(
            l10n.scanTapToCorrect,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: ConstLayout.textS,
            ),
          ),
        const SizedBox(height: ConstLayout.paddingL),
      ],
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

  /// Shared file-picker UI used on macOS and web.
  Widget _buildFilePickerBody(AppLocalizations l10n, String hint) {
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
          hint,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: ConstLayout.textS,
          ),
        ),
        if (_errorMessage != null) ...<Widget>[
          const SizedBox(height: ConstLayout.paddingS),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: ConstLayout.textS,
            ),
          ),
        ],
        const SizedBox(height: ConstLayout.paddingM),
        _buildScoreAndScanRow(l10n),
      ],
    );
  }

  /// Builds the fallback UI for macOS where `camera` is not available.
  Widget _buildMacOsBody(AppLocalizations l10n) =>
      _buildFilePickerBody(l10n, l10n.scanMacosPhotoHint);

  /// Stacks the camera preview with the detection bounding-box overlay.
  Widget _buildPreviewWithOverlay() {
    final capturedImageBytes = _capturedImageBytes;
    final overlayNumberStyle = scoreNumberStyle(
      context,
      fontSize: ConstLayout.textS,
    );
    final cellNumberStyle = scoreNumberStyle(
      context,
      fontSize: ConstLayout.textM * _scoreFontScale,
    );
    if (capturedImageBytes == null) {
      final preview = CameraPreview(_controller!);
      return Stack(
        fit: StackFit.expand,
        children: [
          _shouldFlipHorizontally
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
                  child: preview,
                )
              : preview,
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
      builder: (_, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        final destinationRect = containedRect(
          canvasSize,
          const Size(_modelImageSize, _modelImageSize),
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => _handleReviewTap(details, destinationRect),
          child: Stack(
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
          ),
        );
      },
    );
  }

  /// SCAN button — danger style in preview, primary style in review.
  Widget _buildScanButton() {
    final isShowingCapturedResult = _isShowingCapturedResult;
    if (isShowingCapturedResult) {
      return MyButtonRectangle.primary(
        onTap: _isScanning ? null : _resetToScanMode,
        child: const Icon(Icons.camera_alt),
      );
    }

    final isModelLoaded = TfliteService.instance.isLoaded;
    final canScan = !_isScanning && !_isModelLoading && isModelLoaded;

    return MyButtonRound(
      onTap: canScan ? _scan : null,
      size: ConstLayout.buttonWidth,
      child: _isScanning || _isModelLoading
          ? const SizedBox(
              width: ConstLayout.iconXS,
              height: ConstLayout.iconXS,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: ConstLayout.strokeS,
              ),
            )
          : canScan
          ? const Icon(Icons.camera_alt, size: ConstLayout.iconXL)
          : const Icon(Icons.hourglass_empty, size: ConstLayout.iconXL),
    );
  }

  /// Builds the bottom row showing the current detected score and the SCAN/retake button.
  Widget _buildScoreAndScanRow(AppLocalizations _) {
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
                        style: scoreNumberStyle(
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
              child: _buildScanButton(),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  isReviewMode &&
                      widget.onScoreConfirmed != null &&
                      _gridInference != null
                  ? MyButtonRound(
                      onTap: () {
                        widget.onScoreConfirmed!(_calculateDetectedScore());
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.check),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the UI for web where the camera is replaced by a file picker.
  Widget _buildWebBody(AppLocalizations l10n) =>
      _buildFilePickerBody(l10n, l10n.scanWebPhotoHint);

  /// Sums the score for all 9 grid cells; undetected cells count as Joker (-2).
  int _calculateDetectedScore() {
    final gridInference = _gridInference;
    if (gridInference == null) {
      return 0;
    }

    final values = gridInference.valuesByCell;
    final isZeroScored = gridInference.zeroScoredCells;

    int total = 0;
    for (int i = 0; i < values.length; i++) {
      if (!isZeroScored[i]) {
        total += values[i] ?? TfliteService.jokerRankValue;
      }
    }
    return total;
  }

  /// Removes overlapping detections using non-maximum suppression (NMS).
  List<CardDetection> _deduplicateDetections(List<CardDetection> detections) {
    if (detections.isEmpty) {
      return const [];
    }

    final sorted = [...detections]
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final kept = <CardDetection>[];

    for (final candidate in sorted) {
      final overlapsExisting = kept.any(
        (existing) => iou(candidate, existing) >= _nmsIouThreshold,
      );
      if (!overlapsExisting) {
        kept.add(candidate);
      }
    }

    return kept;
  }

  /// Decodes bytes, runs model inference, and stores sorted detections.
  Future<void> _detectFromRawBytes(
    Uint8List rawBytes,
    AppLocalizations l10n,
  ) async {
    if (UniversalPlatform.isWeb) {
      final result = await TfliteService.instance.detectFromRawBytes(rawBytes);
      if (result.jpegBytes.isEmpty) {
        throw Exception(l10n.scanFailedDecode);
      }
      final deduplicatedDetections = _deduplicateDetections(result.detections);
      final gridInference =
          _inferGridFromDetections(result.detections) ??
          _inferGridFromDetections(deduplicatedDetections);
      if (mounted) {
        setState(() {
          _capturedImageBytes = result.jpegBytes;
          _detections = deduplicatedDetections;
          _gridInference = gridInference;
        });
      }
      return;
    }

    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw Exception(l10n.scanFailedDecode);
    }

    var oriented = img.bakeOrientation(decoded);
    if (_shouldFlipHorizontally) {
      oriented = img.flipHorizontal(oriented);
    }

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

  /// Handles a tap on the review overlay: identifies the tapped grid cell and
  /// opens the correction dialog for that cell.
  Future<void> _handleReviewTap(TapUpDetails details, Rect contentRect) async {
    final grid = _gridInference;
    if (!_isShowingCapturedResult || grid == null) {
      return;
    }

    final gridRect = Rect.fromLTWH(
      contentRect.left + grid.left * contentRect.width,
      contentRect.top + grid.top * contentRect.height,
      grid.width * contentRect.width,
      grid.height * contentRect.height,
    );
    final localPos = details.localPosition;
    if (!gridRect.contains(localPos)) {
      return;
    }

    final relativeX = (localPos.dx - gridRect.left) / gridRect.width;
    final relativeY = (localPos.dy - gridRect.top) / gridRect.height;
    final col = (relativeX * _gridDimension).floor().clamp(
      0,
      _gridDimension - 1,
    );
    final row = (relativeY * _gridDimension).floor().clamp(
      0,
      _gridDimension - 1,
    );
    final cellIndex = row * _gridDimension + col;

    await _showCorrectionDialog(cellIndex);
  }

  /// Divides detections into a 3×3 grid and returns per-cell score values.
  _GridInference? _inferGridFromDetections(List<CardDetection> detections) {
    if (detections.isEmpty) {
      return null;
    }

    final centersX = detections.map((d) => d.left + (d.width / _half)).toList()
      ..sort();
    final centersY = detections.map((d) => d.top + (d.height / _half)).toList()
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
    final valuesByCell = List<int?>.filled(
      _expectedDetectedCards,
      TfliteService.jokerRankValue,
    );
    final confidenceByCell = List<double>.filled(_expectedDetectedCards, 0);
    final minTopByCell = List<double?>.filled(_expectedDetectedCards, null);
    final maxBottomByCell = List<double?>.filled(_expectedDetectedCards, null);

    for (final detection in detections) {
      final cx = detection.left + (detection.width / _half);
      final cy = detection.top + (detection.height / _half);
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
      maxBottomByCell[index] = maxBottom == null || bottomY > maxBottom
          ? bottomY
          : maxBottom;

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
      zeroScoredCells: computeZeroScoredCells(valuesByCell, _gridDimension),
    );
  }

  /// Discovers available cameras and initializes the preferred camera.
  Future<void> _initCamera() async {
    if (UniversalPlatform.isMacOS || UniversalPlatform.isWeb) {
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
      var selectedCamera = cameras.first;
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selectedCamera = camera;
          break;
        }
      }

      final controller = CameraController(
        selectedCamera,
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
        _activeCamera = selectedCamera;
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

  bool get _isShowingCapturedResult => _capturedImageBytes != null;

  /// Loads the TFLite model in the background; sets [_errorMessage] on failure.
  Future<void> _loadModel() async {
    if (mounted) {
      setState(() => _isModelLoading = true);
    }
    try {
      await TfliteService.instance.loadModel();
    } catch (e, stack) {
      logger.e('TFLite model load failed', e, stack);
      if (mounted) {
        setState(
          () => _errorMessage =
              '${AppLocalizations.of(context).scanModelError}$e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isModelLoading = false);
      }
    }
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

  /// Crops the cell image from the captured photo and writes the sample to the
  /// [_correctionStore] for later model retraining.
  Future<void> _saveCorrectionSample({
    required int cellIndex,
    required int wrongValue,
    required int correctedValue,
  }) async {
    final capturedImageBytes = _capturedImageBytes;
    final grid = _gridInference;
    if (capturedImageBytes == null || grid == null) {
      return;
    }

    final decoded = img.decodeImage(capturedImageBytes);
    if (decoded == null) {
      return;
    }

    final row = cellIndex ~/ _gridDimension;
    final col = cellIndex % _gridDimension;
    final cellWidthNorm = grid.width / _gridDimension;
    final cellHeightNorm = grid.height / _gridDimension;

    final leftNorm = grid.left + col * cellWidthNorm;
    final topNorm = grid.top + row * cellHeightNorm;
    final rightNorm = leftNorm + cellWidthNorm;
    final bottomNorm = topNorm + cellHeightNorm;

    final left = (leftNorm * decoded.width).round().clamp(0, decoded.width - 1);
    final top = (topNorm * decoded.height).round().clamp(0, decoded.height - 1);
    final right = (rightNorm * decoded.width).round().clamp(1, decoded.width);
    final bottom = (bottomNorm * decoded.height).round().clamp(
      1,
      decoded.height,
    );
    final cropWidth = (right - left).clamp(1, decoded.width - left);
    final cropHeight = (bottom - top).clamp(1, decoded.height - top);

    final cropped = img.copyCrop(
      decoded,
      x: left,
      y: top,
      width: cropWidth,
      height: cropHeight,
    );

    await _correctionStore.saveSample(
      imageBytes: Uint8List.fromList(img.encodeJpg(cropped)),
      wrongValue: wrongValue,
      correctedValue: correctedValue,
      cellIndex: cellIndex,
    );
  }

  /// Captures a still frame, runs TFLite inference, and updates [_detections].
  Future<void> _scan() async {
    if (UniversalPlatform.isMacOS || UniversalPlatform.isWeb) {
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

  bool get _shouldFlipHorizontally =>
      UniversalPlatform.isWeb &&
      _activeCamera?.lensDirection == CameraLensDirection.front;

  /// Presents a dropdown dialog for the user to correct the detected card value
  /// at [cellIndex], then persists the sample for model retraining.
  Future<void> _showCorrectionDialog(int cellIndex) async {
    final grid = _gridInference;
    if (grid == null) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final currentValue =
        grid.valuesByCell[cellIndex] ?? TfliteService.jokerRankValue;

    final correctedValue = await showCardCorrectionDialog(
      context: context,
      l10n: l10n,
      currentValue: currentValue,
      correctionValues: _correctionValues,
    );

    if (!mounted || correctedValue == null) {
      return;
    }
    if (correctedValue == currentValue) {
      return;
    }

    setState(() {
      grid.valuesByCell[cellIndex] = correctedValue;
    });

    await _saveCorrectionSample(
      cellIndex: cellIndex,
      wrongValue: currentValue,
      correctedValue: correctedValue,
    );

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.scanCorrectionSaved)));
  }
}
