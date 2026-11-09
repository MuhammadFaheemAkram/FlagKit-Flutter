import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/data/flags/app_flag_keys.dart';
import 'package:flagkit_sample/data/flags/flag_reading_mapper.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flagkit_sample/domain/flags/flag_reading.dart';
import 'package:flagkit_sample/domain/flags/home_config.dart';
import 'package:injectable/injectable.dart';

/// [AppFlags] with FlagKit: each getter is one synchronous read, with the
/// app's key and default.
///
/// The SDK's types stay here: the Cubits see `bool`, `int`, an enum and a
/// [HomeConfig], never a `FlagValue`.
@LazySingleton(as: AppFlags)
class FlagKitAppFlags implements AppFlags {
  FlagKitAppFlags(this._flags);

  final FlagKitClient _flags;

  // The defaults are passed even where they equal the SDK's own (`false`):
  // the app's defaults live in AppFlagDefaults, and changing one there must
  // change what the app does.

  @override
  bool get newHomeScreen => _flags.isEnabled(
    AppFlagKeys.newHomeScreen,
    // ignore: avoid_redundant_argument_values
    AppFlagDefaults.newHomeScreen,
  );

  @override
  bool get newCheckout => _flags.isEnabled(
    AppFlagKeys.newCheckout,
    // ignore: avoid_redundant_argument_values
    AppFlagDefaults.newCheckout,
  );

  @override
  AppThemeChoice get homeTheme => AppThemeChoice.fromName(
    _flags.getString(AppFlagKeys.homeTheme, AppFlagDefaults.homeTheme),
  );

  @override
  int get feedPageSize => _flags
      .getInt(AppFlagKeys.feedPageSize, AppFlagDefaults.feedPageSize)
      .clamp(AppFlagDefaults.minFeedPageSize, AppFlagDefaults.maxFeedPageSize);

  @override
  double get discountPercentage => _flags
      .getDouble(
        AppFlagKeys.discountPercentage,
        AppFlagDefaults.discountPercentage,
      )
      .clamp(0.0, AppFlagDefaults.maxDiscountPercentage);

  @override
  HomeConfig get homeConfig => HomeConfig.fromJson(
    _flags.getJson(AppFlagKeys.homeConfig, AppFlagDefaults.homeConfig),
  );

  @override
  FlagReading explain(AppFlag flag) =>
      readingOf(_flags.detail(AppFlagKeys.of(flag)));

  // Only the app's own flags: a change to a flag no screen reads
  // rebuilds nothing.
  @override
  Stream<void> watch() => _flags.changes
      .where((keys) => keys.any(AppFlagKeys.all.contains))
      .map((_) {});
}
