import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/features/dashboard/cubit/try_user_cubit.dart';
import 'package:flagkit_sample/features/dashboard/widgets/reading_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// "Try a user": a user id, and what every flag would be for them. The
/// app's own user doesn't change.
class TryUserSection extends StatelessWidget {
  const TryUserSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TryUserCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          child: TextField(
            key: const ValueKey('tryUserId'),
            decoration: const InputDecoration(
              labelText: 'User id to try',
              hintText: 'maya',
              helperText:
                  'What every flag would be for this user, in your country '
                  'and app version. Your own flags stay as they are.',
              helperMaxLines: 3,
            ),
            textInputAction: TextInputAction.done,
            onChanged: context.read<TryUserCubit>().setUserId,
          ),
        ),
        for (final reading in state.readings) ReadingTile(reading),
      ],
    );
  }
}
