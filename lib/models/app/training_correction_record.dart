import 'dart:convert';
import 'dart:typed_data';

const String trainingCorrectionsDbPath = 'training_corrections';

/// Review status for a correction sample.
enum TrainingCorrectionReviewStatus {
  pending,
  approved,
  rejected;

  /// Database wire value.
  String get wireValue => name;
}

/// One correction sample uploaded for model retraining.
class TrainingCorrectionRecord {
  TrainingCorrectionRecord({
    required this.ownerUid,
    required this.sampleKey,
    required this.filename,
    required this.cellIndex,
    required this.wrongValue,
    required this.correctedValue,
    required this.imageBytes,
    required this.submittedAt,
    required this.reviewStatus,
    required this.reviewedAt,
    required this.reviewerUid,
    required this.reviewerEmail,
  });

  final String ownerUid;
  final String sampleKey;
  final String filename;
  final int cellIndex;
  final int wrongValue;
  final int correctedValue;
  final Uint8List? imageBytes;
  final DateTime? submittedAt;
  final TrainingCorrectionReviewStatus reviewStatus;
  final DateTime? reviewedAt;
  final String reviewerUid;
  final String reviewerEmail;

  /// Stable identifier in `{ownerUid}/{sampleKey}` format.
  String get id => '$ownerUid/$sampleKey';

  /// Converts dynamic numeric input to an integer.
  static int _toInt(dynamic rawValue) {
    if (rawValue is int) {
      return rawValue;
    }
    if (rawValue is num) {
      return rawValue.toInt();
    }
    if (rawValue is String) {
      return int.tryParse(rawValue) ?? 0;
    }
    return 0;
  }

  /// Maps persisted review status strings to enum values.
  static TrainingCorrectionReviewStatus _parseReviewStatus(dynamic rawValue) {
    final String normalized = (rawValue as String?)?.trim().toLowerCase() ?? '';
    return switch (normalized) {
      _ when normalized == TrainingCorrectionReviewStatus.approved.name =>
        TrainingCorrectionReviewStatus.approved,
      _ when normalized == TrainingCorrectionReviewStatus.rejected.name =>
        TrainingCorrectionReviewStatus.rejected,
      _ => TrainingCorrectionReviewStatus.pending,
    };
  }

  /// Decodes base64-encoded image bytes from Firebase payloads.
  static Uint8List? _decodeImageBytes(dynamic rawValue) {
    final String? value = rawValue as String?;
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }

  /// Parses one correction record from Firebase map data.
  static TrainingCorrectionRecord? fromMap({
    required String ownerUid,
    required String sampleKey,
    required Object? rawValue,
  }) {
    if (rawValue is! Map<dynamic, dynamic>) {
      return null;
    }

    final String submittedAtRaw =
        (rawValue['timestamp'] as String?)?.trim() ?? '';
    final String reviewedAtRaw =
        (rawValue['reviewed_at'] as String?)?.trim() ?? '';

    return TrainingCorrectionRecord(
      ownerUid: ownerUid,
      sampleKey: sampleKey,
      filename: (rawValue['filename'] as String?)?.trim() ?? sampleKey,
      cellIndex: _toInt(rawValue['cell_index']),
      wrongValue: _toInt(rawValue['wrong_value']),
      correctedValue: _toInt(rawValue['corrected_value']),
      imageBytes: _decodeImageBytes(rawValue['image_base64']),
      submittedAt: submittedAtRaw.isEmpty
          ? null
          : DateTime.tryParse(submittedAtRaw),
      reviewStatus: _parseReviewStatus(rawValue['review_status']),
      reviewedAt: reviewedAtRaw.isEmpty
          ? null
          : DateTime.tryParse(reviewedAtRaw),
      reviewerUid: (rawValue['reviewer_uid'] as String?)?.trim() ?? '',
      reviewerEmail: (rawValue['reviewer_email'] as String?)?.trim() ?? '',
    );
  }
}

/// Flattens `training_corrections/{uid}/{sampleKey}` DB data into records.
List<TrainingCorrectionRecord> parseTrainingCorrectionRecords(
  Object? rawValue,
) {
  if (rawValue is! Map<dynamic, dynamic>) {
    return <TrainingCorrectionRecord>[];
  }

  final List<TrainingCorrectionRecord> records = <TrainingCorrectionRecord>[];
  rawValue.forEach((dynamic ownerKey, dynamic ownerNode) {
    if (ownerNode is! Map<dynamic, dynamic>) {
      return;
    }

    ownerNode.forEach((dynamic sampleKey, dynamic sampleNode) {
      final TrainingCorrectionRecord? parsed = TrainingCorrectionRecord.fromMap(
        ownerUid: '$ownerKey',
        sampleKey: '$sampleKey',
        rawValue: sampleNode,
      );
      if (parsed != null) {
        records.add(parsed);
      }
    });
  });

  records.sort((TrainingCorrectionRecord a, TrainingCorrectionRecord b) {
    final int aMs = a.submittedAt?.millisecondsSinceEpoch ?? 0;
    final int bMs = b.submittedAt?.millisecondsSinceEpoch ?? 0;
    return bMs.compareTo(aMs);
  });

  return records;
}
