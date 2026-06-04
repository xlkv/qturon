import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/current_user_provider.dart';
import '../../features/auth/domain/role.dart';
import 'permissions.dart';

final permissionsProvider = Provider<Permissions>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return Permissions(user?.role ?? Role.user);
});
