import 'package:cards/models/app/correction_sample_store.dart';
import 'package:cards/models/app/correction_sample_store_stub.dart' if (dart.library.io) 'correction_sample_store_io.dart';

/// Returns the platform-appropriate [CorrectionSampleStore] implementation.
CorrectionSampleStore createCorrectionSampleStore() =>
    createCorrectionSampleStoreImpl();
