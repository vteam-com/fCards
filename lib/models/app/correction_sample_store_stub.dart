import 'dart:typed_data';

import 'package:cards/models/app/correction_sample_store.dart';

class _NoopCorrectionSampleStore implements CorrectionSampleStore {
  @override
  Future<void> saveSample({
    required Uint8List imageBytes,
    required int wrongValue,
    required int correctedValue,
    required int cellIndex,
  }) async {}
}

/// Returns a no-op [CorrectionSampleStore] for platforms without file I/O.
CorrectionSampleStore createCorrectionSampleStoreImpl() =>
    _NoopCorrectionSampleStore();
