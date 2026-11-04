import 'package:bloc_test/bloc_test.dart';
import 'package:flagkit_sample/domain/context/user_context.dart';
import 'package:flagkit_sample/features/profile/cubit/profile_cubit.dart';
import 'package:flagkit_sample/features/profile/profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeUserContext user;

  setUp(() => user = FakeUserContext());
  tearDown(() => user.close());

  group('ProfileCubit', () {
    test('starts from the current user', () {
      expect(ProfileCubit(user).state, AppUser.initial);
    });

    blocTest<ProfileCubit, AppUser>(
      'every change goes to the context, and comes back as state',
      build: () => ProfileCubit(user),
      act: (cubit) => cubit
        ..signIn('alex')
        ..setCountry('PK')
        ..setAppVersion('1.9.0')
        ..signOut(),
      expect: () => const [
        AppUser(userId: 'alex', appVersion: '2.1.0'),
        AppUser(userId: 'alex', country: 'PK', appVersion: '2.1.0'),
        AppUser(userId: 'alex', country: 'PK', appVersion: '1.9.0'),
        AppUser(country: 'PK', appVersion: '1.9.0'),
      ],
    );
  });

  group('the view', () {
    Future<void> pump(WidgetTester tester) async {
      tester.usePhoneSurface();
      await tester.pumpThemed(
        BlocProvider(
          create: (_) => ProfileCubit(user),
          child: const ProfileView(),
        ),
      );
    }

    testWidgets('signed out: Sign in waits for a user id', (tester) async {
      await pump(tester);
      Finder signIn() => find.widgetWithText(FilledButton, 'Sign in');

      expect(tester.widget<FilledButton>(signIn()).onPressed, isNull);
      await tester.enterText(find.byKey(const ValueKey('userId')), '   ');
      await tester.pump();
      expect(tester.widget<FilledButton>(signIn()).onPressed, isNull);

      await tester.enterText(find.byKey(const ValueKey('userId')), 'alex');
      await tester.pump();
      await tester.tap(signIn());
      await tester.pump();

      expect(user.current.userId, 'alex');
      expect(find.text('alex'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('signed in: Sign out', (tester) async {
      user.signIn('alex');
      await pump(tester);

      await tester.tap(find.text('Sign out'));
      await tester.pump();

      expect(user.current.isSignedIn, isFalse);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('the country and the app version', (tester) async {
      await pump(tester);

      await tester.tap(find.byKey(const ValueKey('country')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PK').last);
      await tester.pumpAndSettle();
      expect(user.current.country, 'PK');

      await tester.tap(find.text('1.9.0'));
      await tester.pump();
      expect(user.current.appVersion, '1.9.0');
    });
  });
}
