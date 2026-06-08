import 'dart:typed_data';

/// Abstract store for saving card correction samples used for model retraining.
abstract class CorrectionSampleStore {
  /// Saves a correction sample with the captured image and corrected label.
  Future<void> saveSample({
    required Uint8List imageBytes,
    required int wrongValue,
    required int correctedValue,
    required int cellIndex,
  });
}
