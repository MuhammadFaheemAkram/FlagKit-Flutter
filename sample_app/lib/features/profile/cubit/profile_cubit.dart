import 'dart:async';

import 'package:flagkit_sample/domain/context/user_context.dart';
import 'package:flagkit_sample/features/profile/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Profile: who the app is for, as targeting and rollouts see it. Every
/// change goes to [UserContext], and from there to the SDK, at once.
@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._context) : super(ProfileState(user: _context.current)) {
    _subscriptions = [
      _context.watch().listen((user) => emit(state.copyWith(user: user))),
      _context.watchInstallId().listen(
        (id) => emit(state.copyWith(installId: id)),
      ),
    ];
  }

  final UserContext _context;
  late final List<StreamSubscription<Object>> _subscriptions;

  void signIn(String userId) => _context.signIn(userId);

  void signOut() => _context.signOut();

  void setCountry(String? country) => _context.setCountry(country);

  void setAppVersion(String version) => _context.setAppVersion(version);

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
