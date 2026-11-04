import 'package:material_ui/material_ui.dart';

/// Colors with a meaning that Material's [ColorScheme] has no slot for:
/// where a flag's value came from, and how fresh the cached flags are.
///
/// A [ThemeExtension] travels inside [ThemeData], so the light and dark
/// variants switch automatically (and animate via [lerp]) when the theme
/// changes. Widgets ask for an *intent* (`server`, `stale`) instead of
/// hard-coding raw colors.
///
/// Each is a text and icon color on the page, on cards and on filled
/// surfaces, in every one of the app's looks, so each must reach WCAG AA
/// (4.5:1) against all of them (checked by a test). Color is never the only
/// signal: a source or a status always has an icon and a word too.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.overridden,
    required this.server,
    required this.cache,
    required this.appDefault,
    required this.fresh,
    required this.stale,
    required this.expired,
    required this.empty,
  });

  /// A value overridden on this device.
  final Color overridden;

  /// A value fetched from the server in this session.
  final Color server;

  /// A value from the device's cache.
  final Color cache;

  /// The app's own default: FlagKit had no value.
  final Color appDefault;

  /// The cached flags are fresh.
  final Color fresh;

  /// The cached flags are stale: a refresh is due.
  final Color stale;

  /// The cached flags are expired: still used, refreshed at every chance.
  final Color expired;

  /// Nothing is cached.
  final Color empty;

  static const light = AppColors(
    overridden: Color(0xFF6B3FA0),
    server: Color(0xFF146C2E),
    cache: Color(0xFF1D5FA8),
    appDefault: Color(0xFF44546A),
    fresh: Color(0xFF146C2E),
    stale: Color(0xFF7A4E00),
    expired: Color(0xFFB3261E),
    empty: Color(0xFF44546A),
  );

  static const dark = AppColors(
    overridden: Color(0xFFD7B8FF),
    server: Color(0xFF86D993),
    cache: Color(0xFF9ECAFF),
    appDefault: Color(0xFFB7C6DB),
    fresh: Color(0xFF86D993),
    stale: Color(0xFFFFC56B),
    expired: Color(0xFFFF9C92),
    empty: Color(0xFFB7C6DB),
  );

  List<Color> get _all => [
    overridden,
    server,
    cache,
    appDefault,
    fresh,
    stale,
    expired,
    empty,
  ];

  @override
  AppColors copyWith({
    Color? overridden,
    Color? server,
    Color? cache,
    Color? appDefault,
    Color? fresh,
    Color? stale,
    Color? expired,
    Color? empty,
  }) {
    return AppColors(
      overridden: overridden ?? this.overridden,
      server: server ?? this.server,
      cache: cache ?? this.cache,
      appDefault: appDefault ?? this.appDefault,
      fresh: fresh ?? this.fresh,
      stale: stale ?? this.stale,
      expired: expired ?? this.expired,
      empty: empty ?? this.empty,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    final (a, b) = (_all, other._all);
    Color at(int i) => Color.lerp(a[i], b[i], t)!;
    return AppColors(
      overridden: at(0),
      server: at(1),
      cache: at(2),
      appDefault: at(3),
      fresh: at(4),
      stale: at(5),
      expired: at(6),
      empty: at(7),
    );
  }
}

/// Shorthand for `Theme.of(context).extension<AppColors>()!`.
extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
