import 'package:meta/meta.dart';

// Small JSON helpers, so the SDK needs no `collection` dependency for the
// one place it compares nested values: a JSON flag.

/// A deep, unmodifiable copy of [value], which must be JSON: `null`, a
/// `bool`, a finite `num`, a `String`, a `List` of JSON or a `Map` with
/// `String` keys and JSON values. Throws an [ArgumentError] otherwise.
///
/// Unmodifiable because a flag's value is shared by every read: a caller
/// that changed the map it was given would change it for everyone.
@internal
Object? freezeJson(Object? value, [String path = r'$']) => switch (value) {
  null || bool() || String() => value,
  num() when value.isFinite => value,
  num() => throw ArgumentError.value(value, path, 'not a finite number'),
  List<Object?>() => List<Object?>.unmodifiable([
    for (final (i, item) in value.indexed) freezeJson(item, '$path[$i]'),
  ]),
  Map<Object?, Object?>() => Map<String, Object?>.unmodifiable({
    for (final MapEntry(:key, value: item) in value.entries)
      if (key is String)
        key: freezeJson(item, '$path.$key')
      else
        key.toString(): throw ArgumentError.value(
          key,
          path,
          'a non-string key',
        ),
  }),
  _ => throw ArgumentError.value(value, path, 'not a JSON value'),
};

/// Whether two JSON values are equal, comparing lists in order and maps by
/// key, at every depth.
@internal
bool jsonEquals(Object? a, Object? b) => switch ((a, b)) {
  (final List<Object?> x, final List<Object?> y) =>
    x.length == y.length &&
        Iterable<int>.generate(x.length).every((i) => jsonEquals(x[i], y[i])),
  (final Map<Object?, Object?> x, final Map<Object?, Object?> y) =>
    x.length == y.length &&
        x.entries.every(
          (entry) =>
              y.containsKey(entry.key) && jsonEquals(entry.value, y[entry.key]),
        ),
  _ => a == b,
};

/// A hash consistent with [jsonEquals]: equal values hash alike, whatever
/// the maps' key order.
@internal
int jsonHash(Object? value) => switch (value) {
  final List<Object?> list => Object.hashAll(list.map(jsonHash)),
  final Map<Object?, Object?> map => Object.hashAllUnordered(
    map.entries.map((entry) => Object.hash(entry.key, jsonHash(entry.value))),
  ),
  _ => value.hashCode,
};
