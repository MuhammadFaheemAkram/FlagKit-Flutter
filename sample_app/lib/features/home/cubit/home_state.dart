import 'package:flagkit_sample/domain/feed/feed.dart';
import 'package:flagkit_sample/domain/flags/home_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

/// What Home shows: which home, its config, and the feed.
@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    /// The new home (banner and sections) or the classic list.
    required bool newHome,
    required HomeConfig config,
    required List<FeedItem> items,
  }) = _HomeState;
}
