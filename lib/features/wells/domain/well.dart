import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/constants/object_status.dart';

part 'well.freezed.dart';

@freezed
abstract class Well with _$Well {
  const factory Well({
    required String id,
    required String code,
    required GeoPoint location,
    @Default(ObjectStatus.planned) ObjectStatus status,
    @Default(true) bool paid,
    DateTime? installedAt,
    String? masterId,
    String? notes,
    @Default(<String>[]) List<String> photoUrls,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) = _Well;
}
