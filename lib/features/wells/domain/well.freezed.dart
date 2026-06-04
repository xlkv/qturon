// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'well.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Well {

 String get id; String get code; GeoPoint get location; ObjectStatus get status; bool get paid; DateTime? get installedAt; String? get masterId; String? get notes; List<String> get photoUrls; DateTime? get createdAt; String? get createdBy; DateTime? get updatedAt; String? get updatedBy;
/// Create a copy of Well
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WellCopyWith<Well> get copyWith => _$WellCopyWithImpl<Well>(this as Well, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Well&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.location, location) || other.location == location)&&(identical(other.status, status) || other.status == status)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.installedAt, installedAt) || other.installedAt == installedAt)&&(identical(other.masterId, masterId) || other.masterId == masterId)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.photoUrls, photoUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,code,location,status,paid,installedAt,masterId,notes,const DeepCollectionEquality().hash(photoUrls),createdAt,createdBy,updatedAt,updatedBy);

@override
String toString() {
  return 'Well(id: $id, code: $code, location: $location, status: $status, paid: $paid, installedAt: $installedAt, masterId: $masterId, notes: $notes, photoUrls: $photoUrls, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class $WellCopyWith<$Res>  {
  factory $WellCopyWith(Well value, $Res Function(Well) _then) = _$WellCopyWithImpl;
@useResult
$Res call({
 String id, String code, GeoPoint location, ObjectStatus status, bool paid, DateTime? installedAt, String? masterId, String? notes, List<String> photoUrls, DateTime? createdAt, String? createdBy, DateTime? updatedAt, String? updatedBy
});




}
/// @nodoc
class _$WellCopyWithImpl<$Res>
    implements $WellCopyWith<$Res> {
  _$WellCopyWithImpl(this._self, this._then);

  final Well _self;
  final $Res Function(Well) _then;

/// Create a copy of Well
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? location = null,Object? status = null,Object? paid = null,Object? installedAt = freezed,Object? masterId = freezed,Object? notes = freezed,Object? photoUrls = null,Object? createdAt = freezed,Object? createdBy = freezed,Object? updatedAt = freezed,Object? updatedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [Well].
extension WellPatterns on Well {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Well value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Well() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Well value)  $default,){
final _that = this;
switch (_that) {
case _Well():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Well value)?  $default,){
final _that = this;
switch (_that) {
case _Well() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  GeoPoint location,  ObjectStatus status,  bool paid,  DateTime? installedAt,  String? masterId,  String? notes,  List<String> photoUrls,  DateTime? createdAt,  String? createdBy,  DateTime? updatedAt,  String? updatedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Well() when $default != null:
return $default(_that.id,_that.code,_that.location,_that.status,_that.paid,_that.installedAt,_that.masterId,_that.notes,_that.photoUrls,_that.createdAt,_that.createdBy,_that.updatedAt,_that.updatedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  GeoPoint location,  ObjectStatus status,  bool paid,  DateTime? installedAt,  String? masterId,  String? notes,  List<String> photoUrls,  DateTime? createdAt,  String? createdBy,  DateTime? updatedAt,  String? updatedBy)  $default,) {final _that = this;
switch (_that) {
case _Well():
return $default(_that.id,_that.code,_that.location,_that.status,_that.paid,_that.installedAt,_that.masterId,_that.notes,_that.photoUrls,_that.createdAt,_that.createdBy,_that.updatedAt,_that.updatedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  GeoPoint location,  ObjectStatus status,  bool paid,  DateTime? installedAt,  String? masterId,  String? notes,  List<String> photoUrls,  DateTime? createdAt,  String? createdBy,  DateTime? updatedAt,  String? updatedBy)?  $default,) {final _that = this;
switch (_that) {
case _Well() when $default != null:
return $default(_that.id,_that.code,_that.location,_that.status,_that.paid,_that.installedAt,_that.masterId,_that.notes,_that.photoUrls,_that.createdAt,_that.createdBy,_that.updatedAt,_that.updatedBy);case _:
  return null;

}
}

}

/// @nodoc


class _Well implements Well {
  const _Well({required this.id, required this.code, required this.location, this.status = ObjectStatus.planned, this.paid = true, this.installedAt, this.masterId, this.notes, final  List<String> photoUrls = const <String>[], this.createdAt, this.createdBy, this.updatedAt, this.updatedBy}): _photoUrls = photoUrls;
  

@override final  String id;
@override final  String code;
@override final  GeoPoint location;
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

/// Create a copy of Well
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WellCopyWith<_Well> get copyWith => __$WellCopyWithImpl<_Well>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Well&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.location, location) || other.location == location)&&(identical(other.status, status) || other.status == status)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.installedAt, installedAt) || other.installedAt == installedAt)&&(identical(other.masterId, masterId) || other.masterId == masterId)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._photoUrls, _photoUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,code,location,status,paid,installedAt,masterId,notes,const DeepCollectionEquality().hash(_photoUrls),createdAt,createdBy,updatedAt,updatedBy);

@override
String toString() {
  return 'Well(id: $id, code: $code, location: $location, status: $status, paid: $paid, installedAt: $installedAt, masterId: $masterId, notes: $notes, photoUrls: $photoUrls, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class _$WellCopyWith<$Res> implements $WellCopyWith<$Res> {
  factory _$WellCopyWith(_Well value, $Res Function(_Well) _then) = __$WellCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, GeoPoint location, ObjectStatus status, bool paid, DateTime? installedAt, String? masterId, String? notes, List<String> photoUrls, DateTime? createdAt, String? createdBy, DateTime? updatedAt, String? updatedBy
});




}
/// @nodoc
class __$WellCopyWithImpl<$Res>
    implements _$WellCopyWith<$Res> {
  __$WellCopyWithImpl(this._self, this._then);

  final _Well _self;
  final $Res Function(_Well) _then;

/// Create a copy of Well
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? location = null,Object? status = null,Object? paid = null,Object? installedAt = freezed,Object? masterId = freezed,Object? notes = freezed,Object? photoUrls = null,Object? createdAt = freezed,Object? createdBy = freezed,Object? updatedAt = freezed,Object? updatedBy = freezed,}) {
  return _then(_Well(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
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
