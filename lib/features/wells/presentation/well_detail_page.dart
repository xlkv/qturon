import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/permissions_provider.dart';
import '../../../core/constants/object_status.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../masters/data/master_repository.dart';
import '../data/well_repository.dart';
import '../domain/well.dart';

class WellDetailPage extends ConsumerWidget {
  const WellDetailPage({super.key, required this.wellId});

  final String wellId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wellAsync = ref.watch(wellStreamProvider(wellId));
    final perms = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(wellAsync.valueOrNull?.code ?? 'Kolodets'),
        actions: [
          if (perms.canEditWellOrPipe)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Tahrirlash',
              onPressed: () => context.push('/wells/$wellId/edit'),
            ),
          if (perms.canDeleteWellOrPipe)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'O\'chirish',
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body: wellAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Xato: $e')),
        data: (well) => well == null
            ? const Center(child: Text('Topilmadi'))
            : Consumer(
                builder: (context, ref, _) {
                  final masters = ref.watch(mastersStreamProvider).valueOrNull ?? const [];
                  final masterName = well.masterId == null
                      ? null
                      : masters
                          .where((m) => m.id == well.masterId)
                          .map((m) => m.name)
                          .firstOrNull;
                  return _Body(
                    well: well,
                    masterName: masterName,
                    canSeePaid: perms.canSeePaidField,
                  );
                },
              ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('O\'chirilsinmi?'),
        content: const Text('Kolodets butunlay o\'chiriladi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bekor qil')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(wellRepositoryProvider).delete(wellId);
      ref.read(loggerProvider).info('well.delete', {'id': wellId});
      if (context.mounted) context.pop();
    } catch (e, st) {
      ref.read(loggerProvider).error('well.delete_failed', e, st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.well, required this.masterName, required this.canSeePaid});

  final Well well;
  final String? masterName;
  final bool canSeePaid;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy');
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        _Row(
          icon: Icons.tag,
          label: 'Kod',
          value: well.code,
        ),
        _StatusRow(status: well.status),
        _Row(
          icon: Icons.place_outlined,
          label: 'Joylashuv',
          value:
              '${well.location.latitude.toStringAsFixed(5)}, ${well.location.longitude.toStringAsFixed(5)}',
        ),
        _Row(
          icon: Icons.engineering_outlined,
          label: 'Usta',
          value: masterName ?? (well.masterId == null ? 'Belgilanmagan' : '(o\'chirilgan)'),
        ),
        _Row(
          icon: Icons.calendar_today_outlined,
          label: 'O\'rnatilgan sana',
          value: well.installedAt == null ? 'Hali o\'rnatilmagan' : df.format(well.installedAt!),
        ),
        if (well.notes != null && well.notes!.isNotEmpty)
          _Row(
            icon: Icons.notes_outlined,
            label: 'Izoh',
            value: well.notes!,
          ),
        if (canSeePaid)
          _Row(
            icon: Icons.payments_outlined,
            label: 'To\'langan',
            value: well.paid ? 'Ha' : 'Yo\'q',
          ),
        const Divider(),
        if (well.createdAt != null)
          _Row(
            icon: Icons.add_circle_outline,
            label: 'Yaratilgan',
            value: df.format(well.createdAt!),
          ),
        if (well.updatedAt != null)
          _Row(
            icon: Icons.update,
            label: 'Yangilangan',
            value: df.format(well.updatedAt!),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.status});

  final ObjectStatus status;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.flag_outlined),
      title: const Text('Status'),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: status.color,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                status.label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
