// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {

 String get sdkVersion; List<FlagReading> get readings;/// The SDK's cache, once it has answered (a moment after the screen
/// opens: it is a database query).
 CacheInfo? get cache;/// The device's network and the demo switch, once known.
 NetworkStatus? get network;/// Whether a refresh asked from here is running.
 bool get refreshing;/// The latest refresh asked from here, and how many there were: a new
/// one shows its result once.
 RefreshSummary? get lastResult; int get refreshCount;/// The newest refreshes, newest first.
 List<LastRefresh> get refreshLog;
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStateCopyWith<DashboardState> get copyWith => _$DashboardStateCopyWithImpl<DashboardState>(this as DashboardState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DashboardState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState&&(identical(other.sdkVersion, _this.sdkVersion) || other.sdkVersion == _this.sdkVersion)&&const DeepCollectionEquality().equals(other.readings, _this.readings)&&(identical(other.cache, _this.cache) || other.cache == _this.cache)&&(identical(other.network, _this.network) || other.network == _this.network)&&(identical(other.refreshing, _this.refreshing) || other.refreshing == _this.refreshing)&&(identical(other.lastResult, _this.lastResult) || other.lastResult == _this.lastResult)&&(identical(other.refreshCount, _this.refreshCount) || other.refreshCount == _this.refreshCount)&&const DeepCollectionEquality().equals(other.refreshLog, _this.refreshLog));
}


@override
int get hashCode {
  final _this = this as DashboardState;
  return Object.hash(runtimeType,_this.sdkVersion,const DeepCollectionEquality().hash(_this.readings),_this.cache,_this.network,_this.refreshing,_this.lastResult,_this.refreshCount,const DeepCollectionEquality().hash(_this.refreshLog));
}

@override
String toString() {
  final _this = this as DashboardState;
  return 'DashboardState(sdkVersion: ${_this.sdkVersion}, readings: ${_this.readings}, cache: ${_this.cache}, network: ${_this.network}, refreshing: ${_this.refreshing}, lastResult: ${_this.lastResult}, refreshCount: ${_this.refreshCount}, refreshLog: ${_this.refreshLog})';
}


}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res>  {
  factory $DashboardStateCopyWith(DashboardState value, $Res Function(DashboardState) _then) = _$DashboardStateCopyWithImpl;
@useResult
$Res call({
 String sdkVersion, List<FlagReading> readings, CacheInfo? cache, NetworkStatus? network, bool refreshing, RefreshSummary? lastResult, int refreshCount, List<LastRefresh> refreshLog
});


$NetworkStatusCopyWith<$Res>? get network;

}
/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sdkVersion = null,Object? readings = null,Object? cache = freezed,Object? network = freezed,Object? refreshing = null,Object? lastResult = freezed,Object? refreshCount = null,Object? refreshLog = null,}) {
  return _then(DashboardState(
sdkVersion: null == sdkVersion ? _self.sdkVersion : sdkVersion // ignore: cast_nullable_to_non_nullable
as String,readings: null == readings ? _self.readings : readings // ignore: cast_nullable_to_non_nullable
as List<FlagReading>,cache: freezed == cache ? _self.cache : cache // ignore: cast_nullable_to_non_nullable
as CacheInfo?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as NetworkStatus?,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,lastResult: freezed == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as RefreshSummary?,refreshCount: null == refreshCount ? _self.refreshCount : refreshCount // ignore: cast_nullable_to_non_nullable
as int,refreshLog: null == refreshLog ? _self.refreshLog : refreshLog // ignore: cast_nullable_to_non_nullable
as List<LastRefresh>,
  ));
}
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NetworkStatusCopyWith<$Res>? get network {
    if (_self.network == null) {
    return null;
  }

  return $NetworkStatusCopyWith<$Res>(_self.network!, (value) {
    return _then(_self.copyWith(network: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardState value)  $default,){
final _that = this;
switch (_that) {
case _DashboardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sdkVersion,  List<FlagReading> readings,  CacheInfo? cache,  NetworkStatus? network,  bool refreshing,  RefreshSummary? lastResult,  int refreshCount,  List<LastRefresh> refreshLog)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.sdkVersion,_that.readings,_that.cache,_that.network,_that.refreshing,_that.lastResult,_that.refreshCount,_that.refreshLog);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sdkVersion,  List<FlagReading> readings,  CacheInfo? cache,  NetworkStatus? network,  bool refreshing,  RefreshSummary? lastResult,  int refreshCount,  List<LastRefresh> refreshLog)  $default,) {final _that = this;
switch (_that) {
case _DashboardState():
return $default(_that.sdkVersion,_that.readings,_that.cache,_that.network,_that.refreshing,_that.lastResult,_that.refreshCount,_that.refreshLog);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sdkVersion,  List<FlagReading> readings,  CacheInfo? cache,  NetworkStatus? network,  bool refreshing,  RefreshSummary? lastResult,  int refreshCount,  List<LastRefresh> refreshLog)?  $default,) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.sdkVersion,_that.readings,_that.cache,_that.network,_that.refreshing,_that.lastResult,_that.refreshCount,_that.refreshLog);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardState implements DashboardState {
  const _DashboardState({required this.sdkVersion, required  List<FlagReading> readings, this.cache, this.network, this.refreshing = false, this.lastResult, this.refreshCount = 0,  List<LastRefresh> refreshLog = const <LastRefresh>[]}): _readings = readings,_refreshLog = refreshLog;
  

@override final  String sdkVersion;
 final  List<FlagReading> _readings;
@override List<FlagReading> get readings {
  if (_readings is EqualUnmodifiableListView) return _readings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_readings);
}

