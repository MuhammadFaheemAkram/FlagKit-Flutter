// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flag_detail_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FlagDetailState {

 String get key;/// `null`: FlagKit knows nothing of the flag (a stale link).
 FlagInspection? get inspection;/// What was wrong with the last override typed, in words.
 String? get overrideError;
/// Create a copy of FlagDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlagDetailStateCopyWith<FlagDetailState> get copyWith => _$FlagDetailStateCopyWithImpl<FlagDetailState>(this as FlagDetailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FlagDetailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlagDetailState&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.inspection, _this.inspection) || other.inspection == _this.inspection)&&(identical(other.overrideError, _this.overrideError) || other.overrideError == _this.overrideError));
}


@override
int get hashCode {
  final _this = this as FlagDetailState;
  return Object.hash(runtimeType,_this.key,_this.inspection,_this.overrideError);
}

@override
String toString() {
  final _this = this as FlagDetailState;
  return 'FlagDetailState(key: ${_this.key}, inspection: ${_this.inspection}, overrideError: ${_this.overrideError})';
}


}

/// @nodoc
abstract mixin class $FlagDetailStateCopyWith<$Res>  {
  factory $FlagDetailStateCopyWith(FlagDetailState value, $Res Function(FlagDetailState) _then) = _$FlagDetailStateCopyWithImpl;
@useResult
$Res call({
 String key, FlagInspection? inspection, String? overrideError
});




}
/// @nodoc
class _$FlagDetailStateCopyWithImpl<$Res>
    implements $FlagDetailStateCopyWith<$Res> {
  _$FlagDetailStateCopyWithImpl(this._self, this._then);

  final FlagDetailState _self;
  final $Res Function(FlagDetailState) _then;

/// Create a copy of FlagDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? inspection = freezed,Object? overrideError = freezed,}) {
  return _then(FlagDetailState(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,inspection: freezed == inspection ? _self.inspection : inspection // ignore: cast_nullable_to_non_nullable
as FlagInspection?,overrideError: freezed == overrideError ? _self.overrideError : overrideError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FlagDetailState].
extension FlagDetailStatePatterns on FlagDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlagDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlagDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlagDetailState value)  $default,){
final _that = this;
switch (_that) {
case _FlagDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlagDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _FlagDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  FlagInspection? inspection,  String? overrideError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlagDetailState() when $default != null:
return $default(_that.key,_that.inspection,_that.overrideError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  FlagInspection? inspection,  String? overrideError)  $default,) {final _that = this;
switch (_that) {
case _FlagDetailState():
return $default(_that.key,_that.inspection,_that.overrideError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  FlagInspection? inspection,  String? overrideError)?  $default,) {final _that = this;
switch (_that) {
case _FlagDetailState() when $default != null:
return $default(_that.key,_that.inspection,_that.overrideError);case _:
  return null;

}
}

}

/// @nodoc


class _FlagDetailState implements FlagDetailState {
  const _FlagDetailState({required this.key, this.inspection, this.overrideError});
  

@override final  String key;
/// `null`: FlagKit knows nothing of the flag (a stale link).
@override final  FlagInspection? inspection;
/// What was wrong with the last override typed, in words.
@override final  String? overrideError;

/// Create a copy of FlagDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlagDetailStateCopyWith<_FlagDetailState> get copyWith => __$FlagDetailStateCopyWithImpl<_FlagDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlagDetailState&&(identical(other.key, key) || other.key == key)&&(identical(other.inspection, inspection) || other.inspection == inspection)&&(identical(other.overrideError, overrideError) || other.overrideError == overrideError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,inspection,overrideError);
}

@override
String toString() {
    return 'FlagDetailState(key: $key, inspection: $inspection, overrideError: $overrideError)';
}


}

/// @nodoc
abstract mixin class _$FlagDetailStateCopyWith<$Res> implements $FlagDetailStateCopyWith<$Res> {
  factory _$FlagDetailStateCopyWith(_FlagDetailState value, $Res Function(_FlagDetailState) _then) = __$FlagDetailStateCopyWithImpl;
@override @useResult
$Res call({
 String key, FlagInspection? inspection, String? overrideError
});




}
/// @nodoc
class __$FlagDetailStateCopyWithImpl<$Res>
    implements _$FlagDetailStateCopyWith<$Res> {
  __$FlagDetailStateCopyWithImpl(this._self, this._then);

  final _FlagDetailState _self;
  final $Res Function(_FlagDetailState) _then;

/// Create a copy of FlagDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? inspection = freezed,Object? overrideError = freezed,}) {
  return _then(_FlagDetailState(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,inspection: freezed == inspection ? _self.inspection : inspection // ignore: cast_nullable_to_non_nullable
as FlagInspection?,overrideError: freezed == overrideError ? _self.overrideError : overrideError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
