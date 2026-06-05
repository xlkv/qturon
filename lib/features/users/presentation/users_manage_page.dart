import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/permissions_provider.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/domain/role.dart';
import '../data/users_admin_repository.dart';
import '../domain/admin_user.dart';

class UsersManagePage extends ConsumerWidget {
  const UsersManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(permissionsProvider);
    if (!perms.canManageUsers) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/map');
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final usersAsync = ref.watch(usersAdminStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foydalanuvchilar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Yangi',
            onPressed: () => _showFormSheet(context, ref, null),
          ),
        ],
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Xato: $e')),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('Hali foydalanuvchi yo\'q'));
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _Tile(
              user: users[i],
              onEdit: () => _showFormSheet(context, ref, users[i]),
              onShowPassKey: () {
                if (users[i].passKey != null) {
                  _showPassKey(context, users[i].passKey!);
                }
              },
              onRegenerate: () => _regenerate(context, ref, users[i]),
              onDelete: () => _confirmDelete(context, ref, users[i]),
              onToggleActive: () async {
                try {
                  await ref.read(usersAdminRepositoryProvider).update(
                        users[i].copyWith(active: !users[i].active),
                      );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xato: $e')),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _regenerate(BuildContext context, WidgetRef ref, AdminUser u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${u.name} uchun yangi kod?'),
        content: const Text(
          'Eski kod ishlamay qoladi. Yangi kodni foydalanuvchiga yetkazing.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bekor qil')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yaratish'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final newKey = await ref.read(usersAdminRepositoryProvider).regeneratePassKey(u.id);
      ref.read(loggerProvider).info('user.regenerate_passkey', {'id': u.id});
      if (context.mounted) _showPassKey(context, newKey);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }

  void _showPassKey(BuildContext context, String passKey) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Yangi kirish kodi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                passKey,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Bu kodni foydalanuvchiga yetkazing. Keyin yana ko\'rinmaydi.'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: passKey));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nusxa olindi')),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Nusxa'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFormSheet(BuildContext context, WidgetRef ref, AdminUser? existing) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    var role = existing?.role ?? Role.user;
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
                        existing == null ? 'Yangi foydalanuvchi' : 'Tahrirlash',
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
                      const SizedBox(height: AppSpacing.md),
                      Text('Rol', style: Theme.of(ctx).textTheme.labelLarge),
                      const SizedBox(height: AppSpacing.xs),
                      SegmentedButton<Role>(
                        segments: const [
                          ButtonSegment(value: Role.user, label: Text('Foydalanuvchi')),
                          ButtonSegment(value: Role.admin, label: Text('Admin')),
                          ButtonSegment(value: Role.superAdmin, label: Text('Super')),
                        ],
                        selected: {role},
                        onSelectionChanged: (s) => setState(() => role = s.first),
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
                                      final repo = ref.read(usersAdminRepositoryProvider);
                                      try {
                                        if (existing == null) {
                                          final created = await repo.create(
                                            name: nameCtrl.text.trim(),
                                            role: role,
                                            phone: phoneCtrl.text.trim().isEmpty
                                                ? null
                                                : phoneCtrl.text.trim(),
                                          );
                                          if (ctx.mounted) {
                                            Navigator.pop(ctx);
                                            _showPassKey(context, created.passKey);
                                          }
                                        } else {
                                          await repo.update(existing.copyWith(
                                            name: nameCtrl.text.trim(),
                                            role: role,
                                            phone: phoneCtrl.text.trim().isEmpty
                                                ? null
                                                : phoneCtrl.text.trim(),
                                          ));
                                          if (ctx.mounted) Navigator.pop(ctx);
                                        }
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, AdminUser u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${u.name} ni o\'chirasizmi?'),
        content: const Text('Foydalanuvchi tizimga kira olmaydi.'),
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
      await ref.read(usersAdminRepositoryProvider).delete(u.id);
      ref.read(loggerProvider).info('user.delete', {'id': u.id});
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }
}

class _Tile extends StatefulWidget {
  const _Tile({
    required this.user,
    required this.onEdit,
    required this.onShowPassKey,
    required this.onRegenerate,
    required this.onDelete,
    required this.onToggleActive,
  });

  final AdminUser user;
  final VoidCallback onEdit;
  final VoidCallback onShowPassKey;
  final VoidCallback onRegenerate;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final passKey = user.passKey;
    final keyDisplay = passKey == null
        ? '—'
        : _revealed
            ? passKey
            : '••••••';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: user.active
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(user.name.isEmpty ? '?' : user.name[0].toUpperCase()),
      ),
      title: Text(
        user.name,
        style: TextStyle(
          decoration: user.active ? null : TextDecoration.lineThrough,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${_roleLabel(user.role)} · ${user.phone ?? '—'}'),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.vpn_key_outlined, size: 14),
              const SizedBox(width: 4),
              Text(
                keyDisplay,
                style: TextStyle(
                  fontFamily: 'monospace',
                  letterSpacing: _revealed ? 2 : 4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (passKey != null) ...[
                IconButton(
                  iconSize: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  icon: Icon(_revealed ? Icons.visibility_off : Icons.visibility),
                  tooltip: _revealed ? 'Yashirish' : 'Ko\'rsatish',
                  onPressed: () => setState(() => _revealed = !_revealed),
                ),
                IconButton(
                  iconSize: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: 'Nusxa',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: passKey));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nusxa olindi')),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          switch (v) {
            case 'edit':
              widget.onEdit();
              break;
            case 'show':
              widget.onShowPassKey();
              break;
            case 'regen':
              widget.onRegenerate();
              break;
            case 'toggle':
              widget.onToggleActive();
              break;
            case 'delete':
              widget.onDelete();
              break;
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
          if (passKey != null)
            const PopupMenuItem(value: 'show', child: Text('Kodni katta ko\'rinishda')),
          const PopupMenuItem(value: 'regen', child: Text('Yangi kirish kodi')),
          PopupMenuItem(
            value: 'toggle',
            child: Text(user.active ? 'Faol emas qilish' : 'Faollashtirish'),
          ),
          const PopupMenuItem(value: 'delete', child: Text('O\'chirish')),
        ],
      ),
      onTap: widget.onEdit,
    );
  }

  String _roleLabel(Role r) {
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
