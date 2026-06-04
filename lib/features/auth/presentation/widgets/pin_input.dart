import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class PinInput extends StatelessWidget {
  const PinInput({
    super.key,
    required this.value,
    this.length = 6,
    this.hasError = false,
  });

  final String value;
  final int length;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final filled = value.length;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isFilled = i < filled;
        final isActive = i == filled;
        final border = hasError
            ? colorScheme.error
            : isActive
                ? colorScheme.primary
                : colorScheme.outlineVariant;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 44,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: border, width: isActive ? 2 : 1),
              borderRadius: BorderRadius.circular(10),
              color: isFilled ? colorScheme.primaryContainer.withValues(alpha: 0.25) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              isFilled ? '•' : '',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        );
      }),
    );
  }
}
