import 'package:bloc_test/bloc_test.dart';
import 'package:flagkit_sample/app/theme_cubit.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeAppFlags flags;

  setUp(() => flags = FakeAppFlags());
  tearDown(() => flags.close());

  test('starts with the flag\'s look', () {
    flags.homeTheme = AppThemeChoice.ocean;

    expect(ThemeCubit(flags).state, AppThemeChoice.ocean);
  });

  blocTest<ThemeCubit, AppThemeChoice>(
    'follows the flag when it changes',
    build: () => ThemeCubit(flags),
    act: (_) {
      flags
        ..homeTheme = AppThemeChoice.modern
        ..changed();
    },
    expect: () => [AppThemeChoice.modern],
  );

  test('every look has its spec', () {
    expect(themeSpecOf(AppThemeChoice.classic), AppThemeSpec.classic);
    expect(themeSpecOf(AppThemeChoice.modern), AppThemeSpec.modern);
    expect(themeSpecOf(AppThemeChoice.ocean), AppThemeSpec.ocean);
  });
}
