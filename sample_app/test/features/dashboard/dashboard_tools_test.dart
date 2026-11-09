import 'package:bloc_test/bloc_test.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/domain/demo/demo_server.dart';
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:flagkit_sample/features/dashboard/cubit/flag_detail_cubit.dart';
import 'package:flagkit_sample/features/dashboard/cubit/server_console_cubit.dart';
import 'package:flagkit_sample/features/dashboard/cubit/try_user_cubit.dart';
import 'package:flagkit_sample/features/dashboard/dashboard_page.dart';
import 'package:flagkit_sample/features/dashboard/flag_detail_page.dart';
import 'package:flagkit_sample/features/dashboard/widgets/server_console_section.dart';
import 'package:flagkit_sample/features/dashboard/widgets/try_user_section.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

// The Dashboard's tools: Try a user, the server console, a flag's detail
// with its override, and the cache's actions and log.
void main() {
  late FakeFlagsDebug debug;
  late FakeDemoServer server;
  late FakeDeviceNetwork network;

  setUp(() {
    debug = FakeFlagsDebug();
    server = FakeDemoServer();
    network = FakeDeviceNetwork();
  });
  tearDown(() async {
    await debug.close();
    await server.close();
    await network.close();
  });

  const inRollout = FlagReading(
    key: 'new_checkout',
    value: 'true',
    source: ReadingSource.server,
    reason: ReadingReason.inRollout,
    bucket: 404,
    rolloutPercent: 25,
    kind: FlagKind.onOff,
  );

  const checkout = FlagInspection(
    reading: inRollout,
    serverValue: 'true',
    offValue: 'false',
    enabled: true,
  );

  const theme = FlagInspection(
    reading: FlagReading(
      key: 'home_theme',
      value: '"classic"',
      source: ReadingSource.server,
      reason: ReadingReason.rulesMissed,
      kind: FlagKind.text,
    ),
    serverValue: '"modern"',
    offValue: '"classic"',
    enabled: true,
    rules: [RuleCheck('country is one of PK, AE', matched: false)],
  );

  group('TryUserCubit', () {
    blocTest<TryUserCubit, TryUserState>(
      'an id shows its flags; blank shows none',
      setUp: () => debug.readForResult = const [inRollout],
      build: () => TryUserCubit(debug),
      act: (cubit) => cubit
        ..setUserId(' maya ')
        ..setUserId('  '),
      expect: () => const [
        TryUserState(userId: 'maya', readings: [inRollout]),
        TryUserState(),
      ],
      verify: (_) => expect(debug.triedUsers, ['maya']),
    );

    blocTest<TryUserCubit, TryUserState>(
      'reads again when the flags change',
      build: () => TryUserCubit(debug),
      act: (cubit) {
        cubit.setUserId('maya');
        debug.readForResult = const [inRollout];
        debug.changed();
      },
      verify: (cubit) {
        expect(cubit.state.readings, [inRollout]);
        expect(debug.triedUsers, ['maya', 'maya']);
      },
    );
  });

  group('ServerConsoleCubit', () {
    blocTest<ServerConsoleCubit, ServerConsoleState>(
      'the server\'s flags and knobs; every control goes to the server',
      build: () => ServerConsoleCubit(server),
      act: (cubit) async {
        await pumpEventQueue();
        server.sendFlags(const [
          ServerFlag(key: 'new_checkout', enabled: true, value: 'true'),
        ]);
        cubit
          ..setEnabled('new_checkout', false)
          ..setRollout('new_checkout', 50)
          ..setTheme('ocean')
          ..setFailures(ServerFailures.half)
          ..setSpeed(ServerSpeed.slow);
        await pumpEventQueue();
      },
      verify: (cubit) {
        expect(cubit.state.flags.single.key, 'new_checkout');
        expect(
          cubit.state.knobs,
          const ServerKnobs(
            failures: ServerFailures.half,
            speed: ServerSpeed.slow,
          ),
        );
        expect(server.calls, [
          'enabled new_checkout false',
          'rollout new_checkout 50.0',
          'theme ocean',
          'failures half',
          'speed slow',
        ]);
      },
    );
  });

  group('FlagDetailCubit', () {
    test('the inspection, or none for an unknown flag', () {
      debug.inspections['new_checkout'] = checkout;

      expect(FlagDetailCubit('new_checkout', debug).state.inspection, checkout);
      expect(FlagDetailCubit('nope', debug).state.inspection, isNull);
    });

    blocTest<FlagDetailCubit, FlagDetailState>(
      'an override: set, refused with a reason, cleared',
      setUp: () => debug.inspections['home_theme'] = theme,
      build: () => FlagDetailCubit('home_theme', debug),
      act: (cubit) async {
        await cubit.setOverride('ocean');
        debug.overrideError = 'Enter some text.';
        await cubit.setOverride(' ');
        debug.overrideError = null;
        await cubit.clearOverride();
      },
      verify: (cubit) {
        expect(cubit.state.overrideError, isNull);
        expect(debug.overrides, isEmpty);
      },
      // The first emit is recorded even though it equals the start (bloc
      // lets a Cubit's first emit through).
      expect: () => [
        const FlagDetailState(key: 'home_theme', inspection: theme),
        const FlagDetailState(
          key: 'home_theme',
          inspection: theme,
          overrideError: 'Enter some text.',
        ),
        const FlagDetailState(key: 'home_theme', inspection: theme),
      ],
    );

    blocTest<FlagDetailCubit, FlagDetailState>(
      're-inspects when the flags change',
      build: () => FlagDetailCubit('home_theme', debug),
      act: (_) {
        debug.inspections['home_theme'] = theme;
        debug.changed();
      },
      expect: () => const [
        FlagDetailState(key: 'home_theme', inspection: theme),
      ],
    );
  });

  group('DashboardCubit', () {
    blocTest<DashboardCubit, Object?>(
      'clears the cache and the overrides; keeps the refresh log',
      build: () => DashboardCubit(debug, network),
      act: (cubit) async {
        await cubit.clearCache();
        await cubit.clearOverrides();
        debug.log([
          LastRefresh(
            cause: RefreshCause.manual,
            kind: RefreshKind.updated,
            at: DateTime.utc(2026, 11, 10, 9, 41),
          ),
        ]);
      },
      verify: (cubit) {
        expect(debug.cacheClears, 1);
        expect(debug.overrideClears, 1);
        expect(cubit.state.refreshLog.single.cause, RefreshCause.manual);
      },
    );
  });

  group('the detail page', () {
    Future<void> pump(WidgetTester tester, String key) async {
      tester.usePhoneSurface();
      tester.view.physicalSize = const Size(390 * 3, 2000 * 3);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: BlocProvider(
            create: (_) => FlagDetailCubit(key, debug),
            child: const FlagDetailView(),
          ),
        ),
      );
    }

    testWidgets('an unknown flag: Flag not found', (tester) async {
      await pump(tester, 'nope');

      expect(find.text('Flag not found'), findsOneWidget);
      expect(find.text('Back to the Dashboard'), findsOneWidget);
    });

    testWidgets('a rollout: the definition and where you fall', (tester) async {
      debug.inspections['new_checkout'] = checkout;
      await pump(tester, 'new_checkout');

      expect(find.text('Rolled out to 25 %'), findsOneWidget);
      expect(
        find.text('Your bucket is 404 of 10,000: below 2500, so you\'re in.'),
        findsOneWidget,
      );
      expect(find.text('No rules: everyone is eligible.'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Off value')), findsOneWidget);
    });

    testWidgets('a bucket at the threshold is out, as in the SDK', (
      tester,
    ) async {
      debug.inspections['new_checkout'] = const FlagInspection(
        reading: FlagReading(
          key: 'new_checkout',
          value: 'false',
          source: ReadingSource.server,
          reason: ReadingReason.outsideRollout,
          bucket: 2500,
          rolloutPercent: 25,
          kind: FlagKind.onOff,
        ),
        enabled: true,
      );
      await pump(tester, 'new_checkout');

      expect(
        find.text(
          'Your bucket is 2500 of 10,000: not below 2500, so you\'re out.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('rules: each with whether it matches you', (tester) async {
      debug.inspections['home_theme'] = theme;
      await pump(tester, 'home_theme');

      expect(find.text('country is one of PK, AE'), findsOneWidget);
      expect(find.text('Doesn\'t match you'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('an on/off override: two buttons, then Clear', (tester) async {
      debug.inspections['new_checkout'] = checkout;
      await pump(tester, 'new_checkout');

      await tester.tap(find.text('Override: off'));
      await tester.pump();
      expect(debug.overrides, {'new_checkout': 'false'});

      debug.inspections['new_checkout'] = const FlagInspection(
        reading: inRollout,
        enabled: true,
        overrideValue: 'false',
      );
      debug.changed();
      await tester.pump();
      expect(find.text('Overridden with false.'), findsOneWidget);
      await tester.tap(find.text('Clear override'));
      await tester.pump();
      expect(debug.overrides, isEmpty);
    });

    testWidgets('a text override, and its mistake in words', (tester) async {
      debug.inspections['home_theme'] = theme;
      await pump(tester, 'home_theme');

      debug.overrideError = 'Enter some text.';
      await tester.enterText(find.byKey(const ValueKey('overrideValue')), ' ');
      await tester.tap(find.text('Override'));
      await tester.pump();
      expect(find.text('Enter some text.'), findsOneWidget);

      debug.overrideError = null;
      await tester.enterText(
        find.byKey(const ValueKey('overrideValue')),
        'ocean',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(debug.overrides, {'home_theme': 'ocean'});
      expect(find.text('Enter some text.'), findsNothing);
    });

    testWidgets('an override with no definition says so', (tester) async {
      debug.inspections['beta'] = const FlagInspection(
        reading: FlagReading(
          key: 'beta',
          value: 'true',
          source: ReadingSource.override,
          reason: ReadingReason.override,
          kind: FlagKind.onOff,
        ),
        overrideValue: 'true',
      );
      await pump(tester, 'beta');

      expect(
        find.textContaining('The server doesn\'t send this flag'),
        findsOneWidget,
      );
      expect(find.text('Overridden with true.'), findsOneWidget);
    });
  });

  group('the sections', () {
    testWidgets('Try a user: typing shows the flags for that id', (
      tester,
    ) async {
      debug.readForResult = const [inRollout];
      await tester.pumpThemed(
        BlocProvider(
          create: (_) => TryUserCubit(debug),
          child: const SingleChildScrollView(child: TryUserSection()),
        ),
      );

      await tester.enterText(find.byKey(const ValueKey('tryUserId')), 'maya');
      await tester.pump();

      expect(debug.triedUsers, ['maya']);
      expect(find.text('new_checkout'), findsOneWidget);
      expect(find.textContaining('bucket 404, rollout 25 %'), findsOneWidget);
    });

    testWidgets('the server console: each control reaches the server', (
      tester,
    ) async {
      server.flags = const [
        ServerFlag(
          key: 'new_checkout',
          enabled: true,
          value: 'true',
          rolloutPercent: 25,
        ),
        ServerFlag(
          key: 'home_theme',
          enabled: true,
          value: '"modern"',
          isTheme: true,
        ),
      ];
      tester.view.physicalSize = const Size(390 * 3, 2000 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpThemed(
        BlocProvider(
          create: (_) => ServerConsoleCubit(server),
          child: const SingleChildScrollView(child: ServerConsoleSection()),
        ),
      );
      await tester.pump();

      expect(find.text('true · rolled out to 25 %'), findsOneWidget);
      await tester.tap(find.byType(Switch).first);
      await tester.tap(find.text('50 %').first);
      await tester.tap(find.text('ocean'));
      await tester.tap(find.text('100 %').last);
      await tester.tap(find.text('Slow'));
      await tester.pump();

      expect(server.calls, [
        'enabled new_checkout false',
        'rollout new_checkout 50.0',
        'theme ocean',
        'failures all',
        'speed slow',
      ]);
    });

    testWidgets('Clear cache asks first; Clear overrides shows when set', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 6000 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpThemed(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => DashboardCubit(debug, network)),
            BlocProvider(create: (_) => TryUserCubit(debug)),
            BlocProvider(create: (_) => ServerConsoleCubit(server)),
          ],
          child: const DashboardView(),
        ),
      );
      debug.cache(
        const CacheInfo(
          state: CacheState.fresh,
          flagCount: 6,
          installId: 'anon-1',
          overrideCount: 2,
          reads: {ReadingSource.server: 7},
          refreshes: 3,
          failedRefreshes: 1,
          skippedDefinitions: 2,
        ),
      );
      debug.log([
        LastRefresh(
          cause: RefreshCause.interval,
          kind: RefreshKind.failed,
          at: DateTime.utc(2026, 11, 10, 9, 41),
          error: 'server error 503',
        ),
      ]);
      await tester.pump();

      expect(find.textContaining('Every minute · Failed'), findsWidgets);
      expect(find.bySemanticsLabel('Reads: server: 7'), findsOneWidget);
      expect(find.bySemanticsLabel('Failed refreshes: 1'), findsOneWidget);

      await tester.tap(find.text('Clear cache'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(debug.cacheClears, 0);
      await tester.tap(find.text('Clear cache'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(debug.cacheClears, 1);

      await tester.tap(find.text('Clear 2 overrides'));
      await tester.pump();
      expect(debug.overrideClears, 1);
    });
  });
}
