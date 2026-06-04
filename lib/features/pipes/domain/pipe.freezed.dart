// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Pipe {

 String get id; String get code; List<GeoPoint> get points; int get diameterMm; double get lengthM; ObjectStatus get status; bool get paid; DateTime? get installedAt; String? get masterId; String? get notes; List<String> get photoUrls; DateTime? get createdAt; String? get createdBy; DateTime? get updatedAt; String? get updatedBy;
/// Create a copy of Pipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PipeCopyWith<Pipe> get copyWith => _$PipeCopyWithImpl<Pipe>(this as Pipe, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pipe&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.diameterMm, diameterMm) || other.diameterMm == diameterMm)&&(identical(other.lengthM, lengthM) || other.lengthM == lengthM)&&(identical(other.status, status) || other.status == status)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.installedAt, installedAt) || other.installedAt == installedAt)&&(identical(other.masterId, masterId) || other.masterId == masterId)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.photoUrls, photoUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,code,const DeepCollectionEquality().hash(points),diameterMm,lengthM,status,paid,installedAt,masterId,notes,const DeepCollectionEquality().hash(photoUrls),createdAt,createdBy,updatedAt,updatedBy);

@override
String toString() {
  return 'Pipe(id: $id, code: $code, points: $points, diameterMm: $diameterMm, lengthM: $lengthM, status: $status, paid: $paid, installedAt: $installedAt, masterId: $masterId, notes: $notes, photoUrls: $photoUrls, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class $PipeCopyWith<$Res>  {
  factory $PipeCopyWith(Pipe value, $Res Function(Pipe) _then) = _$PipeCopyWithImpl;
@useResult
$Res call({
 String id, String code, List<GeoPoint> points, int diameterMm, double lengthM, ObjectStatus status, bool paid, DateTime? installedAt, String? masterId, String? notes, List<String> photoUrls, DateTime? createdAt, String? createdBy, DateTime? updatedAt, String? updatedBy
});




}
/// @nodoc
class _$PipeCopyWithImpl<$Res>
    implements $PipeCopyWith<$Res> {
  _$PipeCopyWithImpl(this._self, this._then);

  final Pipe _self;
  final $Res Function(Pipe) _then;

/// Create a copy of Pipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? points = null,Object? diameterMm = null,Object? lengthM = null,Object? status = null,Object? paid = null,Object? installedAt = freezed,Object? masterId = freezed,Object? notes = freezed,Object? photoUrls = null,Object? createdAt = freezed,Object? createdBy = freezed,Object? updatedAt = freezed,Object? updatedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<GeoPoint>,diameterMm: null == diameterMm ? _self.diameterMm : diameterMm // ignore: cast_nullable_to_non_nullable
as int,lengthM: null == lengthM ? _self.lengthM : lengthM // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ObjectStatus,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as bool,installedAt: freezed == installedAt ? _self.installedAt : installedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,masterId: freezed == masterId ? _self.masterId : masterId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Pipe].
extension PipePatterns on Pipe {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pipe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pipe() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pipe value)  $default,){
final _that = this;
switch (_that) {
case _Pipe():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pipe value)?  $default,){
final _that = this;
switch (_that) {
case _Pipe() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  List<GeoPoint> points,  int diameterMm,  double lengthM,  ObjectStatus status,  bool paid,  DateTime? installedAt,  String? masterId,  String? notes,  List<String> photoUrls,  DateTime? createdAt,  String? createdBy,  DateTime? updatedAt,  String? updatedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pipe() when $default != null:
return $default(_that.id,_that.code,_that.points,_that.diameterMm,_that.lengthM,_that.status,_that.paid,_that.installedAt,_that.masterId,_that.notes,_that.photoUrls,_that.createdAt,_that.createdBy,_that.updatedAt,_that.updatedBy);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  List<GeoPoint> points,  int diameterMm,  double lengthM,  ObjectStatus status,  bool paid,  DateTime? installedAt,  String? masterId,  String? notes,  List<String> photoUrls,  DateTime? createdAt,  String? createdBy,  DateTime? updatedAt,  String? updatedBy)  $default,) {final _that = this;
switch (_that) {
case _Pipe():
return $default(_that.id,_that.code,_that.points,_that.diameterMm,_that.lengthM,_that.status,_that.paid,_that.installedAt,_that.masterId,_that.notes,_that.photoUrls,_that.createdAt,_that.createdBy,_that.updatedAt,_that.updatedBy);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  List<GeoPoint> points,  int diameterMm,  double lengthM,  ObjectStatus status,  bool paid,  DateTime? installedAt,  String? masterId,  String? notes,  List<String> photoUrls,  DateTime? createdAt,  String? createdBy,  DateTime? updatedAt,  String? updatedBy)?  $default,) {final _that = this;
switch (_that) {
case _Pipe() when $default != null:
return $default(_that.id,_that.code,_that.points,_that.diameterMm,_that.lengthM,_that.status,_that.paid,_that.installedAt,_that.masterId,_that.notes,_that.photoUrls,_that.createdAt,_that.createdBy,_that.updatedAt,_that.updatedBy);case _:
  return null;

}
}

}

