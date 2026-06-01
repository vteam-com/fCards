import 'dart:typed_data';

import 'package:cards/models/app/card_detection.dart';
import 'package:cards/models/app/tflite_rank_parser.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Loads a YOLOv8 TFLite model and runs card detection inference.
class TfliteService {
  TfliteService._();

  /// Singleton instance.
  static final TfliteService instance = TfliteService._();

  static const String _defaultModelPath = 'assets/models/card_detector.tflite';
  static const String _defaultLabelsPath = 'assets/models/labels.txt';

  /// Square input size expected by the model (must match the training imgsz).
  static const int modelInputSize = 640;

  /// Minimum confidence score for a detection to be returned.
  /// Lower value improves recall for 3x3 grid cell filling.
  static const double confidenceThreshold = 0.2;

  /// Fallback threshold used only when no detection passes the primary threshold.
  static const double relaxedConfidenceThreshold = 0.1;

  /// Number of bytes per RGBA pixel.
  static const int _rgbaChannelCount = 4;

  /// Number of channels expected by RGB model input.
  static const int _rgbChannelCount = 3;

  /// Rank expected by image model input tensors: [N, H, W, C] or [N, C, H, W].
  static const int _inputTensorRank = 4;

  /// Batch size used for single-image inference.
  static const int _singleBatchSize = 1;

  static const int _shapeIndexBatch = 0;
  static const int _shapeIndexOne = 1;
  static const int _shapeIndexTwo = 2;
  static const int _shapeIndexThree = 3;

  /// Max value of a single byte channel, used to normalise to [0, 1].
  static const double _rgbMaxValue = 255.0;

  /// Number of bounding-box coordinate features before class scores in YOLOv8 output.
  /// These represent: cx, cy, width, height.
  static const int _bboxFeatureCount = 4;

  /// Divisor used to compute a box edge from its centre and half-dimension.
  static const double _halfDivisor = 2.0;

  /// Index of the column dimension in the YOLOv8 TFLite output tensor [1, rows, cols].
  static const int _tensorColsDim = 2;

  /// Byte offset of the green channel within an RGBA pixel.
  static const int _rgbGreenOffset = 1;

  /// Byte offset of the blue channel within an RGBA pixel.
  static const int _rgbBlueOffset = 2;

  /// YOLOv8 output row index for the normalised bounding-box width.
  static const int _yoloBwIndex = 2;

  /// YOLOv8 output row index for the normalised bounding-box height.
  static const int _yoloBhIndex = 3;

  /// Public Joker score value used externally (e.g. default for undetected cells).
  static const int jokerRankValue = TfliteRankParser.jokerRankValue;

  Interpreter? _interpreter;
  List<String> _labels = [];

  /// Whether the model has been successfully loaded.
  bool get isLoaded => _interpreter != null && _labels.isNotEmpty;

