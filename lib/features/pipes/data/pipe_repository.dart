import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/object_status.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/geo_point.dart';
import '../../../data/firebase/rest/firebase_auth_rest.dart';
import '../../../data/firebase/rest/firestore_rest.dart';
import '../domain/pipe.dart';

class PipeRepository {
  PipeRepository(this._fs, this._auth);

  final FirestoreRest _fs;
  final FirebaseAuthRest _auth;

  Stream<List<Pipe>> watchAll() {
    return _fs.streamCollection('pipes').map((docs) {
      final list = docs.map(_fromDoc).toList()
        ..sort((a, b) => a.code.compareTo(b.code));
      return list;
    });
  }

  Future<Pipe?> get(String id) async {
    final snap = await _fs.getDoc('pipes/$id');
    return snap == null || !snap.exists ? null : _fromDoc(snap);
  }

  Stream<Pipe?> watch(String id) {
    return _fs.streamDoc('pipes/$id').map((s) {
      return s == null || !s.exists ? null : _fromDoc(s);
    });
  }

  Future<Pipe> create({
    required String code,
    required List<GeoPoint> points,
    required int diameterMm,
    required double lengthM,
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
    final snap = await _fs.addDoc('pipes', {
      'code': code,
      'points': points,
      'diameterMm': diameterMm,
      'lengthM': lengthM,
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
    return Pipe(
      id: snap.id,
      code: code,
      points: points,
      diameterMm: diameterMm,
      lengthM: lengthM,
      status: status,
      paid: paid,
      installedAt: installedAt,
      masterId: masterId,
      notes: notes,
      photoUrls: photoUrls,
      createdAt: now,
      createdBy: uid,
      updatedAt: now,
      updatedBy: uid,
    );
  }

  Future<void> update(Pipe p) async {
    final uid = _auth.currentUid;
    final now = DateTime.now().toUtc();
    await _fs.setDoc('pipes/${p.id}', {
      'code': p.code,
      'points': p.points,
      'diameterMm': p.diameterMm,
      'lengthM': p.lengthM,
      'status': p.status.wire,
      'paid': p.paid,
      'installedAt': p.installedAt,
      'masterId': p.masterId,
      'notes': p.notes,
      'photoUrls': p.photoUrls,
      'updatedAt': now,
      'updatedBy': uid,
    }, merge: true);
  }

  Future<void> delete(String id) async {
    await _fs.deleteDoc('pipes/$id');
  }

  Pipe _fromDoc(DocSnapshot doc) {
    final d = doc.data;
    final raw = (d['points'] as List?) ?? const [];
    final points = raw.whereType<GeoPoint>().toList(growable: false);
    return Pipe(
      id: doc.id,
      code: (d['code'] as String?) ?? '?',
      points: points,
      diameterMm: (d['diameterMm'] as int?) ?? 0,
      lengthM: (d['lengthM'] as num?)?.toDouble() ?? 0,
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

final pipeRepositoryProvider = Provider<PipeRepository>((ref) {
  return PipeRepository(
    ref.watch(firestoreRestProvider),
    ref.watch(firebaseAuthRestProvider),
  );
});

final pipesStreamProvider = StreamProvider<List<Pipe>>((ref) {
  return ref.watch(pipeRepositoryProvider).watchAll();
});

final pipeStreamProvider = StreamProvider.family<Pipe?, String>((ref, id) {
  return ref.watch(pipeRepositoryProvider).watch(id);
});
