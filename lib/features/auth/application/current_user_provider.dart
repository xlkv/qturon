import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/firebase/rest/firebase_auth_rest.dart';
import '../../../data/firebase/rest/firestore_rest.dart';
import '../domain/app_user.dart';
import '../domain/role.dart';

/// Joriy sign-in holati (uid yoki null).
final authStateProvider = StreamProvider<String?>((ref) {
  return ref.watch(firebaseAuthRestProvider).authStateChanges();
});

/// Joriy foydalanuvchi — Firestore `/users/{uid}` doc'idan o'qiladi (polling).
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull;
  if (uid == null) {
    return Stream<AppUser?>.value(null);
  }
  final firestore = ref.watch(firestoreRestProvider);
  return firestore.streamDoc('users/$uid').map((snap) {
    if (snap == null || !snap.exists) {
      return AppUser(id: uid, name: '', role: Role.user);
    }
    final data = snap.data;
    return AppUser(
      id: uid,
      name: (data['name'] as String?) ?? '',
      role: Role.fromWire(data['role'] as String?),
      phone: data['phone'] as String?,
      lastLoginAt: data['lastLoginAt'] as DateTime?,
    );
  });
});
