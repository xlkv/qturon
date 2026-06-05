import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../core/auth/permissions_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/application/current_user_provider.dart';
import '../../cities/application/active_city_provider.dart';
import '../../cities/data/city_repository.dart';
import '../../cities/domain/city.dart';

class MapHomePage extends ConsumerWidget {
  const MapHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(permissionsProvider);
    final activeCityIdAsync = ref.watch(activeCityProvider);
    final citiesAsync = ref.watch(citiesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const _CityTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profil',
          ),
        ],
      ),
      drawer: const _AppDrawer(),
      body: activeCityIdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Xato: $e')),
        data: (activeCityId) {
          if (activeCityId == null) {
            return citiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Xato: $e')),
              data: (cities) => cities.isEmpty
                  ? _NoCitiesYet(canManage: perms.canManageCities)
                  : const _NoCityAssigned(),
            );
          }
          return citiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Xato: $e')),
            data: (cities) {
              final city = cities.where((c) => c.id == activeCityId).firstOrNull;
              if (city == null) return const _NoCityAssigned();
              return _MapView(city: city);
            },
          );
        },
      ),
    );
  }
}

class _CityTitle extends ConsumerWidget {
  const _CityTitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final activeCityId = ref.watch(activeCityProvider).valueOrNull;
    final cities = ref.watch(citiesStreamProvider).valueOrNull ?? const <City>[];
    final active = cities.where((c) => c.id == activeCityId).firstOrNull;

    final title = active?.name ?? 'Xarita';

    if (user?.role.isSuperAdmin == true && cities.length > 1) {
      return PopupMenuButton<String>(
        onSelected: (id) => ref.read(activeCityProvider.notifier).set(id),
        itemBuilder: (_) => cities
            .map((c) => PopupMenuItem(value: c.id, child: Text(c.name)))
            .toList(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      );
    }
    return Text(title);
  }
}

class _MapView extends StatelessWidget {
  const _MapView({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    // Yandex MapKit hozircha desktopda (Windows) qo'llab-quvvatlanmaydi.
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return _MapUnsupportedPlatform(city: city);
    }
    return YandexMap(
      onMapCreated: (controller) async {
        await controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: Point(latitude: city.center.latitude, longitude: city.center.longitude),
              zoom: city.defaultZoom,
            ),
          ),
        );
      },
    );
  }
}

class _MapUnsupportedPlatform extends StatelessWidget {
  const _MapUnsupportedPlatform({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text(
              city.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${city.center.latitude.toStringAsFixed(4)}, ${city.center.longitude.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Yandex Maps Windows desktopda hali qo\'llab-quvvatlanmaydi.\nAndroid qurilmasida xaritani ko\'rish mumkin.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoCitiesYet extends StatelessWidget {
  const _NoCitiesYet({required this.canManage});

  final bool canManage;

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
              'Hali shahar yo\'q',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Birinchi shaharni qo\'shing — kolodets va turbalar shu yerda joylanadi.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (canManage)
              FilledButton.icon(
                onPressed: () => context.push('/cities'),
                icon: const Icon(Icons.add),
                label: const Text('Shahar qo\'shish'),
              )
            else
              const Text(
                'Super-administrator bilan bog\'laning.',
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

class _NoCityAssigned extends StatelessWidget {
  const _NoCityAssigned();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'Sizga hali shahar tayinlanmagan.\nSuper-administrator bilan bog\'laning.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final perms = ref.watch(permissionsProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? '—'),
              accountEmail: Text(_roleLabel(user?.role.wire ?? 'user')),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  (user?.name.isNotEmpty ?? false)
                      ? user!.name.substring(0, 1).toUpperCase()
                      : '?',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Xarita'),
              selected: true,
              onTap: () => Navigator.of(context).pop(),
            ),
            if (perms.canManageMasters)
              ListTile(
                leading: const Icon(Icons.engineering_outlined),
                title: const Text('Ustalar'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tez kunda qo\'shiladi')),
                  );
                },
              ),
            if (perms.canManageCities)
              ListTile(
                leading: const Icon(Icons.location_city_outlined),
                title: const Text('Shaharlar'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/cities');
                },
              ),
            if (perms.canManageUsers)
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Foydalanuvchilar'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tez kunda qo\'shiladi')),
                  );
                },
              ),
            if (perms.canViewAuditLog)
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Audit log'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tez kunda qo\'shiladi')),
                  );
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String wire) {
    switch (wire) {
      case 'super_admin':
        return 'Bosh administrator';
      case 'admin':
        return 'Administrator';
      default:
        return 'Foydalanuvchi';
    }
  }
}
