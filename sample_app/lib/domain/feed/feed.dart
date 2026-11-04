import 'package:flutter/foundation.dart';

/// A story in the home feed.
@immutable
final class FeedItem {
  const FeedItem({required this.title, required this.topic});

  final String title;
  final String topic;

  @override
  bool operator ==(Object other) =>
      other is FeedItem && other.title == title && other.topic == topic;

  @override
  int get hashCode => Object.hash(title, topic);
}

/// The demo's stories: as many as a page size asks for.
abstract final class FeedCatalog {
  static const _topics = ['Brewing', 'Beans', 'Gear', 'Recipes', 'Origins'];

  /// The first [count] stories (0–100).
  static List<FeedItem> items(int count) => [
    for (var i = 1; i <= count.clamp(0, 100); i++)
      FeedItem(title: 'Story $i', topic: _topics[(i - 1) % _topics.length]),
  ];
}
