import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/current_user_provider.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/role.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Xato: $e')),
        data: (user) => user == null
            ? const Center(child: Text('Foydalanuvchi topilmadi'))
            : _ProfileBody(user: user),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.lg),
        _Avatar(name: user.name),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Text(
            user.name.isEmpty ? '—' : user.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(child: _RoleBadge(role: user.role)),
        const SizedBox(height: AppSpacing.xl),
        if (user.phone != null && user.phone!.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Telefon'),
            subtitle: Text(user.phone!),
          ),
        ListTile(
          leading: const Icon(Icons.location_city_outlined),
          title: const Text('Shaharlar'),
          subtitle: Text(
            user.role.isSuperAdmin
                ? 'Barchasi'
                : user.cityIds.isEmpty
                    ? '—'
                    : user.cityIds.join(', '),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.tonalIcon(
          onPressed: () => _onLogout(context, ref),
          icon: const Icon(Icons.logout),
          label: const Text('Tizimdan chiqish'),
          style: FilledButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  Future<void> _onLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tizimdan chiqasizmi?'),
        content: const Text('Keyingi safar yana kirish kodingizni kiritishingiz kerak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Bekor qil'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Chiqish'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!context.mounted) return;

    ref.read(loggerProvider).info('auth.logout');
    await ref.read(authRepositoryProvider).signOut();
    if (!context.mounted) return;
    context.go('/login');
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim().substring(0, 1).toUpperCase();
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: const BoxDecoration(
          color: AppColors.brand,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final Role role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _label(role),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _label(Role r) {
    switch (r) {
      case Role.superAdmin:
        return 'Bosh administrator';
      case Role.admin:
        return 'Administrator';
      case Role.user:
        return 'Foydalanuvchi';
    }
  }
}
