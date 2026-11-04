import 'package:flagkit_sample/domain/shop/cart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_state.freezed.dart';

/// What Checkout shows.
@freezed
abstract class CheckoutState with _$CheckoutState {
  const factory CheckoutState({
    /// The one-page checkout, or the classic stepper.
    required bool newCheckout,
    required List<CartLine> lines,
    required CartTotals totals,

    /// The classic stepper's step: 0 cart, 1 delivery, 2 payment.
    @Default(0) int step,

    /// How many orders were placed: a change shows the confirmation once.
    @Default(0) int ordersPlaced,
  }) = _CheckoutState;
}
