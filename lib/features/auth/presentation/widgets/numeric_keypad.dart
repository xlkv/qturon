import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.enabled = true,
  });

  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row(context, const ['1', '2', '3']),
              _row(context, const ['4', '5', '6']),
              _row(context, const ['7', '8', '9']),
              _row(context, const ['', '0', '⌫']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, List<String> labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: labels.map((l) => _Key(label: l, onDigit: onDigit, onBackspace: onBackspace)).toList(),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onDigit, required this.onBackspace});

  final String label;
  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return const SizedBox(width: 80, height: 64);
    }
    final isBackspace = label == '⌫';
    return SizedBox(
      width: 80,
      height: 64,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => isBackspace ? onBackspace() : onDigit(label),
          child: Center(
            child: isBackspace
                ? const Icon(Icons.backspace_outlined)
                : Text(
                    label,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
          ),
        ),
      ),
    );
  }
}
