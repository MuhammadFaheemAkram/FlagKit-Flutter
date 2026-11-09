// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_console_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerConsoleState {

 List<ServerFlag> get flags; ServerKnobs get knobs;
/// Create a copy of ServerConsoleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerConsoleStateCopyWith<ServerConsoleState> get copyWith => _$ServerConsoleStateCopyWithImpl<ServerConsoleState>(this as ServerConsoleState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerConsoleState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerConsoleState&&const DeepCollectionEquality().equals(other.flags, _this.flags)&&(identical(other.knobs, _this.knobs) || other.knobs == _this.knobs));
}


@override
int get hashCode {
  final _this = this as ServerConsoleState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.flags),_this.knobs);
}

@override
String toString() {
  final _this = this as ServerConsoleState;
  return 'ServerConsoleState(flags: ${_this.flags}, knobs: ${_this.knobs})';
}


}

/// @nodoc
abstract mixin class $ServerConsoleStateCopyWith<$Res>  {
  factory $ServerConsoleStateCopyWith(ServerConsoleState value, $Res Function(ServerConsoleState) _then) = _$ServerConsoleStateCopyWithImpl;
@useResult
$Res call({
 List<ServerFlag> flags, ServerKnobs knobs
});




}
/// @nodoc
class _$ServerConsoleStateCopyWithImpl<$Res>
    implements $ServerConsoleStateCopyWith<$Res> {
  _$ServerConsoleStateCopyWithImpl(this._self, this._then);

  final ServerConsoleState _self;
  final $Res Function(ServerConsoleState) _then;

/// Create a copy of ServerConsoleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flags = null,Object? knobs = null,}) {
  return _then(ServerConsoleState(
flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as List<ServerFlag>,knobs: null == knobs ? _self.knobs : knobs // ignore: cast_nullable_to_non_nullable
as ServerKnobs,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerConsoleState].
extension ServerConsoleStatePatterns on ServerConsoleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerConsoleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerConsoleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerConsoleState value)  $default,){
final _that = this;
switch (_that) {
case _ServerConsoleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerConsoleState value)?  $default,){
final _that = this;
switch (_that) {
case _ServerConsoleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ServerFlag> flags,  ServerKnobs knobs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerConsoleState() when $default != null:
return $default(_that.flags,_that.knobs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ServerFlag> flags,  ServerKnobs knobs)  $default,) {final _that = this;
switch (_that) {
case _ServerConsoleState():
return $default(_that.flags,_that.knobs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ServerFlag> flags,  ServerKnobs knobs)?  $default,) {final _that = this;
switch (_that) {
case _ServerConsoleState() when $default != null:
return $default(_that.flags,_that.knobs);case _:
  return null;

}
}

}

/// @nodoc


class _ServerConsoleState implements ServerConsoleState {
  const _ServerConsoleState({ List<ServerFlag> flags = const <ServerFlag>[], this.knobs = const ServerKnobs()}): _flags = flags;
  

 final  List<ServerFlag> _flags;
@override@JsonKey() List<ServerFlag> get flags {
  if (_flags is EqualUnmodifiableListView) return _flags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_flags);
}

@override@JsonKey() final  ServerKnobs knobs;

/// Create a copy of ServerConsoleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerConsoleStateCopyWith<_ServerConsoleState> get copyWith => __$ServerConsoleStateCopyWithImpl<_ServerConsoleState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerConsoleState&&const DeepCollectionEquality().equals(other.flags, _flags)&&(identical(other.knobs, knobs) || other.knobs == knobs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_flags),knobs);
}

@override
String toString() {
    return 'ServerConsoleState(flags: $flags, knobs: $knobs)';
}


}

/// @nodoc
abstract mixin class _$ServerConsoleStateCopyWith<$Res> implements $ServerConsoleStateCopyWith<$Res> {
  factory _$ServerConsoleStateCopyWith(_ServerConsoleState value, $Res Function(_ServerConsoleState) _then) = __$ServerConsoleStateCopyWithImpl;
@override @useResult
$Res call({
 List<ServerFlag> flags, ServerKnobs knobs
});




}
/// @nodoc
class __$ServerConsoleStateCopyWithImpl<$Res>
    implements _$ServerConsoleStateCopyWith<$Res> {
  __$ServerConsoleStateCopyWithImpl(this._self, this._then);

  final _ServerConsoleState _self;
  final $Res Function(_ServerConsoleState) _then;

/// Create a copy of ServerConsoleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flags = null,Object? knobs = null,}) {
  return _then(_ServerConsoleState(
flags: null == flags ? _self._flags : flags // ignore: cast_nullable_to_non_nullable
as List<ServerFlag>,knobs: null == knobs ? _self.knobs : knobs // ignore: cast_nullable_to_non_nullable
as ServerKnobs,
  ));
}


}

// dart format on
