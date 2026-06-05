import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/city.dart';

class CityRepository {
  CityRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('cities');

  Stream<List<City>> watchAll() {
    return _col.orderBy('name').snapshots().map((snap) {
      return snap.docs.map(_fromDoc).toList(growable: false);
    });
  }

  Future<List<City>> getAll() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs.map(_fromDoc).toList(growable: false);
  }

  Future<City> create({
    required String name,
    required GeoPoint center,
    required double defaultZoom,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('not_signed_in');

    final docRef = _col.doc();
    final data = {
      'id': docRef.id,
      'name': name,
      'center': center,
      'defaultZoom': defaultZoom,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': uid,
    };
    await docRef.set(data);
    return City(
      id: docRef.id,
      name: name,
      center: center,
      defaultZoom: defaultZoom,
      createdBy: uid,
    );
  }

  Future<void> update(City city) async {
    await _col.doc(city.id).update({
      'name': city.name,
      'center': city.center,
      'defaultZoom': city.defaultZoom,
      'active': city.active,
    });
  }

  Future<void> delete(String cityId) async {
    await _col.doc(cityId).delete();
  }

  City _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return City(
      id: doc.id,
      name: (d['name'] as String?) ?? '',
      center: (d['center'] as GeoPoint?) ?? const GeoPoint(41.31, 69.27),
      defaultZoom: (d['defaultZoom'] as num?)?.toDouble() ?? 12.0,
      active: (d['active'] as bool?) ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      createdBy: d['createdBy'] as String?,
    );
  }
}

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  return CityRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final citiesStreamProvider = StreamProvider<List<City>>((ref) {
  return ref.watch(cityRepositoryProvider).watchAll();
});
