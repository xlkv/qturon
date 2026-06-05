import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/firebase/rest/firestore_rest.dart';
import '../../auth/domain/role.dart';
import '../domain/admin_user.dart';

class UsersAdminRepository {
  UsersAdminRepository(this._fs);

  final FirestoreRest _fs;
  static const _uuid = Uuid();
  static final _random = math.Random.secure();

  Stream<List<AdminUser>> watchAll() {
    return _fs.streamCollection('users').map((docs) {
      final users = docs.map(_fromDoc).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return users;
    });
  }

  Future<List<AdminUser>> getAll() async {
    final docs = await _fs.listDocs('users');
    return docs.map(_fromDoc).toList(growable: false);
  }

  /// Yangi user yaratadi. Pass-key avtomatik generate qilinadi.
  /// Returns: yaratilgan user va plain pass-key (super-admin'ga ko'rsatish uchun).
  Future<({AdminUser user, String passKey})> create({
    required String name,
    required Role role,
    String? phone,
  }) async {
    final id = _uuid.v4();
    final passKey = await _uniquePassKey();
    final now = DateTime.now().toUtc();
    await _fs.setDoc('users/$id', {
      'id': id,
      'name': name,
      'role': role.wire,
      'phone': phone,
      'passKey': passKey,
      'active': true,
      'createdAt': now,
      'lastLoginAt': null,
    });
    return (
      user: AdminUser(
        id: id,
        name: name,
        role: role,
        phone: phone,
        active: true,
        createdAt: now,
      ),
      passKey: passKey,
    );
  }

  Future<void> update(AdminUser u) async {
    await _fs.setDoc('users/${u.id}', {
      'name': u.name,
      'role': u.role.wire,
      'phone': u.phone,
      'active': u.active,
    }, merge: true);
  }

  Future<String> regeneratePassKey(String userId) async {
    final newKey = await _uniquePassKey();
    await _fs.setDoc('users/$userId', {'passKey': newKey}, merge: true);
    return newKey;
  }

  Future<void> delete(String userId) async {
    await _fs.deleteDoc('users/$userId');
  }

  Future<String> _uniquePassKey() async {
    final existing = await _fs.listDocs('users');
    final usedKeys = <String>{
      for (final d in existing)
        if (d.data['passKey'] is String) d.data['passKey'] as String,
    };
    for (var i = 0; i < 200; i++) {
      final key = _randomPassKey();
      if (!usedKeys.contains(key)) return key;
    }
    throw const UnknownException('passkey_collision');
  }

  String _randomPassKey() {
    final n = _random.nextInt(900000) + 100000; // 6 xona
    return n.toString();
  }

  AdminUser _fromDoc(DocSnapshot doc) {
    final d = doc.data;
    return AdminUser(
      id: doc.id,
      name: (d['name'] as String?) ?? '',
      role: Role.fromWire(d['role'] as String?),
      phone: d['phone'] as String?,
      passKey: d['passKey'] as String?,
      active: (d['active'] as bool?) ?? true,
      createdAt: d['createdAt'] as DateTime?,
      lastLoginAt: d['lastLoginAt'] as DateTime?,
    );
  }
}

final usersAdminRepositoryProvider = Provider<UsersAdminRepository>((ref) {
  return UsersAdminRepository(ref.watch(firestoreRestProvider));
});

final usersAdminStreamProvider = StreamProvider<List<AdminUser>>((ref) {
  return ref.watch(usersAdminRepositoryProvider).watchAll();
});
