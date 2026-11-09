import 'package:flagkit_sample/domain/flags/app_flags.dart';

/// The app's flag keys and their defaults: the one place they're written.
///
/// A default is what the app does when FlagKit has no value (a first
/// launch offline, an unknown flag, the wrong type): the app's behaviour
/// before the flag existed. So every default is the safe, old behaviour,
/// and switching a flag off on the server can only bring the app back to
/// it.
abstract final class AppFlagKeys {
  static const newHomeScreen = 'new_home_screen';
  static const newCheckout = 'new_checkout';
  static const homeTheme = 'home_theme';
  static const feedPageSize = 'feed_page_size';
  static const discountPercentage = 'discount_percentage';
  static const homeConfig = 'home_config';

  /// [flag]'s key.
  static String of(AppFlag flag) => switch (flag) {
    AppFlag.newHomeScreen => newHomeScreen,
    AppFlag.newCheckout => newCheckout,
    AppFlag.homeTheme => homeTheme,
    AppFlag.feedPageSize => feedPageSize,
    AppFlag.discountPercentage => discountPercentage,
    AppFlag.homeConfig => homeConfig,
  };

  /// Every key, in the Dashboard's order.
  static const all = [
    newHomeScreen,
    newCheckout,
    homeTheme,
    feedPageSize,
    discountPercentage,
    homeConfig,
  ];
}

abstract final class AppFlagDefaults {
  static const newHomeScreen = false;
  static const newCheckout = false;
  static const homeTheme = 'classic';
  static const feedPageSize = 20;
  static const discountPercentage = 0.0;
  static const Map<String, Object?> homeConfig = {};

  /// A page size the server sends is kept to this range: a remote value
  /// is input, and a typo of 2000 mustn't build 2000 rows.
  static const minFeedPageSize = 5;
  static const maxFeedPageSize = 50;

  /// The most a remote discount may be, for the same reason.
  static const maxDiscountPercentage = 50.0;
}
