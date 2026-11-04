import 'package:flagkit_sample/domain/context/user_context.dart';
import 'package:flagkit_sample/domain/feed/feed.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flagkit_sample/domain/flags/home_config.dart';
import 'package:flagkit_sample/domain/shop/cart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeConfig from JSON', () {
    test('the banner and the sections, in order', () {
      expect(
        HomeConfig.fromJson(const {
          'banner': 'Spring sale',
          'sections': ['deals', 'new', 'popular'],
        }),
        const HomeConfig(
          banner: 'Spring sale',
          sections: [
            HomeSection.deals,
            HomeSection.latest,
            HomeSection.popular,
          ],
        ),
      );
    });

    test('what it can\'t read is left out, never fatal', () {
      expect(
        HomeConfig.fromJson(const {
          'banner': 42,
          'sections': ['deals', 'stories', 7, 'popular'],
        }),
        const HomeConfig(sections: [HomeSection.deals, HomeSection.popular]),
      );
      // A blank banner is no banner.
      expect(HomeConfig.fromJson(const {'banner': '  '}).banner, isNull);
    });

    test('no sections it knows: the fallback\'s', () {
      for (final json in const <Map<String, Object?>>[
        {},
        {'sections': 'deals'},
        {
          'sections': ['stories'],
        },
      ]) {
        expect(
          HomeConfig.fromJson(json).sections,
          HomeConfig.fallback.sections,
        );
      }
    });
  });

  test('a theme name the app doesn\'t know is the classic look', () {
    expect(AppThemeChoice.fromName('modern'), AppThemeChoice.modern);
    expect(AppThemeChoice.fromName('ocean'), AppThemeChoice.ocean);
    expect(AppThemeChoice.fromName('neon'), AppThemeChoice.classic);
    expect(AppThemeChoice.fromName(''), AppThemeChoice.classic);
  });

  group('the cart', () {
    test('the demo cart\'s subtotal', () {
      expect(CartTotals.of(DemoCart.lines, 0).subtotalCents, 6250);
      expect(CartTotals.of(DemoCart.lines, 0).discountCents, 0);
    });

    test('a discount rounds half up to a cent, in integers', () {
      // 15.5 % of $74.50 is 1154.75 cents.
      expect(CartTotals.discountOf(7450, 15.5), 1155);
      // 10 % of $62.50 is exactly 625 cents.
      expect(CartTotals.discountOf(6250, 10), 625);
      // 0.01 % of $1.00 is 0.01 cents: nothing.
      expect(CartTotals.discountOf(100, 0.01), 0);
      // 12.5 % of 4 cents is 0.5 cents: up to 1.
      expect(CartTotals.discountOf(4, 12.5), 1);
    });

    test('the total is the subtotal less the discount', () {
      final totals = CartTotals.of(DemoCart.lines, 15.5);

      expect(totals.discountCents, 969); // 968.75, up
      expect(totals.totalCents, 6250 - 969);
    });

    test('a discount out of range is clamped to 0–100 %', () {
      expect(CartTotals.of(DemoCart.lines, 150).totalCents, 0);
      expect(CartTotals.of(DemoCart.lines, -5).discountCents, 0);
    });
  });

  group('the feed', () {
    test('as many stories as asked, topics in turn', () {
      final items = FeedCatalog.items(7);

      expect(items, hasLength(7));
      expect(items.first, const FeedItem(title: 'Story 1', topic: 'Brewing'));
      expect(items[5].topic, 'Brewing');
    });

    test('kept to 0–100', () {
      expect(FeedCatalog.items(-3), isEmpty);
      expect(FeedCatalog.items(500), hasLength(100));
    });
  });

  test('the user starts signed out, on the latest version', () {
    expect(AppUser.initial.isSignedIn, isFalse);
    expect(AppUser.initial.appVersion, AppUser.appVersions.last);
    expect(const AppUser(userId: 'a', appVersion: '2.0.0').isSignedIn, isTrue);
  });
}
