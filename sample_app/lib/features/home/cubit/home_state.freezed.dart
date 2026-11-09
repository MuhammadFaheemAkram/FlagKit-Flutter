// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

/// The new home (banner and sections) or the classic list.
 bool get newHome; HomeConfig get config; List<FeedItem> get items;/// The app's look (Home explains it: it's targeted by country).
 AppThemeChoice get theme;/// Why this home, and why this look.
 FlagReading get homeWhy; FlagReading get themeWhy;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HomeState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.newHome, _this.newHome) || other.newHome == _this.newHome)&&(identical(other.config, _this.config) || other.config == _this.config)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.theme, _this.theme) || other.theme == _this.theme)&&(identical(other.homeWhy, _this.homeWhy) || other.homeWhy == _this.homeWhy)&&(identical(other.themeWhy, _this.themeWhy) || other.themeWhy == _this.themeWhy));
}


@override
int get hashCode {
  final _this = this as HomeState;
  return Object.hash(runtimeType,_this.newHome,_this.config,const DeepCollectionEquality().hash(_this.items),_this.theme,_this.homeWhy,_this.themeWhy);
}

@override
String toString() {
  final _this = this as HomeState;
  return 'HomeState(newHome: ${_this.newHome}, config: ${_this.config}, items: ${_this.items}, theme: ${_this.theme}, homeWhy: ${_this.homeWhy}, themeWhy: ${_this.themeWhy})';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 bool newHome, HomeConfig config, List<FeedItem> items, AppThemeChoice theme, FlagReading homeWhy, FlagReading themeWhy
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? newHome = null,Object? config = null,Object? items = null,Object? theme = null,Object? homeWhy = null,Object? themeWhy = null,}) {
  return _then(HomeState(
newHome: null == newHome ? _self.newHome : newHome // ignore: cast_nullable_to_non_nullable
as bool,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as HomeConfig,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<FeedItem>,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as AppThemeChoice,homeWhy: null == homeWhy ? _self.homeWhy : homeWhy // ignore: cast_nullable_to_non_nullable
as FlagReading,themeWhy: null == themeWhy ? _self.themeWhy : themeWhy // ignore: cast_nullable_to_non_nullable
as FlagReading,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool newHome,  HomeConfig config,  List<FeedItem> items,  AppThemeChoice theme,  FlagReading homeWhy,  FlagReading themeWhy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.newHome,_that.config,_that.items,_that.theme,_that.homeWhy,_that.themeWhy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool newHome,  HomeConfig config,  List<FeedItem> items,  AppThemeChoice theme,  FlagReading homeWhy,  FlagReading themeWhy)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.newHome,_that.config,_that.items,_that.theme,_that.homeWhy,_that.themeWhy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool newHome,  HomeConfig config,  List<FeedItem> items,  AppThemeChoice theme,  FlagReading homeWhy,  FlagReading themeWhy)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.newHome,_that.config,_that.items,_that.theme,_that.homeWhy,_that.themeWhy);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({required this.newHome, required this.config, required  List<FeedItem> items, required this.theme, required this.homeWhy, required this.themeWhy}): _items = items;
  

/// The new home (banner and sections) or the classic list.
@override final  bool newHome;
@override final  HomeConfig config;
 final  List<FeedItem> _items;
@override List<FeedItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// The app's look (Home explains it: it's targeted by country).
@override final  AppThemeChoice theme;
/// Why this home, and why this look.
@override final  FlagReading homeWhy;
@override final  FlagReading themeWhy;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.newHome, newHome) || other.newHome == newHome)&&(identical(other.config, config) || other.config == config)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.homeWhy, homeWhy) || other.homeWhy == homeWhy)&&(identical(other.themeWhy, themeWhy) || other.themeWhy == themeWhy));
}


@override
int get hashCode {
    return Object.hash(runtimeType,newHome,config,const DeepCollectionEquality().hash(_items),theme,homeWhy,themeWhy);
}

@override
String toString() {
    return 'HomeState(newHome: $newHome, config: $config, items: $items, theme: $theme, homeWhy: $homeWhy, themeWhy: $themeWhy)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 bool newHome, HomeConfig config, List<FeedItem> items, AppThemeChoice theme, FlagReading homeWhy, FlagReading themeWhy
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? newHome = null,Object? config = null,Object? items = null,Object? theme = null,Object? homeWhy = null,Object? themeWhy = null,}) {
  return _then(_HomeState(
newHome: null == newHome ? _self.newHome : newHome // ignore: cast_nullable_to_non_nullable
as bool,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as HomeConfig,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<FeedItem>,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as AppThemeChoice,homeWhy: null == homeWhy ? _self.homeWhy : homeWhy // ignore: cast_nullable_to_non_nullable
as FlagReading,themeWhy: null == themeWhy ? _self.themeWhy : themeWhy // ignore: cast_nullable_to_non_nullable
as FlagReading,
  ));
}


}

// dart format on
