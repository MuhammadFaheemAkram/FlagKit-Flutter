import 'dart:convert';

import 'package:meta/meta.dart';

const _offsetBasis = 0x811c9dc5;
const _prime = 0x01000193;

/// The 32-bit FNV-1a hash of [text]'s UTF-8 bytes.
///
/// Not `String.hashCode`: that isn't stable across runs, isolates or
/// platforms, and a rollout must put the same user in the same bucket on
/// every device, today and after every update. FNV-1a is a few lines, the
/// same in every language (a server could compute the same bucket), and
/// spreads short keys well. Its published test vectors pin it: changing the
/// hash would reshuffle every user of every rollout, a breaking change.
@internal
int fnv1a32(String text) {
  var hash = _offsetBasis;
  for (final byte in utf8.encode(text)) {
    hash ^= byte;
    // Multiply modulo 2^32. A 32-bit number times a 25-bit prime fits a
    // 64-bit int; on the web (doubles) it wouldn't, but this SDK runs on
    // phones.
    hash = (hash * _prime) & 0xffffffff;
  }
  return hash;
}
