import 'package:bloc_test/bloc_test.dart';
import 'package:flagkit_sample/domain/shop/cart.dart';
import 'package:flagkit_sample/features/checkout/checkout_page.dart';
import 'package:flagkit_sample/features/checkout/cubit/checkout_cubit.dart';
import 'package:flagkit_sample/features/checkout/cubit/checkout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeAppFlags flags;

  setUp(() => flags = FakeAppFlags());
  tearDown(() => flags.close());

  group('CheckoutCubit', () {
    test('the cart and the discount from the flags', () {
      flags.discountPercentage = 10;
      final state = CheckoutCubit(flags).state;

      expect(state.lines, DemoCart.lines);
      expect(state.totals, CartTotals.of(DemoCart.lines, 10));
      expect(state.newCheckout, isFalse);
      expect(state.step, 0);
    });

    blocTest<CheckoutCubit, CheckoutState>(
      'the classic steps go forward and back, within 0–2',
      build: () => CheckoutCubit(flags),
      act: (cubit) => cubit
        ..previousStep()
        ..nextStep()
        ..nextStep()
        ..nextStep()
        ..previousStep(),
      verify: (cubit) => expect(cubit.state.step, 1),
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'placing an order counts it and starts over',
      build: () => CheckoutCubit(flags),
      act: (cubit) => cubit
        ..nextStep()
        ..nextStep()
        ..placeOrder(),
      verify: (cubit) {
        expect(cubit.state.ordersPlaced, 1);
        expect(cubit.state.step, 0);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'a new discount reprices the cart; a new style restarts the steps',
      build: () => CheckoutCubit(flags),
      act: (cubit) {
        cubit.nextStep();
        flags
          ..discountPercentage = 15.5
          ..newCheckout = true
          ..changed();
      },
      verify: (cubit) {
        expect(cubit.state.totals.discountPercent, 15.5);
        expect(cubit.state.newCheckout, isTrue);
        expect(cubit.state.step, 0);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'a discount change alone keeps the step',
      build: () => CheckoutCubit(flags),
      act: (cubit) {
        cubit.nextStep();
        flags
          ..discountPercentage = 5
          ..changed();
      },
      verify: (cubit) => expect(cubit.state.step, 1),
    );
  });

  group('the view', () {
    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpThemed(
        BlocProvider(
          create: (_) => CheckoutCubit(flags),
          child: const CheckoutView(),
        ),
      );
    }

    testWidgets('the classic checkout: three steps, then Place order', (
      tester,
    ) async {
      await pump(tester);

      expect(find.byType(Stepper), findsOneWidget);
      expect(find.text('Coffee beans'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Standard delivery'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text(r'$62.50'), findsWidgets);

      await tester.tap(find.text('Place order'));
      await tester.pump();

      expect(find.textContaining('Order placed'), findsOneWidget);
    });

    testWidgets('no discount: no discount line', (tester) async {
      flags.newCheckout = true;
      await pump(tester);

      expect(find.textContaining('Discount'), findsNothing);
      expect(find.text(r'Pay $62.50'), findsOneWidget);
    });

    testWidgets('the new checkout: the discount, the total, and Pay asks', (
      tester,
    ) async {
      flags
        ..newCheckout = true
        ..discountPercentage = 15.5;
      await pump(tester);

      expect(find.byType(Stepper), findsNothing);
      expect(find.text('Discount (15.5 %)'), findsOneWidget);
      expect(find.text(r'−$9.69'), findsOneWidget);

      await tester.tap(find.text(r'Pay $52.81'));
      await tester.pumpAndSettle();
      expect(find.text('Place this order?'), findsOneWidget);

      // Cancel keeps the order open.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Order placed'), findsNothing);

      await tester.tap(find.text(r'Pay $52.81'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Pay'));
      await tester.pump();
      expect(find.textContaining('Order placed'), findsOneWidget);
    });
  });
}
