import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/object_status.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/geo_point.dart';
import '../../../data/firebase/rest/firebase_auth_rest.dart';
import '../../../data/firebase/rest/firestore_rest.dart';
import '../domain/well.dart';

class WellRepository {
  WellRepository(this._fs, this._auth);

  final FirestoreRest _fs;
  final FirebaseAuthRest _auth;

  Stream<List<Well>> watchAll() {
    return _fs.streamCollection('wells').map((docs) {
      final wells = docs.map(_fromDoc).toList()
        ..sort((a, b) => a.code.compareTo(b.code));
      return wells;
    });
  }

  Future<Well?> get(String id) async {
    final snap = await _fs.getDoc('wells/$id');
    return snap == null || !snap.exists ? null : _fromDoc(snap);
  }

  Stream<Well?> watch(String id) {
    return _fs.streamDoc('wells/$id').map((snap) {
      return snap == null || !snap.exists ? null : _fromDoc(snap);
    });
  }

  Future<Well> create({
    required String code,
    required GeoPoint location,
    required ObjectStatus status,
    required bool paid,
    DateTime? installedAt,
    String? masterId,
    String? notes,
    List<String> photoUrls = const [],
  }) async {
    final uid = _auth.currentUid;
    if (uid == null) throw const AuthException('not_signed_in');

    final now = DateTime.now().toUtc();
    final snap = await _fs.addDoc('wells', {
      'code': code,
      'location': location,
      'status': status.wire,
      'paid': paid,
      'installedAt': installedAt,
      'masterId': masterId,
      'notes': notes,
      'photoUrls': photoUrls,
      'createdAt': now,
      'createdBy': uid,
      'updatedAt': now,
      'updatedBy': uid,
    });
    return Well(
      id: snap.id,
      code: code,
      location: location,
      status: status,
      paid: paid,
      installedAt: installedAt,
      masterId: masterId,
      notes: notes,
      createdAt: now,
      createdBy: uid,
      updatedAt: now,
      updatedBy: uid,
    );
  }

  Future<void> update(Well w) async {
    final uid = _auth.currentUid;
    final now = DateTime.now().toUtc();
    await _fs.setDoc('wells/${w.id}', {
      'code': w.code,
      'location': w.location,
      'status': w.status.wire,
      'paid': w.paid,
      'installedAt': w.installedAt,
      'masterId': w.masterId,
      'notes': w.notes,
      'photoUrls': w.photoUrls,
      'updatedAt': now,
      'updatedBy': uid,
    }, merge: true);
  }

  Future<void> delete(String id) async {
    await _fs.deleteDoc('wells/$id');
  }

  Well _fromDoc(DocSnapshot doc) {
    final d = doc.data;
    final location = d['location'];
    return Well(
      id: doc.id,
      code: (d['code'] as String?) ?? '?',
      location: location is GeoPoint ? location : const GeoPoint(0, 0),
      status: ObjectStatus.fromWire(d['status'] as String?),
      paid: (d['paid'] as bool?) ?? true,
      installedAt: d['installedAt'] as DateTime?,
      masterId: d['masterId'] as String?,
      notes: d['notes'] as String?,
      photoUrls: ((d['photoUrls'] as List?) ?? const [])
          .whereType<String>()
          .toList(growable: false),
      createdAt: d['createdAt'] as DateTime?,
      createdBy: d['createdBy'] as String?,
      updatedAt: d['updatedAt'] as DateTime?,
      updatedBy: d['updatedBy'] as String?,
    );
  }
}

final wellRepositoryProvider = Provider<WellRepository>((ref) {
  return WellRepository(
    ref.watch(firestoreRestProvider),
    ref.watch(firebaseAuthRestProvider),
  );
});

final wellsStreamProvider = StreamProvider<List<Well>>((ref) {
  return ref.watch(wellRepositoryProvider).watchAll();
});

final wellStreamProvider = StreamProvider.family<Well?, String>((ref, id) {
  return ref.watch(wellRepositoryProvider).watch(id);
});
