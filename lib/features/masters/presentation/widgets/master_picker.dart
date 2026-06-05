import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/master_repository.dart';
import '../../domain/master.dart';

class MasterPicker extends ConsumerWidget {
  const MasterPicker({super.key, required this.masterId, required this.onChanged});

  final String? masterId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mastersAsync = ref.watch(activeMastersStreamProvider);
    return mastersAsync.when(
      loading: () => const _Loading(),
      error: (e, _) => Text('Xato: $e'),
      data: (masters) {
        if (masters.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.engineering_outlined),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(child: Text('Hali usta qo\'shilmagan')),
                TextButton.icon(
                  onPressed: () async {
                    final created = await _showAddMasterDialog(context, ref);
                    if (created != null) onChanged(created.id);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Qo\'shish'),
                ),
              ],
            ),
          );
        }
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: masters.any((m) => m.id == masterId) ? masterId : null,
                decoration: const InputDecoration(
                  labelText: 'Usta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.engineering_outlined),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Belgilanmagan')),
                  for (final m in masters)
                    DropdownMenuItem(value: m.id, child: Text(m.name)),
                ],
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filledTonal(
              icon: const Icon(Icons.add),
              tooltip: 'Yangi usta',
              onPressed: () async {
                final created = await _showAddMasterDialog(context, ref);
                if (created != null) onChanged(created.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<Master?> _showAddMasterDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<Master?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yangi usta'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Ism',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v ?? '').trim().length < 2 ? 'Ism kiriting' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Telefon (ixtiyoriy)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor qil')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final m = await ref.read(masterRepositoryProvider).create(
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                    );
                if (ctx.mounted) Navigator.pop(ctx, m);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Xato: $e')));
                }
              }
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
    nameCtrl.dispose();
    phoneCtrl.dispose();
    return result;
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
}
