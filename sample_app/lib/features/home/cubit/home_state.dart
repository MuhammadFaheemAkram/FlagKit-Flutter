import 'package:flagkit_sample/domain/feed/feed.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flagkit_sample/domain/flags/flag_reading.dart';
import 'package:flagkit_sample/domain/flags/home_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

/// What Home shows: which home, its config, the feed, and why.
@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    /// The new home (banner and sections) or the classic list.
    required bool newHome,
    required HomeConfig config,
    required List<FeedItem> items,

    /// The app's look (Home explains it: it's targeted by country).
    required AppThemeChoice theme,

    /// Why this home, and why this look.
    required FlagReading homeWhy,
    required FlagReading themeWhy,
  }) = _HomeState;
}
