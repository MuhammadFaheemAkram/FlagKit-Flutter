import 'package:bloc_test/bloc_test.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_state.dart';
import 'package:flagkit_sample/features/dashboard/dashboard_page.dart';
import 'package:flagkit_sample/features/dashboard/dashboard_words.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeFlagsDebug debug;

  const reading = FlagReading(
    key: 'new_home_screen',
    value: 'false',
    source: ReadingSource.appDefault,
    reason: ReadingReason.unknownFlag,
  );

  setUp(() => debug = FakeFlagsDebug()..readings = const [reading]);
  tearDown(() => debug.close());

  group('DashboardCubit', () {
    test('reads the SDK at once', () {
      expect(
        DashboardCubit(debug).state,
        const DashboardState(sdkVersion: '9.9.9', readings: [reading]),
      );
    });

    blocTest<DashboardCubit, DashboardState>(
      'reads it again when a flag changes',
      build: () => DashboardCubit(debug),
      act: (_) {
        debug
          ..readings = const []
          ..changed();
      },
      expect: () => const [DashboardState(sdkVersion: '9.9.9', readings: [])],
    );
  });

  test('every source and reason has words', () {
    for (final source in ReadingSource.values) {
      final (_, label, _) = sourceStyle(source, AppColors.light);
      expect(label, isNotEmpty);
    }
    final words = ReadingReason.values.map(reasonWords).toSet();
    expect(words, hasLength(ReadingReason.values.length));
  });

  group('the view', () {
    // Phone width, tall enough for every row: a lazy list builds only the
    // rows that show.
    Future<void> pump(WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(390 * 3, 3000 * 3)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpThemed(
        BlocProvider(
          create: (_) => DashboardCubit(debug),
          child: const DashboardView(),
        ),
      );
    }

    testWidgets('the SDK version and each flag with its source and why', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('FlagKit 9.9.9'), findsOneWidget);
      expect(find.text('new_home_screen'), findsOneWidget);
      expect(
        find.text('false · FlagKit doesn\'t know this flag yet'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(StatusChip),
          matching: find.text('Default'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('at large text, the chip goes under the words', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pump(tester);

      final key = tester.getRect(find.text('new_home_screen'));
      final chip = tester.getRect(find.byType(StatusChip));
      expect(chip.top, greaterThan(key.bottom));
      expect(chip.left, key.left);
    });

    testWidgets('a row reads as one phrase', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester);

      expect(
        tester.getSemantics(find.text('new_home_screen')).label,
        'new_home_screen\nfalse · FlagKit doesn\'t know this flag yet\n'
        'Default',
      );
      handle.dispose();
    });
  });
}
