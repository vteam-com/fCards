// ignore: fcheck_dead_code
import 'dart:convert';
import 'dart:js_interop';

import 'package:cards/models/app/card_detection.dart';
import 'package:cards/models/app/tflite_rank_parser.dart';
import 'package:flutter/services.dart';

@JS('fcardsOrtInit')
external JSPromise<JSBoolean> _ortInit(JSUint8Array modelBytes);

@JS('fcardsOrtDetect')
external JSPromise<JSString> _ortDetect(
  JSUint8Array bytes,
  int w,
  int h,
  int inputSize,
  double threshold,
  JSArray<JSString> labels,
);

@JS('fcardsDetectFromImageBytes')
external JSPromise<JSString> _detectFromImageBytes(
  JSUint8Array imageBytes,
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
  static const String _defaultLabelsPath = 'assets/models/labels.txt';

  /// Public Joker score value used externally (e.g. default for undetected cells).
  static const int jokerRankValue = TfliteRankParser.jokerRankValue;

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

    // Use rootBundle.load() so Flutter resolves the asset path correctly on all
    // platforms (including web where assets are served at assets/assets/…).
    // Pass the raw bytes to JS to avoid any URL construction issues.
    final byteData = await rootBundle.load(modelPath);
    final modelBytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    await _ortInit(modelBytes.toJS).toDart;
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

  /// Web-only: decodes raw image bytes in the browser (handles HEIF/HEIC on
  /// iOS Safari via Canvas API), runs ONNX inference, and returns detections
  /// together with a JPEG of the resized image for display.
  Future<({List<CardDetection> detections, Uint8List jpegBytes})>
  detectFromRawBytes(Uint8List rawImageBytes) async {
    if (!_isLoaded) {
      return (detections: const <CardDetection>[], jpegBytes: Uint8List(0));
    }

    final labelArray = _labels.map((l) => l.toJS).toList().toJS;
    final jsJson = await _detectFromImageBytes(
      rawImageBytes.toJS,
      modelInputSize,
      confidenceThreshold,
      labelArray,
    ).toDart;

    final dynamic dartData = jsonDecode(jsJson.toDart);
    if (dartData is! Map) {
      return (detections: const <CardDetection>[], jpegBytes: Uint8List(0));
    }

    final detectionsRaw = dartData['detections'];
    final List<CardDetection> detections = detectionsRaw is List
        ? detectionsRaw.whereType<Map>().map((item) {
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
          }).toList()
        : const <CardDetection>[];

    final jpegBase64 = dartData['jpeg']?.toString() ?? '';
    final jpegBytes = jpegBase64.isNotEmpty
        ? base64Decode(jpegBase64)
        : Uint8List(0);

    return (detections: detections, jpegBytes: jpegBytes);
  }

  /// Normalizes a raw model label string to a canonical rank display name.
  static String _normalizeRankLabel(String label) =>
      TfliteRankParser.normalizeRankLabel(label);

  /// Converts a card rank label to its game score value.
  static int? labelToRankValue(String label) =>
      TfliteRankParser.labelToRankValue(label);
}
