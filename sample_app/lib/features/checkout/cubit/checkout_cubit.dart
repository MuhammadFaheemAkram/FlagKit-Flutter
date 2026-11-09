import 'dart:async';

import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flagkit_sample/domain/shop/cart.dart';
import 'package:flagkit_sample/features/checkout/cubit/checkout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Checkout's state: the cart, the discount and the checkout style from the
/// flags, read again whenever they change.
@injectable
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._flags)
    : super(
        CheckoutState(
          newCheckout: _flags.newCheckout,
          lines: DemoCart.lines,
          totals: CartTotals.of(DemoCart.lines, _flags.discountPercentage),
          checkoutWhy: _flags.explain(AppFlag.newCheckout),
          discountWhy: _flags.explain(AppFlag.discountPercentage),
        ),
      ) {
    _subscription = _flags.watch().listen((_) => _readFlags());
  }

  /// The classic stepper's steps.
  static const stepCount = 3;

  final AppFlags _flags;
  late final StreamSubscription<void> _subscription;

  void _readFlags() {
    final newCheckout = _flags.newCheckout;
    emit(
      state.copyWith(
        newCheckout: newCheckout,
        totals: CartTotals.of(state.lines, _flags.discountPercentage),
        checkoutWhy: _flags.explain(AppFlag.newCheckout),
        discountWhy: _flags.explain(AppFlag.discountPercentage),
        // A switch of style starts the order again from its first step.
        step: newCheckout == state.newCheckout ? state.step : 0,
      ),
    );
  }

  /// The classic stepper's next step.
  void nextStep() {
    if (state.step < stepCount - 1) emit(state.copyWith(step: state.step + 1));
  }

  /// The classic stepper's previous step.
  void previousStep() {
    if (state.step > 0) emit(state.copyWith(step: state.step - 1));
  }

  /// Places the demo order (nothing is kept or charged), and starts over.
  void placeOrder() =>
      emit(state.copyWith(step: 0, ordersPlaced: state.ordersPlaced + 1));

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
