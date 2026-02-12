import 'package:cards/models/app/constants_layout.dart';
import 'package:flutter/material.dart';

/// Shared circular step indicator for wizard-style flows.
class StepIndicator extends StatelessWidget {
  ///
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.stepCount,
  });

  /// Index of the active step.
  final int currentStep;

  /// Total number of steps shown.
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int index = 0; index < stepCount; index++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: ConstLayout.sizeXS),
            child: CircleAvatar(
              radius: ConstLayout.radiusXL,
              backgroundColor: index <= currentStep
                  ? colorScheme.primary
                  : colorScheme.onSurface,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
