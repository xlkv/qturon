import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/constants/object_status.dart';

part 'pipe.freezed.dart';

@freezed
abstract class Pipe with _$Pipe {
  const factory Pipe({
    required String id,
    required String code,
    required List<GeoPoint> points,
    required int diameterMm,
    required double lengthM,
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
  }) = _Pipe;
}
