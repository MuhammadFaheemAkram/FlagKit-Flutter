import 'package:flagkit_sample/domain/flags/home_config.dart';

/// The app's feature flags, by meaning: what the screens may ask.
///
/// The port every Cubit uses. A screen asks `flags.newCheckout`, never
/// `isEnabled('new_checkout')`: the keys, the types and the defaults live in
/// one place (the adapter), so a typo in a key can't hide in a widget, a
/// renamed flag is one change, and a test passes a fake with plain values.
abstract interface class AppFlags {
  /// The new home (a banner and sections) instead of the classic list.
  bool get newHomeScreen;

  /// The one-page checkout instead of the classic stepper.
  bool get newCheckout;

  /// The app's look.
  AppThemeChoice get homeTheme;

  /// How many items the home feed shows.
  int get feedPageSize;

  /// The discount at checkout, in percent.
  double get discountPercentage;

  /// What the new home shows: its banner and sections.
  HomeConfig get homeConfig;

  /// Emits whenever one of the flags above changes value.
  Stream<void> watch();
}

/// The app's looks, picked by a flag.
enum AppThemeChoice {
  /// Indigo, the app's original look: what everyone gets by default.
  classic,

  /// Teal, with rounder shapes.
  modern,

  /// Blue.
  ocean;

  /// The look named [name], or [classic] for a name this version of the
  /// app doesn't know (the server may be ahead of it).
  static AppThemeChoice fromName(String name) =>
      values.firstWhere((choice) => choice.name == name, orElse: () => classic);
}
