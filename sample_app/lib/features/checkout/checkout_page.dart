import 'package:flagkit_sample/core/common/money.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flagkit_sample/domain/shop/cart.dart';
import 'package:flagkit_sample/features/checkout/cubit/checkout_cubit.dart';
import 'package:flagkit_sample/features/checkout/cubit/checkout_state.dart';
import 'package:flagkit_sample/features/common/why_line.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Checkout: the cart with the discount from `discount_percentage`, in the
/// style `new_checkout` picks.
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<CheckoutCubit>(),
    child: const CheckoutView(),
  );
}

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CheckoutCubit>().state;
    return BlocListener<CheckoutCubit, CheckoutState>(
      listenWhen: (before, now) => now.ordersPlaced > before.ordersPlaced,
      listener: (context, _) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Order placed. Nothing was charged: it\'s a demo.'),
          ),
        ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: state.newCheckout
            ? _OnePageCheckout(state)
            : _ClassicCheckout(state),
      ),
    );
  }
}

/// Why this checkout and this discount.
WhyLine _whyLine(CheckoutState state) => WhyLine([
  (
    subject: state.newCheckout
        ? 'the one-page checkout'
        : 'the step-by-step checkout',
    reading: state.checkoutWhy,
  ),
  (
    subject: state.totals.discountCents > 0
        ? 'a ${formatPercent(state.totals.discountPercent)} discount'
        : 'no discount',
    reading: state.discountWhy,
  ),
]);

/// The new checkout: everything on one page, and one button.
class _OnePageCheckout extends StatelessWidget {
  const _OnePageCheckout(this.state);

  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    final total = formatPrice(state.totals.totalCents, 'USD');
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        _whyLine(state),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
            child: Column(
              children: [
                for (final line in state.lines) _LineRow(line),
                const Divider(),
                _Totals(state.totals),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        const ListTile(
          leading: Icon(Icons.local_shipping_outlined),
          title: Text('Standard delivery'),
          subtitle: Text('3–5 days, free'),
        ),
        const SizedBox(height: AppSpacing.medium),
        FilledButton.icon(
          onPressed: () => _confirm(context, total),
          icon: const Icon(Icons.lock_outline),
          label: Text('Pay $total'),
        ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context, String total) async {
    final cubit = context.read<CheckoutCubit>();
    final pay = await showConfirmDialog(
      context,
      title: 'Place this order?',
      message: '$total, delivered in 3–5 days.',
      confirmLabel: 'Pay',
    );
    if (pay) cubit.placeOrder();
  }
}

/// The classic checkout: a stepper, cart → delivery → payment.
class _ClassicCheckout extends StatelessWidget {
  const _ClassicCheckout(this.state);

  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    final last = state.step == CheckoutCubit.stepCount - 1;
    return ListView(children: [_whyLine(state), _stepper(cubit, last)]);
  }

  Widget _stepper(CheckoutCubit cubit, bool last) {
    return Stepper(
      // Inside the page's list: the list scrolls, not the stepper.
      physics: const NeverScrollableScrollPhysics(),
      currentStep: state.step,
      onStepContinue: last ? cubit.placeOrder : cubit.nextStep,
      onStepCancel: state.step == 0 ? null : cubit.previousStep,
      // The controls of the current step only: a vertical Stepper builds
      // every step's, and the hidden ones would still be found (and read
      // by screen readers).
      controlsBuilder: (context, details) =>
          details.stepIndex != details.currentStep
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: AppSpacing.medium),
              // In line with the step's content, not centred under it.
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: AppSpacing.xSmall,
                  runSpacing: AppSpacing.xSmall,
                  children: [
                    FilledButton(
                      onPressed: details.onStepContinue,
                      child: Text(last ? 'Place order' : 'Continue'),
                    ),
                    if (details.onStepCancel != null)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                  ],
                ),
              ),
            ),
      steps: [
        Step(
          title: const Text('Cart'),
          isActive: state.step >= 0,
          content: Column(
            children: [for (final line in state.lines) _LineRow(line)],
          ),
        ),
        Step(
          title: const Text('Delivery'),
          isActive: state.step >= 1,
          content: const ListTile(
            leading: Icon(Icons.local_shipping_outlined),
            title: Text('Standard delivery'),
            subtitle: Text('3–5 days, free'),
          ),
        ),
        Step(
          title: const Text('Payment'),
          isActive: state.step >= 2,
          content: _Totals(state.totals),
        ),
      ],
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow(this.line);

  final CartLine line;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(line.name),
    subtitle: Text(
      '${line.quantity} × ${formatPrice(line.unitPriceCents, 'USD')}',
    ),
    trailing: Text(formatPrice(line.totalCents, 'USD')),
  );
}

class _Totals extends StatelessWidget {
  const _Totals(this.totals);

  final CartTotals totals;

  @override
  Widget build(BuildContext context) {
    final bold = Theme.of(context).textTheme.titleMedium;
    return Column(
      children: [
        ListTile(
          title: const Text('Subtotal'),
          trailing: Text(formatPrice(totals.subtotalCents, 'USD')),
        ),
        if (totals.discountCents > 0)
          ListTile(
            leading: const Icon(Icons.sell_outlined),
            title: Text('Discount (${formatPercent(totals.discountPercent)})'),
            trailing: Text('−${formatPrice(totals.discountCents, 'USD')}'),
          ),
        ListTile(
          title: Text('Total', style: bold),
          trailing: Text(formatPrice(totals.totalCents, 'USD'), style: bold),
        ),
      ],
    );
  }
}
