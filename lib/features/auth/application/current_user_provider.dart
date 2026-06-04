import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_user.dart';
import '../domain/role.dart';

final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final fbUser = ref.watch(firebaseAuthStateProvider).valueOrNull;
  if (fbUser == null) return null;

  final tokenResult = await fbUser.getIdTokenResult();
  final claims = tokenResult.claims ?? <String, dynamic>{};

  return AppUser(
    id: fbUser.uid,
    name: (claims['name'] as String?) ?? fbUser.displayName ?? '',
    role: Role.fromWire(claims['role'] as String?),
    cityIds: List<String>.from((claims['cityIds'] as List?) ?? const []),
  );
});
