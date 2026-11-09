import 'package:flagkit_sample/domain/context/user_context.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

/// What Profile shows: the user, and this install's anonymous id.
@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    required AppUser user,

    /// Who rollouts bucket while signed out; `null` until known.
    String? installId,
  }) = _ProfileState;
}