/// @nodoc


class _Pipe implements Pipe {
  const _Pipe({required this.id, required this.code, required final  List<GeoPoint> points, required this.diameterMm, required this.lengthM, this.status = ObjectStatus.planned, this.paid = true, this.installedAt, this.masterId, this.notes, final  List<String> photoUrls = const <String>[], this.createdAt, this.createdBy, this.updatedAt, this.updatedBy}): _points = points,_photoUrls = photoUrls;
  

@override final  String id;
@override final  String code;
 final  List<GeoPoint> _points;
@override List<GeoPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  int diameterMm;
@override final  double lengthM;
@override@JsonKey() final  ObjectStatus status;
@override@JsonKey() final  bool paid;
@override final  DateTime? installedAt;
@override final  String? masterId;
@override final  String? notes;
 final  List<String> _photoUrls;
@override@JsonKey() List<String> get photoUrls {
  if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoUrls);
}

@override final  DateTime? createdAt;
@override final  String? createdBy;
@override final  DateTime? updatedAt;
@override final  String? updatedBy;

/// Create a copy of Pipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PipeCopyWith<_Pipe> get copyWith => __$PipeCopyWithImpl<_Pipe>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pipe&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.diameterMm, diameterMm) || other.diameterMm == diameterMm)&&(identical(other.lengthM, lengthM) || other.lengthM == lengthM)&&(identical(other.status, status) || other.status == status)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.installedAt, installedAt) || other.installedAt == installedAt)&&(identical(other.masterId, masterId) || other.masterId == masterId)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._photoUrls, _photoUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,code,const DeepCollectionEquality().hash(_points),diameterMm,lengthM,status,paid,installedAt,masterId,notes,const DeepCollectionEquality().hash(_photoUrls),createdAt,createdBy,updatedAt,updatedBy);

@override
String toString() {
  return 'Pipe(id: $id, code: $code, points: $points, diameterMm: $diameterMm, lengthM: $lengthM, status: $status, paid: $paid, installedAt: $installedAt, masterId: $masterId, notes: $notes, photoUrls: $photoUrls, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class _$PipeCopyWith<$Res> implements $PipeCopyWith<$Res> {
  factory _$PipeCopyWith(_Pipe value, $Res Function(_Pipe) _then) = __$PipeCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, List<GeoPoint> points, int diameterMm, double lengthM, ObjectStatus status, bool paid, DateTime? installedAt, String? masterId, String? notes, List<String> photoUrls, DateTime? createdAt, String? createdBy, DateTime? updatedAt, String? updatedBy
});




}
/// @nodoc
class __$PipeCopyWithImpl<$Res>
    implements _$PipeCopyWith<$Res> {
  __$PipeCopyWithImpl(this._self, this._then);

  final _Pipe _self;
  final $Res Function(_Pipe) _then;

/// Create a copy of Pipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? points = null,Object? diameterMm = null,Object? lengthM = null,Object? status = null,Object? paid = null,Object? installedAt = freezed,Object? masterId = freezed,Object? notes = freezed,Object? photoUrls = null,Object? createdAt = freezed,Object? createdBy = freezed,Object? updatedAt = freezed,Object? updatedBy = freezed,}) {
  return _then(_Pipe(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<GeoPoint>,diameterMm: null == diameterMm ? _self.diameterMm : diameterMm // ignore: cast_nullable_to_non_nullable
as int,lengthM: null == lengthM ? _self.lengthM : lengthM // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ObjectStatus,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as bool,installedAt: freezed == installedAt ? _self.installedAt : installedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,masterId: freezed == masterId ? _self.masterId : masterId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
