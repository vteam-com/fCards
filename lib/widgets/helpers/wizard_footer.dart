import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:flutter/material.dart';

/// Standard wizard footer with back + forward action buttons.
class WizardFooter extends StatelessWidget {
  const WizardFooter({
    super.key,
    required this.backLabel,
    required this.primaryLabel,
    required this.isPrimaryEnabled,
    this.onBack,
    this.onForward,
  });

  final String backLabel;
  final bool isPrimaryEnabled;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final String primaryLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onBack != null)
          MyButtonRectangle.action(
            onTap: onBack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: ConstLayout.sizeM,
              children: [const Icon(Icons.arrow_back), Text(backLabel)],
            ),
          )
        else
          const SizedBox.shrink(),
        if (onForward != null)
          MyButtonRectangle.action(
            onTap: isPrimaryEnabled ? onForward : null,
            child: Text(primaryLabel),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
