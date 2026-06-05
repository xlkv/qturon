import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/permissions_provider.dart';
import '../../../core/constants/object_status.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../masters/data/master_repository.dart';
import '../data/pipe_repository.dart';
import '../domain/pipe.dart';

class PipeDetailPage extends ConsumerWidget {
  const PipeDetailPage({super.key, required this.pipeId});

  final String pipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipeAsync = ref.watch(pipeStreamProvider(pipeId));
    final perms = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(pipeAsync.valueOrNull?.code ?? 'Turba'),
        actions: [
          if (perms.canEditWellOrPipe)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Tahrirlash',
              onPressed: () => context.push('/pipes/$pipeId/edit'),
            ),
          if (perms.canDeleteWellOrPipe)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'O\'chirish',
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body: pipeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Xato: $e')),
        data: (pipe) => pipe == null
            ? const Center(child: Text('Topilmadi'))
            : Consumer(
                builder: (context, ref, _) {
                  final masters = ref.watch(mastersStreamProvider).valueOrNull ?? const [];
                  final masterName = pipe.masterId == null
                      ? null
                      : masters
                          .where((m) => m.id == pipe.masterId)
                          .map((m) => m.name)
                          .firstOrNull;
                  return _Body(
                    pipe: pipe,
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
        content: const Text('Turba butunlay o\'chiriladi.'),
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
      await ref.read(pipeRepositoryProvider).delete(pipeId);
      ref.read(loggerProvider).info('pipe.delete', {'id': pipeId});
      if (context.mounted) context.pop();
    } catch (e, st) {
      ref.read(loggerProvider).error('pipe.delete_failed', e, st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.pipe, required this.masterName, required this.canSeePaid});

  final Pipe pipe;
  final String? masterName;
  final bool canSeePaid;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy');
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        ListTile(leading: const Icon(Icons.tag), title: const Text('Kod'), subtitle: Text(pipe.code)),
        _StatusRow(status: pipe.status),
        ListTile(
          leading: const Icon(Icons.straighten),
          title: const Text('Diametr'),
          subtitle: Text('${pipe.diameterMm} mm'),
        ),
        ListTile(
          leading: const Icon(Icons.linear_scale),
          title: const Text('Uzunlik'),
          subtitle: Text('${pipe.lengthM.toStringAsFixed(1)} m'),
        ),
        ListTile(
          leading: const Icon(Icons.scatter_plot),
          title: const Text('Nuqtalar soni'),
          subtitle: Text('${pipe.points.length} ta'),
        ),
        ListTile(
          leading: const Icon(Icons.engineering_outlined),
          title: const Text('Usta'),
          subtitle: Text(masterName ?? (pipe.masterId == null ? 'Belgilanmagan' : '(o\'chirilgan)')),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: const Text('O\'rnatilgan sana'),
          subtitle: Text(pipe.installedAt == null ? 'Hali yo\'q' : df.format(pipe.installedAt!)),
        ),
        if (pipe.notes != null && pipe.notes!.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.notes_outlined),
            title: const Text('Izoh'),
            subtitle: Text(pipe.notes!),
          ),
        if (canSeePaid)
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: const Text('To\'langan'),
            subtitle: Text(pipe.paid ? 'Ha' : 'Yo\'q'),
          ),
      ],
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
