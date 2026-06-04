import 'package:freezed_annotation/freezed_annotation.dart';

part 'master.freezed.dart';

@freezed
abstract class Master with _$Master {
  const factory Master({
    required String id,
    required String name,
    String? phone,
    @Default(true) bool active,
    DateTime? createdAt,
    String? createdBy,
  }) = _Master;
}
