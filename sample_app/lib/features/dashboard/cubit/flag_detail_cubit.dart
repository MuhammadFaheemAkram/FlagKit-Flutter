import 'dart:async';

import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'flag_detail_cubit.freezed.dart';

/// One flag in full: its definition, this user's bucket, each rule, and
/// the override controls.
@freezed
abstract class FlagDetailState with _$FlagDetailState {
  const factory FlagDetailState({
    required String key,

    /// `null`: FlagKit knows nothing of the flag (a stale link).
    FlagInspection? inspection,

    /// What was wrong with the last override typed, in words.
    String? overrideError,
  }) = _FlagDetailState;
}

@injectable
class FlagDetailCubit extends Cubit<FlagDetailState> {
  FlagDetailCubit(@factoryParam String key, this._debug)
    : super(FlagDetailState(key: key, inspection: _debug.inspect(key))) {
    _subscription = _debug.watch().listen(
      (_) => emit(state.copyWith(inspection: _debug.inspect(state.key))),
    );
  }

  final FlagsDebug _debug;
  late final StreamSubscription<void> _subscription;

  /// Overrides the flag with [text]; a mistake shows as
  /// [FlagDetailState.overrideError]. The page itself follows the flags:
  /// a new override reaches it through [FlagsDebug.watch], like any other
  /// change.
  Future<void> setOverride(String text) async {
    final error = await _debug.setOverride(state.key, text);
    if (!isClosed) emit(state.copyWith(overrideError: error));
  }

  Future<void> clearOverride() async {
    await _debug.clearOverride(state.key);
    if (!isClosed) emit(state.copyWith(overrideError: null));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
