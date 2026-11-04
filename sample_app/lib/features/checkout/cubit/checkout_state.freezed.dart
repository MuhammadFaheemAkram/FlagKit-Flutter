// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckoutState {

/// The one-page checkout, or the classic stepper.
 bool get newCheckout; List<CartLine> get lines; CartTotals get totals;/// The classic stepper's step: 0 cart, 1 delivery, 2 payment.
 int get step;/// How many orders were placed: a change shows the confirmation once.
 int get ordersPlaced;
/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutStateCopyWith<CheckoutState> get copyWith => _$CheckoutStateCopyWithImpl<CheckoutState>(this as CheckoutState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CheckoutState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutState&&(identical(other.newCheckout, _this.newCheckout) || other.newCheckout == _this.newCheckout)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.totals, _this.totals) || other.totals == _this.totals)&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.ordersPlaced, _this.ordersPlaced) || other.ordersPlaced == _this.ordersPlaced));
}


@override
int get hashCode {
  final _this = this as CheckoutState;
  return Object.hash(runtimeType,_this.newCheckout,const DeepCollectionEquality().hash(_this.lines),_this.totals,_this.step,_this.ordersPlaced);
}

@override
String toString() {
  final _this = this as CheckoutState;
  return 'CheckoutState(newCheckout: ${_this.newCheckout}, lines: ${_this.lines}, totals: ${_this.totals}, step: ${_this.step}, ordersPlaced: ${_this.ordersPlaced})';
}


}

/// @nodoc
abstract mixin class $CheckoutStateCopyWith<$Res>  {
  factory $CheckoutStateCopyWith(CheckoutState value, $Res Function(CheckoutState) _then) = _$CheckoutStateCopyWithImpl;
@useResult
$Res call({
 bool newCheckout, List<CartLine> lines, CartTotals totals, int step, int ordersPlaced
});




}
/// @nodoc
class _$CheckoutStateCopyWithImpl<$Res>
    implements $CheckoutStateCopyWith<$Res> {
  _$CheckoutStateCopyWithImpl(this._self, this._then);

  final CheckoutState _self;
  final $Res Function(CheckoutState) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? newCheckout = null,Object? lines = null,Object? totals = null,Object? step = null,Object? ordersPlaced = null,}) {
  return _then(CheckoutState(
newCheckout: null == newCheckout ? _self.newCheckout : newCheckout // ignore: cast_nullable_to_non_nullable
as bool,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as CartTotals,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,ordersPlaced: null == ordersPlaced ? _self.ordersPlaced : ordersPlaced // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutState].
extension CheckoutStatePatterns on CheckoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutState value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutState value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool newCheckout,  List<CartLine> lines,  CartTotals totals,  int step,  int ordersPlaced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
return $default(_that.newCheckout,_that.lines,_that.totals,_that.step,_that.ordersPlaced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool newCheckout,  List<CartLine> lines,  CartTotals totals,  int step,  int ordersPlaced)  $default,) {final _that = this;
switch (_that) {
case _CheckoutState():
return $default(_that.newCheckout,_that.lines,_that.totals,_that.step,_that.ordersPlaced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool newCheckout,  List<CartLine> lines,  CartTotals totals,  int step,  int ordersPlaced)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
return $default(_that.newCheckout,_that.lines,_that.totals,_that.step,_that.ordersPlaced);case _:
  return null;

}
}

}

/// @nodoc


class _CheckoutState implements CheckoutState {
  const _CheckoutState({required this.newCheckout, required  List<CartLine> lines, required this.totals, this.step = 0, this.ordersPlaced = 0}): _lines = lines;
  

/// The one-page checkout, or the classic stepper.
@override final  bool newCheckout;
 final  List<CartLine> _lines;
@override List<CartLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  CartTotals totals;
/// The classic stepper's step: 0 cart, 1 delivery, 2 payment.
@override@JsonKey() final  int step;
/// How many orders were placed: a change shows the confirmation once.
@override@JsonKey() final  int ordersPlaced;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutStateCopyWith<_CheckoutState> get copyWith => __$CheckoutStateCopyWithImpl<_CheckoutState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutState&&(identical(other.newCheckout, newCheckout) || other.newCheckout == newCheckout)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.step, step) || other.step == step)&&(identical(other.ordersPlaced, ordersPlaced) || other.ordersPlaced == ordersPlaced));
}


@override
int get hashCode {
    return Object.hash(runtimeType,newCheckout,const DeepCollectionEquality().hash(_lines),totals,step,ordersPlaced);
}

@override
String toString() {
    return 'CheckoutState(newCheckout: $newCheckout, lines: $lines, totals: $totals, step: $step, ordersPlaced: $ordersPlaced)';
}


}

/// @nodoc
abstract mixin class _$CheckoutStateCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory _$CheckoutStateCopyWith(_CheckoutState value, $Res Function(_CheckoutState) _then) = __$CheckoutStateCopyWithImpl;
@override @useResult
$Res call({
 bool newCheckout, List<CartLine> lines, CartTotals totals, int step, int ordersPlaced
});




}
/// @nodoc
class __$CheckoutStateCopyWithImpl<$Res>
    implements _$CheckoutStateCopyWith<$Res> {
  __$CheckoutStateCopyWithImpl(this._self, this._then);

  final _CheckoutState _self;
  final $Res Function(_CheckoutState) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? newCheckout = null,Object? lines = null,Object? totals = null,Object? step = null,Object? ordersPlaced = null,}) {
  return _then(_CheckoutState(
newCheckout: null == newCheckout ? _self.newCheckout : newCheckout // ignore: cast_nullable_to_non_nullable
as bool,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as CartTotals,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,ordersPlaced: null == ordersPlaced ? _self.ordersPlaced : ordersPlaced // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
