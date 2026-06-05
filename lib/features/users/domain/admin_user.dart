import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/role.dart';

part 'admin_user.freezed.dart';

@freezed
abstract class AdminUser with _$AdminUser {
  const factory AdminUser({
    required String id,
    required String name,
    required Role role,
    String? phone,
    String? passKey,
    @Default(true) bool active,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) = _AdminUser;
}
