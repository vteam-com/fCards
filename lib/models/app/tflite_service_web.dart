import 'dart:convert';
import 'dart:js_interop';

import 'package:cards/models/app/card_detection.dart';
import 'package:flutter/services.dart';

@JS('fcardsOrtInit')
external JSPromise<JSBoolean> _ortInit(String modelPath);

@JS('fcardsOrtDetect')
external JSPromise<JSString> _ortDetect(
  JSUint8Array bytes,
  int w,
  int h,
  int inputSize,
  double threshold,
  JSArray<JSString> labels,
);

/// Web fallback for TFLite service.
///
/// The `tflite_flutter` package depends on `dart:ffi`, which is not available
/// in web builds. This implementation uses ONNX Runtime Web via JS interop.
class TfliteService {
  TfliteService._();

  /// Singleton instance.
  static final TfliteService instance = TfliteService._();

  /// Square input size expected by the mobile model.
  static const int modelInputSize = 640;

  /// Minimum confidence score for a detection to be returned.
  /// Lower value improves recall for 3x3 grid cell filling.
  static const double confidenceThreshold = 0.2;

  static const String _defaultModelPath = 'assets/models/card_detector.onnx';
  static const String _defaultLabelsPath = 'assets/models/labels_web_52.txt';

  static const String _rankJoker = 'joker';
  static const String _rankAce = 'ace';
  static const String _rankJack = 'jack';
  static const String _rankQueen = 'queen';
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
  static const int _rankValueJoker = -2;

  /// Public Joker score value used externally (e.g. default for undetected cells).
  static const int jokerRankValue = _rankValueJoker;
  static const int _rankValueAce = 1;
  static const int _rankValueJack = 11;
  static const int _rankValueQueen = 12;
  static const int _rankValueKing = 0;

  bool _isLoaded = false;
  List<String> _labels = [];

  /// Returns true once loadModel was called.
  bool get isLoaded => _isLoaded;

  /// Loads the ONNX model and labels for browser inference.
  Future<void> loadModel({
    String modelPath = _defaultModelPath,
    String labelsPath = _defaultLabelsPath,
  }) async {
    final raw = await rootBundle.loadString(labelsPath);
    _labels = raw
        .trim()
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    await _ortInit(modelPath).toDart;
    _isLoaded = true;
  }

  /// Runs browser-side ONNX inference and parses detections.
  Future<List<CardDetection>> detect(
    Uint8List rgbaBytes,
    int imageWidth,
    int imageHeight,
  ) async {
    if (!_isLoaded) return const [];

    final labelArray = _labels.map((l) => l.toJS).toList().toJS;
    final jsJson = await _ortDetect(
      rgbaBytes.toJS,
      imageWidth,
      imageHeight,
      modelInputSize,
      confidenceThreshold,
      labelArray,
    ).toDart;

    final dynamic dartData = jsonDecode(jsJson.toDart);
    if (dartData is! List) return const [];

    return dartData.whereType<Map>().map((item) {
      final label = _normalizeRankLabel(item['label']?.toString() ?? '');
      final confidence = (item['confidence'] as num?)?.toDouble() ?? 0.0;
      final left = (item['left'] as num?)?.toDouble() ?? 0.0;
      final top = (item['top'] as num?)?.toDouble() ?? 0.0;
      final width = (item['width'] as num?)?.toDouble() ?? 0.0;
      final height = (item['height'] as num?)?.toDouble() ?? 0.0;
      return CardDetection(
        label: label,
        confidence: confidence,
        left: left,
        top: top,
        width: width,
        height: height,
      );
    }).toList();
  }

  /// No-op on web.
  void dispose() {
    _isLoaded = false;
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
