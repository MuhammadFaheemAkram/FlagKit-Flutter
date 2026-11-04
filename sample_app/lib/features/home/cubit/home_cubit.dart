import 'dart:async';

import 'package:flagkit_sample/domain/feed/feed.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flagkit_sample/features/home/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Home's state, read from the flags, and read again whenever they change:
/// reads are synchronous, so there is no loading state.
@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._flags) : super(_read(_flags)) {
    _subscription = _flags.watch().listen((_) => emit(_read(_flags)));
  }

  final AppFlags _flags;
  late final StreamSubscription<void> _subscription;

  static HomeState _read(AppFlags flags) => HomeState(
    newHome: flags.newHomeScreen,
    config: flags.homeConfig,
    items: FeedCatalog.items(flags.feedPageSize),
  );

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
