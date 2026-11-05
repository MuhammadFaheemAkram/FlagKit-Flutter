import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/domain/network/device_network.dart';
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

  const empty = CacheInfo(
    state: CacheState.empty,
    flagCount: 0,
    installId: 'anon-1',
  );

  late FakeDeviceNetwork network;

  setUp(() {
    debug = FakeFlagsDebug()..readings = const [reading];
    network = FakeDeviceNetwork();
  });
  tearDown(() async {
    await debug.close();
    await network.close();
  });

  group('DashboardCubit', () {
    test('reads the SDK at once', () {
      expect(
        DashboardCubit(debug, network).state,
        const DashboardState(sdkVersion: '9.9.9', readings: [reading]),
      );
    });

    blocTest<DashboardCubit, DashboardState>(
      'adds the cache when the SDK answers',
      build: () => DashboardCubit(debug, network),
      act: (_) => debug.cache(empty),
      expect: () => const [
        DashboardState(sdkVersion: '9.9.9', readings: [reading], cache: empty),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'adds the network when it answers',
      build: () => DashboardCubit(debug, network),
      act: (_) => network.set(const NetworkStatus(deviceOnline: false)),
      verify: (cubit) =>
          expect(cubit.state.network, const NetworkStatus(deviceOnline: false)),
    );

    blocTest<DashboardCubit, DashboardState>(
      'a refresh: refreshing while it runs, then the result, counted',
      build: () => DashboardCubit(debug, network),
      act: (cubit) async {
        debug.refreshResult = const RefreshSummary(
          RefreshKind.updated,
          changed: 2,
        );
        await cubit.refresh();
      },
      expect: () => const [
        DashboardState(
          sdkVersion: '9.9.9',
          readings: [reading],
          refreshing: true,
        ),
        DashboardState(
          sdkVersion: '9.9.9',
          readings: [reading],
          lastResult: RefreshSummary(RefreshKind.updated, changed: 2),
          refreshCount: 1,
        ),
      ],
    );

    test('a tap while refreshing asks nothing more', () async {
      final cubit = DashboardCubit(debug, network);
      addTearDown(cubit.close);
      debug.refreshGate = Completer<void>();

      final first = cubit.refresh();
      await cubit.refresh();
      debug.refreshGate!.complete();
      await first;

      expect(debug.refreshes, 1);
    });

    test('the switch goes to the network', () {
      final cubit = DashboardCubit(debug, network);
      addTearDown(cubit.close);

      cubit.simulateOffline(true);

      expect(network.status.simulatingOffline, isTrue);
    });

    blocTest<DashboardCubit, DashboardState>(
      'reads it again when a flag changes',
      build: () => DashboardCubit(debug, network),
      act: (_) {
        debug
          ..readings = const []
          ..changed();
      },
      expect: () => const [DashboardState(sdkVersion: '9.9.9', readings: [])],
    );
  });

  test('every refresh has words', () {
    for (final (summary, words) in const [
      (RefreshSummary(RefreshKind.updated), 'Refreshed: no flag changed.'),
      (
        RefreshSummary(RefreshKind.updated, changed: 1),
        'Refreshed: 1 flag changed.',
      ),
      (
        RefreshSummary(RefreshKind.updated, changed: 3, skipped: 1),
        'Refreshed: 3 flags changed. 1 invalid flag was left out.',
      ),
      (
        RefreshSummary(RefreshKind.updated, skipped: 2),
        'Refreshed: no flag changed. 2 invalid flags were left out.',
      ),
      (
        RefreshSummary(RefreshKind.upToDate),
        'Up to date: the server has nothing new.',
      ),
      (
        RefreshSummary(RefreshKind.offline),
        'You\'re offline: the flags stay as they are.',
      ),
      (
        RefreshSummary(RefreshKind.failed, reason: 'server error 503'),
        'The refresh failed (server error 503). The flags stay as they are.',
      ),
      (
        RefreshSummary(RefreshKind.rejected),
        'The server rejected the API key. The flags stay as they are.',
      ),
    ]) {
      expect(refreshResultWords(summary), words);
    }
    expect(RefreshCause.values.map(causeWords).toSet(), hasLength(5));
    expect(RefreshKind.values.map(kindWords).toSet(), hasLength(5));
  });

  test('every source and reason has words', () {
    for (final source in ReadingSource.values) {
      final (_, label, _) = sourceStyle(source, AppColors.light);
      expect(label, isNotEmpty);
    }
    final labels = {
      for (final state in CacheState.values)
        cacheStyle(state, AppColors.light).$2,
    };
    expect(labels, hasLength(CacheState.values.length));
    expect(CacheState.values.map(cacheWords).toSet(), hasLength(4));
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
          create: (_) => DashboardCubit(debug, network),
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

    testWidgets('before the cache answers: a line says so', (tester) async {
      await pump(tester);

      expect(find.text('Reading the cache…'), findsOneWidget);
    });

    testWidgets('an empty cache: Empty, no flags, never fetched, the id', (
      tester,
    ) async {
      await pump(tester);
      debug.cache(empty);
      await tester.pump();

      expect(find.text('Empty'), findsOneWidget);
      expect(
        find.text('Nothing cached: every flag is the app\'s default.'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Flags cached: 0'), findsOneWidget);
      expect(find.bySemanticsLabel('Fetched: Never'), findsOneWidget);
      expect(find.textContaining('anon-1'), findsOneWidget);
    });

    testWidgets('a stale cache: Stale, its count, and when', (tester) async {
      await pump(tester);
      debug.cache(
        CacheInfo(
          state: CacheState.stale,
          flagCount: 6,
          installId: 'anon-1',
          fetchedAt: DateTime(2026, 11, 4, 9, 41, 5),
        ),
      );
      await tester.pump();

      expect(find.text('Stale'), findsOneWidget);
      expect(find.bySemanticsLabel('Flags cached: 6'), findsOneWidget);
      expect(find.bySemanticsLabel('Fetched: 09:41:05'), findsOneWidget);
    });

    testWidgets('Refresh: the button waits, a line shows, the result tells', (
      tester,
    ) async {
      debug
        ..refreshResult = const RefreshSummary(RefreshKind.upToDate)
        ..refreshGate = Completer<void>();
      await pump(tester);

      await tester.tap(find.text('Refresh'));
      await tester.pump();
      expect(find.text('Refreshing…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      debug.refreshGate!.complete();
      await tester.pump();
      await tester.pump();
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        find.text('Up to date: the server has nothing new.'),
        findsOneWidget,
      );
    });

    testWidgets('the network, and the switch', (tester) async {
      await pump(tester);
      network.set(const NetworkStatus(deviceOnline: true));
      await tester.pump();
      expect(find.text('Online'), findsOneWidget);

      await tester.tap(find.text('Device offline'));
      await tester.pump();
      expect(find.text('Offline (simulated)'), findsOneWidget);

      network.set(const NetworkStatus(deviceOnline: false));
      await tester.pump();
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('the last refresh: why, what, when, and the error', (
      tester,
    ) async {
      await pump(tester);
      debug.cache(
        CacheInfo(
          state: CacheState.fresh,
          flagCount: 6,
          installId: 'anon-1',
          lastRefresh: LastRefresh(
            cause: RefreshCause.reconnect,
            kind: RefreshKind.failed,
            at: DateTime(2026, 11, 6, 9, 41, 5),
            error: 'server error 503',
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('Back online · Failed · 09:41:05 · server error 503'),
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
