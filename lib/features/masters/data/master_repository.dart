import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/firebase/rest/firebase_auth_rest.dart';
import '../../../data/firebase/rest/firestore_rest.dart';
import '../domain/master.dart';

class MasterRepository {
  MasterRepository(this._fs, this._auth);

  final FirestoreRest _fs;
  final FirebaseAuthRest _auth;

  Stream<List<Master>> watchAll({bool activeOnly = false}) {
    return _fs.streamCollection('masters').map((docs) {
      var list = docs.map(_fromDoc).toList();
      if (activeOnly) list = list.where((m) => m.active).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    });
  }

  Future<Master> create({required String name, String? phone}) async {
    final uid = _auth.currentUid;
    if (uid == null) throw const AuthException('not_signed_in');
    final now = DateTime.now().toUtc();
    final snap = await _fs.addDoc('masters', {
      'name': name,
      'phone': phone,
      'active': true,
      'createdAt': now,
      'createdBy': uid,
    });
    return Master(
      id: snap.id,
      name: name,
      phone: phone,
      createdAt: now,
      createdBy: uid,
    );
  }

  Future<void> update(Master m) async {
    await _fs.setDoc('masters/${m.id}', {
      'name': m.name,
      'phone': m.phone,
      'active': m.active,
    }, merge: true);
  }

  Future<void> delete(String id) async {
    await _fs.deleteDoc('masters/$id');
  }

  Master _fromDoc(DocSnapshot doc) {
    final d = doc.data;
    return Master(
      id: doc.id,
      name: (d['name'] as String?) ?? '',
      phone: d['phone'] as String?,
      active: (d['active'] as bool?) ?? true,
      createdAt: d['createdAt'] as DateTime?,
      createdBy: d['createdBy'] as String?,
    );
  }
}

final masterRepositoryProvider = Provider<MasterRepository>((ref) {
  return MasterRepository(
    ref.watch(firestoreRestProvider),
    ref.watch(firebaseAuthRestProvider),
  );
});

final mastersStreamProvider = StreamProvider<List<Master>>((ref) {
  return ref.watch(masterRepositoryProvider).watchAll();
});

final activeMastersStreamProvider = StreamProvider<List<Master>>((ref) {
  return ref.watch(masterRepositoryProvider).watchAll(activeOnly: true);
});