/// The SDK's cache, once it has answered (a moment after the screen
/// opens: it is a database query).
@override final  CacheInfo? cache;
/// The device's network and the demo switch, once known.
@override final  NetworkStatus? network;
/// Whether a refresh asked from here is running.
@override@JsonKey() final  bool refreshing;
/// The latest refresh asked from here, and how many there were: a new
/// one shows its result once.
@override final  RefreshSummary? lastResult;
@override@JsonKey() final  int refreshCount;
/// The newest refreshes, newest first.
 final  List<LastRefresh> _refreshLog;
/// The newest refreshes, newest first.
@override@JsonKey() List<LastRefresh> get refreshLog {
  if (_refreshLog is EqualUnmodifiableListView) return _refreshLog;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_refreshLog);
}


/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStateCopyWith<_DashboardState> get copyWith => __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardState&&(identical(other.sdkVersion, sdkVersion) || other.sdkVersion == sdkVersion)&&const DeepCollectionEquality().equals(other.readings, _readings)&&(identical(other.cache, cache) || other.cache == cache)&&(identical(other.network, network) || other.network == network)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&(identical(other.lastResult, lastResult) || other.lastResult == lastResult)&&(identical(other.refreshCount, refreshCount) || other.refreshCount == refreshCount)&&const DeepCollectionEquality().equals(other.refreshLog, _refreshLog));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sdkVersion,const DeepCollectionEquality().hash(_readings),cache,network,refreshing,lastResult,refreshCount,const DeepCollectionEquality().hash(_refreshLog));
}

@override
String toString() {
    return 'DashboardState(sdkVersion: $sdkVersion, readings: $readings, cache: $cache, network: $network, refreshing: $refreshing, lastResult: $lastResult, refreshCount: $refreshCount, refreshLog: $refreshLog)';
}


}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(_DashboardState value, $Res Function(_DashboardState) _then) = __$DashboardStateCopyWithImpl;
@override @useResult
$Res call({
 String sdkVersion, List<FlagReading> readings, CacheInfo? cache, NetworkStatus? network, bool refreshing, RefreshSummary? lastResult, int refreshCount, List<LastRefresh> refreshLog
});


@override $NetworkStatusCopyWith<$Res>? get network;

}
/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sdkVersion = null,Object? readings = null,Object? cache = freezed,Object? network = freezed,Object? refreshing = null,Object? lastResult = freezed,Object? refreshCount = null,Object? refreshLog = null,}) {
  return _then(_DashboardState(
sdkVersion: null == sdkVersion ? _self.sdkVersion : sdkVersion // ignore: cast_nullable_to_non_nullable
as String,readings: null == readings ? _self._readings : readings // ignore: cast_nullable_to_non_nullable
as List<FlagReading>,cache: freezed == cache ? _self.cache : cache // ignore: cast_nullable_to_non_nullable
as CacheInfo?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as NetworkStatus?,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,lastResult: freezed == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as RefreshSummary?,refreshCount: null == refreshCount ? _self.refreshCount : refreshCount // ignore: cast_nullable_to_non_nullable
as int,refreshLog: null == refreshLog ? _self._refreshLog : refreshLog // ignore: cast_nullable_to_non_nullable
as List<LastRefresh>,
  ));
}

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NetworkStatusCopyWith<$Res>? get network {
    if (_self.network == null) {
    return null;
  }

  return $NetworkStatusCopyWith<$Res>(_self.network!, (value) {
    return _then(_self.copyWith(network: value));
  });
}
}

// dart format on
