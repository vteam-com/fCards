import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/reviewer_access.dart';
import 'package:cards/models/app/training_correction_record.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum _CorrectionsFilter { pending, approved, rejected, all }

/// Reviewer-only UI for auditing uploaded correction samples.
class CorrectionsReviewScreen extends StatefulWidget {
  const CorrectionsReviewScreen({super.key});

  @override
  State<CorrectionsReviewScreen> createState() =>
      _CorrectionsReviewScreenState();
}

class _CorrectionsReviewScreenState extends State<CorrectionsReviewScreen> {
  _CorrectionsFilter _activeFilter = _CorrectionsFilter.pending;
  String? _processingRecordId;
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Screen(
      title: l10n.correctionsTitle,
      isWaiting: false,
      child: _buildBody(l10n),
    );
  }

  /// Persists an approve/reject decision to Firebase for one correction record.
  Future<void> _applyReviewDecision({
    required TrainingCorrectionRecord record,
    required TrainingCorrectionReviewStatus status,
  }) async {
    if (_processingRecordId != null) {
      return;
    }

    final user = AuthService.currentUser;
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (user == null || user.isAnonymous) {
      _showMessage(l10n.notAllowed);
      return;
    }

    final bool reviewer = await isCurrentUserReviewer();
    if (!reviewer) {
      _showMessage(l10n.correctionsReviewerOnly);
      return;
    }

    setState(() {
      _processingRecordId = record.id;
    });

    try {
      await FirebaseDatabase.instance
          .ref(
            '$trainingCorrectionsDbPath/${record.ownerUid}/${record.sampleKey}',
          )
          .update(<String, dynamic>{
            'review_status': status.wireValue,
            'reviewed_at': DateTime.now().toIso8601String(),
            'reviewer_uid': user.uid,
            'reviewer_email': user.email ?? user.displayName ?? '',
          });

      _showMessage(l10n.correctionsDecisionSaved);
    } catch (error, stack) {
      logger.e('Failed to update correction review', error, stack);
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _processingRecordId = null;
        });
      }
    }
  }

  /// Builds the main body and applies web/reviewer access guards.
  Widget _buildBody(AppLocalizations l10n) {
    if (isRunningOffLine) {
      return Center(
        child: Text(
          l10n.correctionsBackendRequired,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: ConstLayout.textS),
        ),
      );
    }

    if (!kIsWeb) {
      return Center(
        child: Text(
          l10n.correctionsWebOnly,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: ConstLayout.textS),
        ),
      );
    }

    return StreamBuilder<bool>(
      stream: reviewerAccessStream(),
      builder: (BuildContext _, AsyncSnapshot<bool> reviewerSnapshot) {
        if (reviewerSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bool isReviewer = reviewerSnapshot.data ?? false;
        if (!isReviewer) {
          return Center(
            child: Text(
              l10n.correctionsReviewerOnly,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: ConstLayout.textS),
            ),
          );
        }

        return StreamBuilder<DatabaseEvent>(
          stream: FirebaseDatabase.instance
              .ref(trainingCorrectionsDbPath)
              .onValue,
          builder: (BuildContext _, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(ConstLayout.paddingL),
                  child: Text(
                    '${l10n.errorLoadingScores}: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: ConstLayout.textS),
                  ),
                ),
              );
            }

            final List<TrainingCorrectionRecord> allRecords =
                parseTrainingCorrectionRecords(snapshot.data?.snapshot.value);
            final List<TrainingCorrectionRecord> visibleRecords =
                _filterRecords(allRecords);

            return Padding(
              padding: const EdgeInsets.all(ConstLayout.paddingM),
              child: Column(
                children: [
                  _buildFilters(l10n),
                  SizedBox(height: ConstLayout.sizeM),
                  Expanded(
                    child: visibleRecords.isEmpty
                        ? Center(
                            child: Text(
                              _emptyStateText(l10n),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: ConstLayout.textS,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: visibleRecords.length,
                            separatorBuilder: (BuildContext _, int _) =>
                                SizedBox(height: ConstLayout.sizeM),
                            itemBuilder: (BuildContext _, int index) {
                              return _buildRecordCard(
                                l10n,
                                visibleRecords[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Renders the pending/approved/rejected/all filter controls.
  Widget _buildFilters(AppLocalizations l10n) {
    return Wrap(
      spacing: ConstLayout.sizeS,
      runSpacing: ConstLayout.sizeS,
      alignment: WrapAlignment.center,
      children: _CorrectionsFilter.values.map((filter) {
        final bool isSelected = filter == _activeFilter;
        return Opacity(
          opacity: isSelected ? ConstLayout.scaleSmall : ConstLayout.scaleTiny,
          child: MyButtonRectangle.secondary(
            width: ConstLayout.playerZoneCTAHeight,
            height: ConstLayout.height40,
            onTap: () {
              setState(() {
                _activeFilter = filter;
              });
            },
            child: Text(
              _filterLabel(filter, l10n),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: ConstLayout.textS,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Renders the correction image thumbnail with fallback placeholders.
  Widget _buildImagePreview(TrainingCorrectionRecord record) {
    final Uint8List? imageBytes = record.imageBytes;
    if (imageBytes == null) {
      return Container(
        width: ConstLayout.playerZoneCTAHeight,
        height: ConstLayout.playerZoneCTAHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ConstLayout.radiusM),
          color: Colors.black.withAlpha(ConstLayout.alphaM),
        ),
        child: const Icon(Icons.image_not_supported, size: ConstLayout.iconM),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(ConstLayout.radiusM),
      child: Image.memory(
        imageBytes,
        width: ConstLayout.playerZoneCTAHeight,
        height: ConstLayout.playerZoneCTAHeight,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext _, Object _, StackTrace? _) {
          return Container(
            width: ConstLayout.playerZoneCTAHeight,
            height: ConstLayout.playerZoneCTAHeight,
            color: Colors.black.withAlpha(ConstLayout.alphaM),
            child: const Icon(Icons.broken_image, size: ConstLayout.iconM),
          );
        },
      ),
    );
  }

  /// Builds one correction item with metadata and review actions.
  Widget _buildRecordCard(
    AppLocalizations l10n,
    TrainingCorrectionRecord record,
  ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isProcessing = _processingRecordId == record.id;

    return Container(
      padding: const EdgeInsets.all(ConstLayout.paddingM),
      decoration: BoxDecoration(
        color: AppTheme.panelInputZone,
        borderRadius: BorderRadius.circular(ConstLayout.radiusM),
        border: Border.all(
          color: colorScheme.onPrimary.withAlpha(ConstLayout.alphaM),
          width: ConstLayout.strokeXS,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePreview(record),
              SizedBox(width: ConstLayout.sizeM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.correctionsSubmittedBy}: ${record.ownerUid}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ConstLayout.textS,
                      ),
                    ),
                    SizedBox(height: ConstLayout.sizeS),
                    Text(
                      '${l10n.correctionsSubmittedAt}: ${_formatDateTime(record.submittedAt)}',
                      style: const TextStyle(fontSize: ConstLayout.textS),
                    ),
                    SizedBox(height: ConstLayout.sizeS),
                    Text(
                      '${l10n.correctionsDetectedValue}: ${record.wrongValue}',
                      style: const TextStyle(fontSize: ConstLayout.textS),
                    ),
                    Text(
                      '${l10n.correctionsCorrectedValue}: ${record.correctedValue}',
                      style: const TextStyle(fontSize: ConstLayout.textS),
                    ),
                    SizedBox(height: ConstLayout.sizeS),
                    Text(
                      '${l10n.correctionsReviewStatus}: ${_statusLabel(record.reviewStatus, l10n)}',
                      style: TextStyle(
                        fontSize: ConstLayout.textS,
                        color: _statusColor(record.reviewStatus, colorScheme),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (record.reviewerEmail.isNotEmpty)
                      Text(
                        '${l10n.account}: ${record.reviewerEmail}',
                        style: const TextStyle(fontSize: ConstLayout.textS),
                      ),
                    if (record.reviewedAt != null)
                      Text(
                        '${l10n.done}: ${_formatDateTime(record.reviewedAt)}',
                        style: const TextStyle(fontSize: ConstLayout.textS),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ConstLayout.sizeM),
          Row(
            children: [
              Expanded(
                child: MyButtonRectangle.primary(
                  height: ConstLayout.height40,
                  onTap: isProcessing
                      ? null
                      : () => _applyReviewDecision(
                          record: record,
                          status: TrainingCorrectionReviewStatus.approved,
                        ),
                  child: isProcessing
                      ? const SizedBox(
                          width: ConstLayout.iconXS,
                          height: ConstLayout.iconXS,
                          child: CircularProgressIndicator(
                            strokeWidth: ConstLayout.strokeS,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.correctionsApprove),
                ),
              ),
              SizedBox(width: ConstLayout.sizeS),
              Expanded(
                child: MyButtonRectangle.danger(
                  height: ConstLayout.height40,
                  onTap: isProcessing
                      ? null
                      : () => _applyReviewDecision(
                          record: record,
                          status: TrainingCorrectionReviewStatus.rejected,
                        ),
                  child: Text(l10n.correctionsReject),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _emptyStateText(AppLocalizations l10n) {
    return switch (_activeFilter) {
      _CorrectionsFilter.pending => l10n.correctionsNoPending,
      _CorrectionsFilter.approved => l10n.correctionsNoApproved,
      _CorrectionsFilter.rejected => l10n.correctionsNoRejected,
      _CorrectionsFilter.all => l10n.correctionsNoData,
    };
  }

  String _filterLabel(_CorrectionsFilter filter, AppLocalizations l10n) {
    return switch (filter) {
      _CorrectionsFilter.pending => l10n.correctionsPending,
      _CorrectionsFilter.approved => l10n.correctionsApproved,
      _CorrectionsFilter.rejected => l10n.correctionsRejected,
      _CorrectionsFilter.all => l10n.correctionsAll,
    };
  }

  /// Applies the active status filter to the correction list.
  List<TrainingCorrectionRecord> _filterRecords(
    List<TrainingCorrectionRecord> records,
  ) {
    return records.where((TrainingCorrectionRecord record) {
      return switch (_activeFilter) {
        _CorrectionsFilter.pending =>
          record.reviewStatus == TrainingCorrectionReviewStatus.pending,
        _CorrectionsFilter.approved =>
          record.reviewStatus == TrainingCorrectionReviewStatus.approved,
        _CorrectionsFilter.rejected =>
          record.reviewStatus == TrainingCorrectionReviewStatus.rejected,
        _CorrectionsFilter.all => true,
      };
    }).toList();
  }

  /// Formats nullable timestamps for compact display in the review list.
  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '-';
    }

    final DateTime local = value.toLocal();
    final String month = local.month.toString().padLeft(
      ConstLayout.dateCharacterLeftSpacePadding,
      '0',
    );
    final String day = local.day.toString().padLeft(
      ConstLayout.dateCharacterLeftSpacePadding,
      '0',
    );
    final String hour = local.hour.toString().padLeft(
      ConstLayout.dateCharacterLeftSpacePadding,
      '0',
    );
    final String minute = local.minute.toString().padLeft(
      ConstLayout.dateCharacterLeftSpacePadding,
      '0',
    );
    return '${local.year}-$month-$day $hour:$minute';
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Color _statusColor(
    TrainingCorrectionReviewStatus status,
    ColorScheme colorScheme,
  ) {
    return switch (status) {
      TrainingCorrectionReviewStatus.pending => colorScheme.secondary,
      TrainingCorrectionReviewStatus.approved => colorScheme.primary,
      TrainingCorrectionReviewStatus.rejected => colorScheme.error,
    };
  }

  String _statusLabel(
    TrainingCorrectionReviewStatus status,
    AppLocalizations l10n,
  ) {
    return switch (status) {
      TrainingCorrectionReviewStatus.pending => l10n.correctionsPending,
      TrainingCorrectionReviewStatus.approved => l10n.correctionsApproved,
      TrainingCorrectionReviewStatus.rejected => l10n.correctionsRejected,
    };
  }
}
