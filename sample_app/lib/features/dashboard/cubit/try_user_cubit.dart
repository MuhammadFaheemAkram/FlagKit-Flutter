import 'dart:async';

import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'try_user_cubit.freezed.dart';

/// "Try a user": what every flag would be for a user id, without changing
/// who the app is for. Typing ids shows the rollout at work.
@freezed
abstract class TryUserState with _$TryUserState {
  const factory TryUserState({
    /// The id typed, trimmed; empty: nothing to show.
    @Default('') String userId,
    @Default(<FlagReading>[]) List<FlagReading> readings,
  }) = _TryUserState;
}

@injectable
class TryUserCubit extends Cubit<TryUserState> {
  TryUserCubit(this._debug) : super(const TryUserState()) {
    // A refresh or a context change (a new country) changes the answers.
    _subscription = _debug.watch().listen((_) => _read(state.userId));
  }

  final FlagsDebug _debug;
  late final StreamSubscription<void> _subscription;

  /// Shows the flags for [userId].
  void setUserId(String userId) => _read(userId.trim());

  void _read(String userId) => emit(
    TryUserState(
      userId: userId,
      readings: userId.isEmpty ? const [] : _debug.readFor(userId),
    ),
  );

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