  /// Loads the TFLite model and labels file from Flutter assets.
  Future<void> loadModel({
    String modelPath = _defaultModelPath,
    String labelsPath = _defaultLabelsPath,
  }) async {
    _interpreter?.close();
    _interpreter = await Interpreter.fromAsset(modelPath);

    final raw = await rootBundle.loadString(labelsPath);
    _labels = raw
        .trim()
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Runs card detection on a flat RGBA pixel buffer.
  Future<List<CardDetection>> detect(
    Uint8List rgbaBytes,
    int imageWidth,
    int imageHeight,
  ) async {
    final interpreter = _interpreter;
    if (interpreter == null || _labels.isEmpty) return const [];

    final inputShape = interpreter.getInputTensor(0).shape;
    final input = _buildInputTensor(
      rgbaBytes,
      imageWidth,
      imageHeight,
      inputShape,
    );
    final outputShape = interpreter.getOutputTensor(0).shape;
    // YOLOv8 TFLite can export in two layouts:
    //   [1, features, anchors]  e.g. [1, 56, 8400]  — features-first
    //   [1, anchors, features]  e.g. [1, 8400, 56]  — anchors-first
    // Detect layout by assuming features (4 + numClasses) << anchors (8400).
    final dim1 = outputShape[1];
    final dim2 = outputShape[_tensorColsDim];
    final bool featuresFirst = dim1 < dim2;
    final int numFeatures = featuresFirst ? dim1 : dim2;
    final int numAnchors = featuresFirst ? dim2 : dim1;

    // Allocate the full 3-D buffer matching the actual output shape.
    final outputBuffer = List<List<List<double>>>.generate(
      _singleBatchSize,
      (_) => List<List<double>>.generate(
        dim1,
        (_) => List<double>.filled(dim2, 0.0),
      ),
    );
    interpreter.runForMultipleInputs([input], {0: outputBuffer});

    // Flatten and normalise to features-first layout [features, anchors]
    // so _parseYoloOutput always sees the same index arithmetic.
    final rows = outputBuffer[0];
    final outputFlat = Float32List(numFeatures * numAnchors);
    if (featuresFirst) {
      // Already [features, anchors] — copy straight through.
      for (int r = 0; r < numFeatures; r++) {
        final row = rows[r];
        for (int c = 0; c < numAnchors; c++) {
          outputFlat[r * numAnchors + c] = row[c];
        }
      }
    } else {
      // Transpose from [anchors, features] to [features, anchors].
      for (int a = 0; a < numAnchors; a++) {
        final row = rows[a];
        for (int f = 0; f < numFeatures; f++) {
          outputFlat[f * numAnchors + a] = row[f];
        }
      }
    }

    final detections = _parseYoloOutput(
      outputFlat,
      numFeatures,
      numAnchors,
      confidenceThreshold,
    );
    if (detections.isNotEmpty) {
      return detections;
    }
    return _parseYoloOutput(
      outputFlat,
      numFeatures,
      numAnchors,
      relaxedConfidenceThreshold,
    );
  }

  /// Nearest-neighbour resize + normalise to [modelInputSize]×[modelInputSize].
  Object _buildInputTensor(
    Uint8List rgba,
    int srcW,
    int srcH,
    List<int> inputShape,
  ) {
    if (inputShape.length != _inputTensorRank ||
        inputShape[_shapeIndexBatch] != _singleBatchSize) {
      throw UnsupportedError('Unsupported input tensor shape: $inputShape');
    }

    final secondDim = inputShape[_shapeIndexOne];
    final thirdDim = inputShape[_shapeIndexTwo];
    final fourthDim = inputShape[_shapeIndexThree];

    // Supports both [1, H, W, 3] (NHWC) and [1, 3, H, W] (NCHW) layouts.
    if (fourthDim == _rgbChannelCount) {
      final height = secondDim;
      final width = thirdDim;
      return [
        List.generate(
          height,
          (y) => List.generate(width, (x) {
            final srcX = (x * srcW ~/ width).clamp(0, srcW - 1);
            final srcY = (y * srcH ~/ height).clamp(0, srcH - 1);
            final idx = (srcY * srcW + srcX) * _rgbaChannelCount;
            return [
              rgba[idx] / _rgbMaxValue,
              rgba[idx + _rgbGreenOffset] / _rgbMaxValue,
              rgba[idx + _rgbBlueOffset] / _rgbMaxValue,
            ];
          }),
        ),
      ];
    }

    if (secondDim == _rgbChannelCount) {
      final height = thirdDim;
      final width = fourthDim;
      return [
        List.generate(_rgbChannelCount, (channel) {
          return List.generate(height, (y) {
            return List.generate(width, (x) {
              final srcX = (x * srcW ~/ width).clamp(0, srcW - 1);
              final srcY = (y * srcH ~/ height).clamp(0, srcH - 1);
              final idx = (srcY * srcW + srcX) * _rgbaChannelCount;
              return switch (channel) {
                0 => rgba[idx] / _rgbMaxValue,
                _rgbGreenOffset => rgba[idx + _rgbGreenOffset] / _rgbMaxValue,
                _ => rgba[idx + _rgbBlueOffset] / _rgbMaxValue,
              };
            });
          });
        }),
      ];
    }

    throw UnsupportedError('Unsupported input tensor shape: $inputShape');
  }

  /// Parses the raw YOLOv8 output (flat [numRows × numCols] buffer, layout
  /// [4+numClasses, numBoxes]) into [CardDetection] objects.
  List<CardDetection> _parseYoloOutput(
    Float32List flat,
    int numRows,
    int numCols,
    double minConfidence,
  ) {
    final availableClasses = numRows - _bboxFeatureCount;
    final numClasses = _labels.length < availableClasses
        ? _labels.length
        : availableClasses;
    final numBoxes = numCols;
    final detections = <CardDetection>[];

    for (int i = 0; i < numBoxes; i++) {
      double maxScore = 0.0;
      int maxClass = 0;
      for (int c = 0; c < numClasses; c++) {
        // flat index for [row, col] where row = _bboxFeatureCount + c, col = i
        final score = flat[(_bboxFeatureCount + c) * numCols + i];
        if (score > maxScore) {
          maxScore = score;
          maxClass = c;
        }
      }
      if (maxScore < minConfidence) continue;

      final cx = flat[i];
      final cy = flat[numCols + i];
      final bw = flat[_yoloBwIndex * numCols + i];
      final bh = flat[_yoloBhIndex * numCols + i];

      detections.add(
        CardDetection(
          label: _normalizeRankLabel(
            maxClass < _labels.length ? _labels[maxClass] : '',
          ),
          confidence: maxScore,
          left: (cx - bw / _halfDivisor).clamp(0.0, 1.0),
          top: (cy - bh / _halfDivisor).clamp(0.0, 1.0),
          width: bw.clamp(0.0, 1.0),
          height: bh.clamp(0.0, 1.0),
        ),
      );
    }

    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    return detections;
  }

  /// Releases the TFLite interpreter.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = [];
  }

  /// Not used on native platforms; exists only to satisfy the shared interface
  /// called from web-guarded code paths.
  Future<({List<CardDetection> detections, Uint8List jpegBytes})>
  detectFromRawBytes(Uint8List rawImageBytes) async {
    return (
      detections: const <CardDetection>[],
      jpegBytes: rawImageBytes.sublist(0, 0),
    );
  }

  /// Normalizes a raw model label string to a canonical rank display name.
  static String _normalizeRankLabel(String label) =>
      TfliteRankParser.normalizeRankLabel(label);

  /// Converts a card rank label to its game score value.
  static int? labelToRankValue(String label) =>
      TfliteRankParser.labelToRankValue(label);
}
