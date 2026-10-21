import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:flutter/material.dart';

/// Standard wizard footer with back + forward action buttons.
///
/// Each button is at most [ConstLayout.buttonWidth] wide and shrinks to share
/// the row on narrow screens, scaling its label down rather than overflowing.
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
      spacing: ConstLayout.sizeS,
      children: [
        if (onBack != null)
          _buildButton(
            onTap: onBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: ConstLayout.sizeM,
              children: [const Icon(Icons.arrow_back), Text(backLabel)],
            ),
          )
        else
          const SizedBox.shrink(),
        if (onForward != null)
          _buildButton(
            onTap: isPrimaryEnabled ? onForward : null,
            child: Text(primaryLabel),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  /// Builds a footer button that shrinks to fit, capped at the standard width.
  Widget _buildButton({required VoidCallback? onTap, required Widget child}) {
    return Flexible(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ConstLayout.buttonWidth),
        child: MyButtonRectangle.action(
          onTap: onTap,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ConstLayout.paddingM,
            ),
            child: FittedBox(fit: BoxFit.scaleDown, child: child),
          ),
        ),
      ),
    );
  }
}
