import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

double contrast(Color a, Color b) {
  final (hi, lo) = (a.computeLuminance(), b.computeLuminance());
  return hi > lo ? (hi + 0.05) / (lo + 0.05) : (lo + 0.05) / (hi + 0.05);
}

void main() {
  group('AppTheme', () {
    test('builds Material 3 light and dark themes for every look', () {
      for (final spec in AppThemeSpec.all) {
        for (final brightness in Brightness.values) {
          final theme = AppTheme.build(spec, brightness);
          expect(theme.useMaterial3, isTrue);
          expect(theme.colorScheme.brightness, brightness);
        }
      }
      expect(AppTheme.light().colorScheme.brightness, Brightness.light);
      expect(AppTheme.dark().colorScheme.brightness, Brightness.dark);
    });

    test('each look\'s primary color stays close to its seed (fidelity)', () {
      for (final spec in AppThemeSpec.all) {
        final primary = HSLColor.fromColor(
          AppTheme.build(spec, Brightness.light).colorScheme.primary,
        );
        final seed = HSLColor.fromColor(spec.seedColor);

        expect((primary.hue - seed.hue).abs(), lessThan(10));
        expect(primary.saturation, greaterThanOrEqualTo(seed.saturation * 0.8));
      }
    });

    test('the looks are three different colors', () {
      expect(
        AppThemeSpec.all.map((spec) => spec.seedColor).toSet(),
        hasLength(3),
      );
    });

    test('the modern look has rounder cards and buttons', () {
      RoundedRectangleBorder card(AppThemeSpec spec) =>
          AppTheme.build(spec, Brightness.light).cardTheme.shape!
              as RoundedRectangleBorder;

      expect(
        card(AppThemeSpec.modern).borderRadius,
        const BorderRadius.all(Radius.circular(AppRadius.large)),
      );
      expect(
        card(AppThemeSpec.classic).borderRadius,
        const BorderRadius.all(Radius.circular(AppRadius.medium)),
      );
    });

    test('registers the matching AppColors for each brightness', () {
      expect(AppTheme.light().extension<AppColors>(), same(AppColors.light));
      expect(AppTheme.dark().extension<AppColors>(), same(AppColors.dark));
    });

    test('list rows keep their icon level with the title at large text', () {
      expect(
        AppTheme.light().listTileTheme.titleAlignment,
        ListTileTitleAlignment.titleHeight,
      );
    });
  });

  group('AppColors', () {
    List<Color> tokens(AppColors c) => [
      c.overridden,
      c.server,
      c.cache,
      c.appDefault,
      c.fresh,
      c.stale,
      c.expired,
      c.empty,
    ];

    test('lerp interpolates every token', () {
      final mid = AppColors.light.lerp(AppColors.dark, 0.5);

      final (light, dark) = (tokens(AppColors.light), tokens(AppColors.dark));
      expect(tokens(mid), [
        for (var i = 0; i < light.length; i++)
          Color.lerp(light[i], dark[i], 0.5),
      ]);
    });

    test('lerp towards a missing extension keeps the current colors', () {
      expect(AppColors.light.lerp(null, 0.5), same(AppColors.light));
    });

    test('copyWith replaces only the given tokens', () {
      const purple = Color(0xFF7B1FA2);
      final copy = AppColors.light.copyWith(stale: purple);

      expect(copy.stale, purple);
      final (before, after) = (tokens(AppColors.light), tokens(copy));
      for (var i = 0; i < before.length; i++) {
        if (i != 5) expect(after[i], before[i]);
      }
    });

    test('the sources have four colors, the statuses four', () {
      for (final c in [AppColors.light, AppColors.dark]) {
        expect({c.overridden, c.server, c.cache, c.appDefault}, hasLength(4));
        expect({c.fresh, c.stale, c.expired, c.empty}, hasLength(4));
      }
    });

    testWidgets('context.appColors reads the current theme', (tester) async {
      late AppColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Builder(
            builder: (context) {
              colors = context.appColors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(colors, same(AppColors.dark));
    });
  });

  // WCAG contrast checks, so a color tweak (or a new look) can't silently
  // make a label unreadable. The meaning colors are text and icon colors on
  // the page, on cards and on filled surfaces, in every look and
  // brightness, so each must reach AA (4.5:1) on all of them.
  group('Contrast in every look', () {
    for (final (name, spec) in [
      ('classic', AppThemeSpec.classic),
      ('modern', AppThemeSpec.modern),
      ('ocean', AppThemeSpec.ocean),
    ]) {
      for (final brightness in Brightness.values) {
        final theme = AppTheme.build(spec, brightness);
        final colors = theme.extension<AppColors>()!;
        final scheme = theme.colorScheme;

        test('$name, ${brightness.name}: every token meets AA', () {
          for (final (token, color) in [
            ('overridden', colors.overridden),
            ('server', colors.server),
            ('cache', colors.cache),
            ('appDefault', colors.appDefault),
            ('fresh', colors.fresh),
            ('stale', colors.stale),
            ('expired', colors.expired),
            ('empty', colors.empty),
          ]) {
            for (final (surface, background) in [
              ('the page', scheme.surface),
              ('a card', scheme.surfaceContainerLow),
              ('a filled surface', scheme.surfaceContainerHighest),
            ]) {
              expect(
                contrast(color, background),
                greaterThanOrEqualTo(4.5),
                reason: '$token on $surface',
              );
            }
          }
        });
      }
    }
  });
}
