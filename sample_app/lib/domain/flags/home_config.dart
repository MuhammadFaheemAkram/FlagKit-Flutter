import 'package:flutter/foundation.dart';

/// What the new home shows, from a JSON flag: several settings that change
/// together, so they travel as one value.
@immutable
final class HomeConfig {
  const HomeConfig({this.banner, this.sections = const [HomeSection.latest]});

  /// What the app shows when the flag is missing or unreadable.
  static const fallback = HomeConfig();

  /// The config in [json]. Anything it can't read is left out, never
  /// fatal: a banner that isn't text, an unknown section. The server may
  /// be ahead of this version of the app.
  factory HomeConfig.fromJson(Map<String, Object?> json) {
    final banner = json['banner'];
    final sections = switch (json['sections']) {
      final List<Object?> names => [
        for (final name in names)
          if (name is String) ?HomeSection.fromName(name),
      ],
      _ => const <HomeSection>[],
    };
    return HomeConfig(
      banner: banner is String && banner.trim().isNotEmpty ? banner : null,
      sections: sections.isEmpty ? fallback.sections : sections,
    );
  }

  /// A promotional line at the top, if any.
  final String? banner;

  /// The feed's sections, in order.
  final List<HomeSection> sections;

  @override
  bool operator ==(Object other) =>
      other is HomeConfig &&
      other.banner == banner &&
      listEquals(other.sections, sections);

  @override
  int get hashCode => Object.hash(banner, Object.hashAll(sections));

  @override
  String toString() => 'HomeConfig(banner: $banner, sections: $sections)';
}

/// A section of the new home's feed.
enum HomeSection {
  deals('deals', 'Deals'),
  latest('new', 'New this week'),
  popular('popular', 'Popular');

  const HomeSection(this.wireName, this.title);

  /// The section's name in the flag's JSON.
  final String wireName;

  /// The section's heading.
  final String title;

  /// The section named [name], or `null` for one this app doesn't know.
  static HomeSection? fromName(String name) {
    for (final section in values) {
      if (section.wireName == name) return section;
    }
    return null;
  }
}
