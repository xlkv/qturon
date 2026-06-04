// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'master.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Master {

 String get id; String get name; String? get phone; bool get active; DateTime? get createdAt; String? get createdBy;
/// Create a copy of Master
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MasterCopyWith<Master> get copyWith => _$MasterCopyWithImpl<Master>(this as Master, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Master&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,phone,active,createdAt,createdBy);

@override
String toString() {
  return 'Master(id: $id, name: $name, phone: $phone, active: $active, createdAt: $createdAt, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class $MasterCopyWith<$Res>  {
  factory $MasterCopyWith(Master value, $Res Function(Master) _then) = _$MasterCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? phone, bool active, DateTime? createdAt, String? createdBy
});




}
/// @nodoc
class _$MasterCopyWithImpl<$Res>
    implements $MasterCopyWith<$Res> {
  _$MasterCopyWithImpl(this._self, this._then);

  final Master _self;
  final $Res Function(Master) _then;

/// Create a copy of Master
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phone = freezed,Object? active = null,Object? createdAt = freezed,Object? createdBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Master].
extension MasterPatterns on Master {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Master value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Master() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Master value)  $default,){
final _that = this;
switch (_that) {
case _Master():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Master value)?  $default,){
final _that = this;
switch (_that) {
case _Master() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? phone,  bool active,  DateTime? createdAt,  String? createdBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Master() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.active,_that.createdAt,_that.createdBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? phone,  bool active,  DateTime? createdAt,  String? createdBy)  $default,) {final _that = this;
switch (_that) {
case _Master():
return $default(_that.id,_that.name,_that.phone,_that.active,_that.createdAt,_that.createdBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? phone,  bool active,  DateTime? createdAt,  String? createdBy)?  $default,) {final _that = this;
switch (_that) {
case _Master() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.active,_that.createdAt,_that.createdBy);case _:
  return null;

}
}

}

/// @nodoc


class _Master implements Master {
  const _Master({required this.id, required this.name, this.phone, this.active = true, this.createdAt, this.createdBy});
  

@override final  String id;
@override final  String name;
@override final  String? phone;
@override@JsonKey() final  bool active;
@override final  DateTime? createdAt;
@override final  String? createdBy;

/// Create a copy of Master
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MasterCopyWith<_Master> get copyWith => __$MasterCopyWithImpl<_Master>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Master&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,phone,active,createdAt,createdBy);

@override
String toString() {
  return 'Master(id: $id, name: $name, phone: $phone, active: $active, createdAt: $createdAt, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class _$MasterCopyWith<$Res> implements $MasterCopyWith<$Res> {
  factory _$MasterCopyWith(_Master value, $Res Function(_Master) _then) = __$MasterCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? phone, bool active, DateTime? createdAt, String? createdBy
});




}
/// @nodoc
class __$MasterCopyWithImpl<$Res>
    implements _$MasterCopyWith<$Res> {
  __$MasterCopyWithImpl(this._self, this._then);

  final _Master _self;
  final $Res Function(_Master) _then;

/// Create a copy of Master
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phone = freezed,Object? active = null,Object? createdAt = freezed,Object? createdBy = freezed,}) {
  return _then(_Master(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
