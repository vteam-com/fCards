import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/correction_sample_store.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';

class _IoCorrectionSampleStore implements CorrectionSampleStore {
  static const String _rootDirName = 'training_corrections';
  static const String _imageDirName = 'images';
  static const String _metadataFileName = 'samples.jsonl';
  static const String _recordSeparator = '\n';
  static const String _dbPath = 'training_corrections';
  static const String _anonymousUid = 'anonymous';

  @override
  Future<void> saveSample({
    required Uint8List imageBytes,
    required int wrongValue,
    required int correctedValue,
    required int cellIndex,
  }) async {
    final now = DateTime.now();
    final timestamp = now.toIso8601String();
    final filename = 'sample_${now.millisecondsSinceEpoch}_cell_$cellIndex.jpg';

    await Future.wait([
      _saveLocally(
        imageBytes: imageBytes,
        filename: filename,
        timestamp: timestamp,
        cellIndex: cellIndex,
        wrongValue: wrongValue,
        correctedValue: correctedValue,
      ),
      _uploadToFirebase(
        imageBytes: imageBytes,
        filename: filename,
        timestamp: timestamp,
        cellIndex: cellIndex,
        wrongValue: wrongValue,
        correctedValue: correctedValue,
      ),
    ]);
  }

  /// Persists the sample image and appends a metadata record to the local JSONL file.
  Future<void> _saveLocally({
    required Uint8List imageBytes,
    required String filename,
    required String timestamp,
    required int cellIndex,
    required int wrongValue,
    required int correctedValue,
  }) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final rootDir = Directory('${documentsDir.path}/$_rootDirName');
    final imageDir = Directory('${rootDir.path}/$_imageDirName');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final imageFile = File('${imageDir.path}/$filename');
    await imageFile.writeAsBytes(imageBytes, flush: true);

    final metadataFile = File('${rootDir.path}/$_metadataFileName');
    final record = <String, dynamic>{
      'timestamp': timestamp,
      'image_file': filename,
      'cell_index': cellIndex,
      'wrong_value': wrongValue,
      'corrected_value': correctedValue,
    };
    await metadataFile.writeAsString(
      '${jsonEncode(record)}$_recordSeparator',
      mode: FileMode.append,
      flush: true,
    );
  }

  /// Uploads the sample image (base64) and metadata to Firebase Realtime Database
  /// under `training_corrections/{uid}/{key}` for later model retraining.
  Future<void> _uploadToFirebase({
    required Uint8List imageBytes,
    required String filename,
    required String timestamp,
    required int cellIndex,
    required int wrongValue,
    required int correctedValue,
  }) async {
    final uid = AuthService.currentUser?.uid ?? _anonymousUid;
    final db = FirebaseDatabase.instance.ref();
    final key = filename.replaceAll('.', '_');
    await db.child('$_dbPath/$uid/$key').set(<String, dynamic>{
      'timestamp': timestamp,
      'filename': filename,
      'cell_index': cellIndex,
      'wrong_value': wrongValue,
      'corrected_value': correctedValue,
      'image_base64': base64Encode(imageBytes),
    });
  }
}

/// Returns the native I/O [CorrectionSampleStore] implementation.
CorrectionSampleStore createCorrectionSampleStoreImpl() =>
    _IoCorrectionSampleStore();
