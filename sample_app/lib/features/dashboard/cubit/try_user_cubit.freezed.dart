// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'try_user_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TryUserState {

/// The id typed, trimmed; empty: nothing to show.
 String get userId; List<FlagReading> get readings;
/// Create a copy of TryUserState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TryUserStateCopyWith<TryUserState> get copyWith => _$TryUserStateCopyWithImpl<TryUserState>(this as TryUserState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TryUserState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TryUserState&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&const DeepCollectionEquality().equals(other.readings, _this.readings));
}


@override
int get hashCode {
  final _this = this as TryUserState;
  return Object.hash(runtimeType,_this.userId,const DeepCollectionEquality().hash(_this.readings));
}

@override
String toString() {
  final _this = this as TryUserState;
  return 'TryUserState(userId: ${_this.userId}, readings: ${_this.readings})';
}


}

/// @nodoc
abstract mixin class $TryUserStateCopyWith<$Res>  {
  factory $TryUserStateCopyWith(TryUserState value, $Res Function(TryUserState) _then) = _$TryUserStateCopyWithImpl;
@useResult
$Res call({
 String userId, List<FlagReading> readings
});




}
/// @nodoc
class _$TryUserStateCopyWithImpl<$Res>
    implements $TryUserStateCopyWith<$Res> {
  _$TryUserStateCopyWithImpl(this._self, this._then);

  final TryUserState _self;
  final $Res Function(TryUserState) _then;

/// Create a copy of TryUserState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? readings = null,}) {
  return _then(TryUserState(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,readings: null == readings ? _self.readings : readings // ignore: cast_nullable_to_non_nullable
as List<FlagReading>,
  ));
}

}


/// Adds pattern-matching-related methods to [TryUserState].
extension TryUserStatePatterns on TryUserState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TryUserState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TryUserState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TryUserState value)  $default,){
final _that = this;
switch (_that) {
case _TryUserState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TryUserState value)?  $default,){
final _that = this;
switch (_that) {
case _TryUserState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  List<FlagReading> readings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TryUserState() when $default != null:
return $default(_that.userId,_that.readings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  List<FlagReading> readings)  $default,) {final _that = this;
switch (_that) {
case _TryUserState():
return $default(_that.userId,_that.readings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  List<FlagReading> readings)?  $default,) {final _that = this;
switch (_that) {
case _TryUserState() when $default != null:
return $default(_that.userId,_that.readings);case _:
  return null;

}
}

}

/// @nodoc


class _TryUserState implements TryUserState {
  const _TryUserState({this.userId = '',  List<FlagReading> readings = const <FlagReading>[]}): _readings = readings;
  

/// The id typed, trimmed; empty: nothing to show.
@override@JsonKey() final  String userId;
 final  List<FlagReading> _readings;
@override@JsonKey() List<FlagReading> get readings {
  if (_readings is EqualUnmodifiableListView) return _readings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_readings);
}


/// Create a copy of TryUserState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TryUserStateCopyWith<_TryUserState> get copyWith => __$TryUserStateCopyWithImpl<_TryUserState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TryUserState&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.readings, _readings));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,const DeepCollectionEquality().hash(_readings));
}

@override
String toString() {
    return 'TryUserState(userId: $userId, readings: $readings)';
}


}

/// @nodoc
abstract mixin class _$TryUserStateCopyWith<$Res> implements $TryUserStateCopyWith<$Res> {
  factory _$TryUserStateCopyWith(_TryUserState value, $Res Function(_TryUserState) _then) = __$TryUserStateCopyWithImpl;
@override @useResult
$Res call({
 String userId, List<FlagReading> readings
});




}
/// @nodoc
class __$TryUserStateCopyWithImpl<$Res>
    implements _$TryUserStateCopyWith<$Res> {
  __$TryUserStateCopyWithImpl(this._self, this._then);

  final _TryUserState _self;
  final $Res Function(_TryUserState) _then;

/// Create a copy of TryUserState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? readings = null,}) {
  return _then(_TryUserState(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,readings: null == readings ? _self._readings : readings // ignore: cast_nullable_to_non_nullable
as List<FlagReading>,
  ));
}


}

// dart format on
