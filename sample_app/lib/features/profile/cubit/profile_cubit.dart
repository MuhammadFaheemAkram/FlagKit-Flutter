import 'dart:async';

import 'package:flagkit_sample/domain/context/user_context.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Profile: who the app is for, as targeting and rollouts see it. Every
/// change goes to [UserContext], and from there to the SDK, at once.
@injectable
class ProfileCubit extends Cubit<AppUser> {
  ProfileCubit(this._context) : super(_context.current) {
    _subscription = _context.watch().listen(emit);
  }

  final UserContext _context;
  late final StreamSubscription<AppUser> _subscription;

  void signIn(String userId) => _context.signIn(userId);

  void signOut() => _context.signOut();

  void setCountry(String? country) => _context.setCountry(country);

  void setAppVersion(String version) => _context.setAppVersion(version);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
