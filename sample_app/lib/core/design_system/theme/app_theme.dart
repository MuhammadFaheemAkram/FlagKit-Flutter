import 'package:flagkit_sample/core/design_system/theme/app_colors.dart';
import 'package:flagkit_sample/core/design_system/theme/app_radius.dart';
import 'package:material_ui/material_ui.dart';

/// One of the app's looks: a seed color and a corner radius. A flag picks
/// which (`home_theme`), so the whole app can be restyled from the server.
@immutable
final class AppThemeSpec {
  const AppThemeSpec({required this.seedColor, required this.cornerRadius});

  /// Indigo, medium corners: the app's original look.
  static const classic = AppThemeSpec(
    seedColor: Color(0xFF3F51B5),
    cornerRadius: AppRadius.medium,
  );

  /// Teal, with rounder shapes.
  static const modern = AppThemeSpec(
    seedColor: Color(0xFF00796B),
    cornerRadius: AppRadius.large,
  );

  /// Blue, medium corners.
  static const ocean = AppThemeSpec(
    seedColor: Color(0xFF0061A4),
    cornerRadius: AppRadius.medium,
  );

  static const all = [classic, modern, ocean];

  final Color seedColor;
  final double cornerRadius;
}

/// Builds the app's Material 3 themes.
///
/// Screens style themselves through `Theme.of(context)`, never with
/// hard-coded colors, so a new look is a new [AppThemeSpec] and nothing
/// else.
abstract final class AppTheme {
  /// The theme for [spec] in [brightness].
  static ThemeData build(AppThemeSpec spec, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: spec.seedColor,
      brightness: brightness,
      // `fidelity` keeps the primary color close to the seed; the default
      // variant (`tonalSpot`) would noticeably mute it.
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final corners = BorderRadius.all(Radius.circular(spec.cornerRadius));
    return ThemeData(
      colorScheme: colorScheme,
      extensions: [
        if (brightness == Brightness.light) AppColors.light else AppColors.dark,
      ],
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: corners),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: corners),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      // A row's icon stays level with its title when large text wraps the
      // row onto several lines, instead of drifting to the row's middle.
      listTileTheme: const ListTileThemeData(
        titleAlignment: ListTileTitleAlignment.titleHeight,
      ),
    );
  }

  /// The classic look in light mode: what tests and the first frame use.
  static ThemeData light() => build(AppThemeSpec.classic, Brightness.light);

  /// The classic look in dark mode.
  static ThemeData dark() => build(AppThemeSpec.classic, Brightness.dark);
}
