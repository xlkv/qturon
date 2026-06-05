import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/permissions_provider.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/master_repository.dart';
import '../domain/master.dart';

class MastersManagePage extends ConsumerWidget {
  const MastersManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(permissionsProvider);
    final mastersAsync = ref.watch(mastersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustalar'),
        actions: [
          if (perms.canManageMasters)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Yangi usta',
              onPressed: () => _showFormSheet(context, ref, null),
            ),
        ],
      ),
      body: mastersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Xato: $e')),
        data: (masters) {
          if (masters.isEmpty) {
            return _Empty(canAdd: perms.canManageMasters, onAdd: () => _showFormSheet(context, ref, null));
          }
          return ListView.separated(
            itemCount: masters.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _Tile(
              master: masters[i],
              canEdit: perms.canManageMasters,
              canHardDelete: perms.canHardDeleteMaster,
              onEdit: () => _showFormSheet(context, ref, masters[i]),
              onDelete: () => _confirmDelete(context, ref, masters[i]),
              onToggleActive: () async {
                try {
                  await ref.read(masterRepositoryProvider).update(
                        masters[i].copyWith(active: !masters[i].active),
                      );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showFormSheet(BuildContext context, WidgetRef ref, Master? existing) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        existing == null ? 'Yangi usta' : 'Usta tahrirlash',
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: saving ? null : () => Navigator.pop(ctx),
                              child: const Text('Bekor qil'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: FilledButton(
                              onPressed: saving
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) return;
                                      setState(() => saving = true);
                                      final repo = ref.read(masterRepositoryProvider);
                                      try {
                                        if (existing == null) {
                                          await repo.create(
                                            name: nameCtrl.text.trim(),
                                            phone: phoneCtrl.text.trim().isEmpty
                                                ? null
                                                : phoneCtrl.text.trim(),
                                          );
                                        } else {
                                          await repo.update(existing.copyWith(
                                            name: nameCtrl.text.trim(),
                                            phone: phoneCtrl.text.trim().isEmpty
                                                ? null
                                                : phoneCtrl.text.trim(),
                                          ));
                                        }
                                        if (ctx.mounted) Navigator.pop(ctx);
                                      } catch (e) {
                                        setState(() => saving = false);
                                        if (ctx.mounted) {
                                          ScaffoldMessenger.of(ctx)
                                              .showSnackBar(SnackBar(content: Text('Xato: $e')));
                                        }
                                      }
                                    },
                              child: saving
                                  ? const SizedBox(
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Saqlash'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    nameCtrl.dispose();
    phoneCtrl.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Master m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${m.name}ni o\'chirasizmi?'),
        content: const Text('Yozuv butunlay o\'chiriladi. Eski kolodets/turbalarda ham yo\'qoladi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bekor qil')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(masterRepositoryProvider).delete(m.id);
      ref.read(loggerProvider).info('master.delete', {'id': m.id});
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.master,
    required this.canEdit,
    required this.canHardDelete,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  final Master master;
  final bool canEdit;
  final bool canHardDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: master.active
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(master.name.isEmpty ? '?' : master.name[0].toUpperCase()),
      ),
      title: Text(
        master.name,
        style: TextStyle(
          decoration: master.active ? null : TextDecoration.lineThrough,
        ),
      ),
      subtitle: Text(master.phone ?? (master.active ? 'Faol' : 'Faol emas')),
      trailing: canEdit
          ? PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'toggle') onToggleActive();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(master.active ? 'Faol emas qilish' : 'Faollashtirish'),
                ),
                if (canHardDelete)
                  const PopupMenuItem(value: 'delete', child: Text('O\'chirish')),
              ],
            )
          : null,
      onTap: canEdit ? onEdit : null,
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.canAdd, required this.onAdd});

  final bool canAdd;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.engineering_outlined, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text('Hali usta yo\'q', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            if (canAdd)
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Yangi usta'),
              ),
          ],
        ),
      ),
    );
  }
}
