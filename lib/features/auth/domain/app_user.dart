import 'package:freezed_annotation/freezed_annotation.dart';

import 'role.dart';

part 'app_user.freezed.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String name,
    required Role role,
    @Default(<String>[]) List<String> cityIds,
    String? phone,
    DateTime? lastLoginAt,
  }) = _AppUser;
}
