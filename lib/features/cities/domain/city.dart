import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'city.freezed.dart';

@freezed
abstract class City with _$City {
  const factory City({
    required String id,
    required String name,
    required GeoPoint center,
    @Default(12.0) double defaultZoom,
    @Default(true) bool active,
    DateTime? createdAt,
    String? createdBy,
  }) = _City;
}
