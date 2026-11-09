import 'package:bloc_test/bloc_test.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flagkit_sample/domain/flags/flag_reading.dart';
import 'package:flagkit_sample/domain/flags/home_config.dart';
import 'package:flagkit_sample/features/home/cubit/home_cubit.dart';
import 'package:flagkit_sample/features/home/cubit/home_state.dart';
import 'package:flagkit_sample/features/home/home_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeAppFlags flags;

  setUp(() => flags = FakeAppFlags());
  tearDown(() => flags.close());

  group('HomeCubit', () {
    test('reads the flags at once: no loading state', () {
      flags
        ..newHomeScreen = true
        ..feedPageSize = 8;
      final state = HomeCubit(flags).state;

      expect(state.newHome, isTrue);
      expect(state.items, hasLength(8));
      expect(state.config, HomeConfig.fallback);
    });

    test('why: this home and this look, as the flags explain them', () {
      const home = FlagReading(
        key: 'new_home_screen',
        value: 'true',
        source: ReadingSource.server,
        reason: ReadingReason.onForEveryone,
      );
      const theme = FlagReading(
        key: 'home_theme',
        value: '"modern"',
        source: ReadingSource.server,
        reason: ReadingReason.rulesMatched,
      );
      flags
        ..homeTheme = AppThemeChoice.modern
        ..readings[AppFlag.newHomeScreen] = home
        ..readings[AppFlag.homeTheme] = theme;

      final state = HomeCubit(flags).state;

      expect(state.theme, AppThemeChoice.modern);
      expect(state.homeWhy, home);
      expect(state.themeWhy, theme);
    });

    blocTest<HomeCubit, HomeState>(
      'reads them again when they change',
      build: () => HomeCubit(flags),
      act: (_) {
        flags
          ..newHomeScreen = true
          ..feedPageSize = 5
          ..changed();
      },
      verify: (cubit) {
        expect(cubit.state.newHome, isTrue);
        expect(cubit.state.items, hasLength(5));
      },
    );
  });

  group('the view', () {
    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpThemed(
        BlocProvider(create: (_) => HomeCubit(flags), child: const HomeView()),
      );
    }

    testWidgets('the classic home: one list of stories', (tester) async {
      flags.feedPageSize = 6;
      await pump(tester);

      expect(find.text('Stories'), findsOneWidget);
      expect(find.textContaining('Story '), findsNWidgets(6));
      expect(find.text('New this week'), findsNothing);
    });

    testWidgets('the new home: the banner, then the sections, in order', (
      tester,
    ) async {
      flags
        ..newHomeScreen = true
        ..feedPageSize = 6
        ..homeConfig = const HomeConfig(
          banner: 'Spring sale',
          sections: [HomeSection.deals, HomeSection.latest],
        );
      await pump(tester);

      expect(find.text('Spring sale'), findsOneWidget);
      expect(find.text('Stories'), findsNothing);
      expect(
        tester.getTopLeft(find.text('Deals')).dy,
        lessThan(tester.getTopLeft(find.text('New this week')).dy),
      );
      // The feed is split between the sections, none lost.
      expect(find.textContaining('Story '), findsNWidgets(6));
      expect(
        tester.getTopLeft(find.text('Story 4')).dy,
        greaterThan(tester.getTopLeft(find.text('New this week')).dy),
      );
    });

    testWidgets('no banner: none shown', (tester) async {
      flags.newHomeScreen = true;
      await pump(tester);

      expect(find.byType(Card), findsNothing);
      expect(find.text('New this week'), findsOneWidget);
    });

    testWidgets('a flag change switches the home in place', (tester) async {
      await pump(tester);
      expect(find.text('Stories'), findsOneWidget);

      flags
        ..newHomeScreen = true
        ..changed();
      await tester.pump();

      expect(find.text('Stories'), findsNothing);
      expect(find.text('New this week'), findsOneWidget);
    });
  });
}
