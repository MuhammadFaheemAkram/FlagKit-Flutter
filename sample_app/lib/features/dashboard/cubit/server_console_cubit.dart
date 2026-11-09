import 'dart:async';

import 'package:flagkit_sample/domain/demo/demo_server.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'server_console_cubit.freezed.dart';

/// The demo server's console: its flags and knobs, as an admin would
/// change them. The app sees a change only after a refresh.
@freezed
abstract class ServerConsoleState with _$ServerConsoleState {
  const factory ServerConsoleState({
    @Default(<ServerFlag>[]) List<ServerFlag> flags,
    @Default(ServerKnobs()) ServerKnobs knobs,
  }) = _ServerConsoleState;
}

@injectable
class ServerConsoleCubit extends Cubit<ServerConsoleState> {
  ServerConsoleCubit(this._server) : super(const ServerConsoleState()) {
    _subscriptions = [
      _server.watchFlags().listen(
        (flags) => emit(state.copyWith(flags: flags)),
      ),
      _server.watchKnobs().listen(
        (knobs) => emit(state.copyWith(knobs: knobs)),
      ),
    ];
  }

  final DemoServer _server;
  late final List<StreamSubscription<Object?>> _subscriptions;

  void setEnabled(String key, bool enabled) => _server.setEnabled(key, enabled);

  void setRollout(String key, double? percent) =>
      _server.setRollout(key, percent);

  void setTheme(String theme) => _server.setTheme(theme);

  void setFailures(ServerFailures failures) => _server.setFailures(failures);

  void setSpeed(ServerSpeed speed) => _server.setSpeed(speed);

  @override
  Future<void> close() async {
    await Future.wait([for (final s in _subscriptions) s.cancel()]);
    return super.close();
  }
}
