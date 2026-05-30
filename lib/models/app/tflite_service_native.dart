import 'dart:typed_data';

import 'package:cards/models/app/card_detection.dart';
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
  static const double relaxedConfidenceThreshold = 0.2;

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

  /// Card rank label for Ace.
  static const String _rankJoker = 'joker';

  /// Card rank label for Ace.
  static const String _rankAce = 'ace';

  /// Card rank label for Jack.
  static const String _rankJack = 'jack';

  /// Card rank label for Queen.
  static const String _rankQueen = 'queen';

  /// Card rank label for King.
  static const String _rankKing = 'king';

  static const String _displayJoker = 'Joker';
  static const String _displayAce = 'Ace';
  static const String _displayJack = 'Jack';
  static const String _displayQueen = 'Queen';
  static const String _displayKing = 'King';
  static const String _shortAce = 'a';
  static const String _shortJack = 'j';
  static const String _shortQueen = 'q';
  static const String _shortKing = 'k';

  /// Numeric value for Joker.
  static const int _rankValueJoker = -2;

  /// Public Joker score value used externally (e.g. default for undetected cells).
  static const int jokerRankValue = _rankValueJoker;

  /// Numeric value for Ace (lowest card).
  static const int _rankValueAce = 1;

  /// Numeric value for Jack.
  static const int _rankValueJack = 11;

  /// Numeric value for Queen.
  static const int _rankValueQueen = 12;

  /// Numeric value for King.
  static const int _rankValueKing = 0;

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
    final numRows = outputShape[1]; // 56 for YOLOv8 (4 bbox + 52 classes)
    final numCols = outputShape[_tensorColsDim]; // 8400 anchor boxes

    // Allocate the full [1, numRows, numCols] 3-D buffer explicitly so
    // tflite_flutter's native copy writes into the correct nested structure.
    final outputBuffer = List<List<List<double>>>.generate(
      _singleBatchSize,
      (_) => List<List<double>>.generate(
        numRows,
        (_) => List<double>.filled(numCols, 0.0),
      ),
    );
    interpreter.runForMultipleInputs([input], {0: outputBuffer});

    // Flatten rows to Float32List for fast index arithmetic in the parser.
    final rows = outputBuffer[0];
    final outputFlat = Float32List(numRows * numCols);
    for (int r = 0; r < numRows; r++) {
      final row = rows[r];
      for (int c = 0; c < numCols; c++) {
        outputFlat[r * numCols + c] = row[c];
      }
    }

    final detections = _parseYoloOutput(
      outputFlat,
      numCols,
      confidenceThreshold,
    );
    if (detections.isNotEmpty) {
      return detections;
    }
    return _parseYoloOutput(outputFlat, numCols, relaxedConfidenceThreshold);
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
    int numCols,
    double minConfidence,
  ) {
    final numClasses = _labels.length;
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
          label: _normalizeRankLabel(_labels[maxClass]),
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

  static String _normalizeRankLabel(String label) {
    final normalized = label.toLowerCase().trim();

    if (normalized.contains(_rankJoker)) {
      return _displayJoker;
    }

    if (normalized.contains('_of_')) {
      final rank = normalized.split('_of_').first;
      return _toDisplayRank(rank);
    }

    final compact = RegExp(r'^(10|[2-9]|[ajqk])[cdhs]$');
    if (compact.hasMatch(normalized)) {
      final rank = normalized.substring(0, normalized.length - 1);
      return _toDisplayRank(rank);
    }

    return _toDisplayRank(normalized);
  }

  static String _toDisplayRank(String rank) {
    return switch (rank) {
      '2' => '2',
      '3' => '3',
      '4' => '4',
      '5' => '5',
      '6' => '6',
      '7' => '7',
      '8' => '8',
      '9' => '9',
      '10' => '10',
      _rankJoker => _displayJoker,
      _shortAce || _rankAce => _displayAce,
      _shortJack || _rankJack => _displayJack,
      _shortQueen || _rankQueen => _displayQueen,
      _shortKing || _rankKing => _displayKing,
      _ => _displayJoker,
    };
  }

  /// Converts a card rank label to its game score value.
  static int? labelToRankValue(String label) {
    final normalized = _normalizeRankLabel(label).toLowerCase().trim();
    return switch (normalized) {
      _rankJoker => _rankValueJoker,
      _rankAce => _rankValueAce,
      _rankJack => _rankValueJack,
      _rankQueen => _rankValueQueen,
      _rankKing => _rankValueKing,
      _ => int.tryParse(normalized),
    };
  }
}
