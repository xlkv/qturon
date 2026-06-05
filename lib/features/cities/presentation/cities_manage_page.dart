import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/permissions_provider.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/city_repository.dart';
import '../domain/city.dart';
import 'widgets/city_form_sheet.dart';

class CitiesManagePage extends ConsumerWidget {
  const CitiesManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(permissionsProvider);
    if (!perms.canManageCities) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/map');
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final citiesAsync = ref.watch(citiesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shaharlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Yangi shahar',
            onPressed: () => CityFormSheet.show(context),
          ),
        ],
      ),
      body: citiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Xato: $e')),
        data: (cities) {
          if (cities.isEmpty) {
            return _EmptyState(onAdd: () => CityFormSheet.show(context));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: cities.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _CityTile(city: cities[i]),
          );
        },
      ),
    );
  }
}

class _CityTile extends ConsumerWidget {
  const _CityTile({required this.city});

  final City city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(city.name.isEmpty ? '?' : city.name[0].toUpperCase()),
      ),
      title: Text(city.name),
      subtitle: Text(
        '${city.center.latitude.toStringAsFixed(3)}, ${city.center.longitude.toStringAsFixed(3)} · zoom ${city.defaultZoom.toStringAsFixed(0)}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) => _onAction(context, ref, v),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
          PopupMenuItem(value: 'delete', child: Text('O\'chirish')),
        ],
      ),
      onTap: () => CityFormSheet.show(context, city: city),
    );
  }

  Future<void> _onAction(BuildContext context, WidgetRef ref, String action) async {
    if (action == 'edit') {
      await CityFormSheet.show(context, city: city);
      return;
    }
    if (action == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${city.name}ni o\'chirasizmi?'),
          content: const Text(
            'Diqqat: shahar ichidagi barcha kolodets/turba/usta yozuvlari ham yo\'qoladi (Firestore subcollections). Faqat shahar bo\'sh bo\'lganda o\'chiring.',
          ),
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
        await ref.read(cityRepositoryProvider).delete(city.id);
        ref.read(loggerProvider).info('city.delete', {'id': city.id});
      } catch (e, st) {
        ref.read(loggerProvider).error('city.delete_failed', e, st);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_city_outlined, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Hali shahar qo\'shilmagan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Birinchi shaharni qo\'shing — kolodets va turbalar shu yerda saqlanadi.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Yangi shahar'),
            ),
          ],
        ),
      ),
    );
  }
}
