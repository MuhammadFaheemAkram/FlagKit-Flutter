import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flagkit_sample/domain/context/user_context.dart';
import 'package:flagkit_sample/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Profile: the user, their country and the app's version. Targeting rules
/// and rollouts look at these, so changing them changes the other tabs.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ProfileCubit>(),
    child: const ProfileView(),
  );
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileCubit>().state;
    final cubit = context.read<ProfileCubit>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.large),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Text(
              'Flags can target who you are. Change any of these and the '
              'other tabs follow at once.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SectionHeader('User'),
          if (user.userId case final userId?)
            _SignedIn(userId: userId, onSignOut: cubit.signOut)
          else
            _SignInForm(onSignIn: cubit.signIn),
          const SizedBox(height: AppSpacing.large),
          // The menu's own label names it: no heading above it.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: DropdownMenu<String?>(
              key: const ValueKey('country'),
              initialSelection: user.country,
              label: const Text('Country'),
              expandedInsets: EdgeInsets.zero,
              onSelected: cubit.setCountry,
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Not set'),
                for (final country in AppUser.countries)
                  DropdownMenuEntry(value: country, label: country),
              ],
            ),
          ),
          const SectionHeader('App version'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: SegmentedChoice<String>(
              values: AppUser.appVersions,
              labelOf: (version) => version,
              selected: user.appVersion,
              onSelected: cubit.setAppVersion,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Text(
              'A real app reports its own version; the demo lets you pick '
              'one, to see rules like "2.0.0 or later".',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedIn extends StatelessWidget {
  const _SignedIn({required this.userId, required this.onSignOut});

  final String userId;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(userId),
          subtitle: const Text(
            'Rollouts now use this id, so the same flags follow you to any '
            'device.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          child: OutlinedButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ),
      ],
    );
  }
}

/// A user id field and Sign in: no password, it only sets the context.
class _SignInForm extends StatefulWidget {
  const _SignInForm({required this.onSignIn});

  final ValueChanged<String> onSignIn;

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _userId = TextEditingController();

  @override
  void dispose() {
    _userId.dispose();
    super.dispose();
  }

  void _submit() {
    if (_userId.text.trim().isEmpty) return;
    widget.onSignIn(_userId.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Signed out: rollouts use this install\'s anonymous id. Signing '
            'in has no password; it only sets the user id.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.small),
          TextField(
            key: const ValueKey('userId'),
            controller: _userId,
            decoration: const InputDecoration(
              labelText: 'User id',
              hintText: 'user_123',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.small),
          FilledButton.icon(
            onPressed: _userId.text.trim().isEmpty ? null : _submit,
            icon: const Icon(Icons.login),
            label: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}
