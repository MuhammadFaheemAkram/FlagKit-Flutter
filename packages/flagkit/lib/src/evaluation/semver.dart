import 'package:meta/meta.dart';

/// A version `major.minor.patch`, compared as numbers.
///
/// Versions aren't strings: `"2.10.0" < "2.9.0"` as text, so a rule
/// "2.9.0 or later" compared as strings would leave 2.10 out. Missing parts
/// are zero (`2.0` is `2.0.0`). Anything else (a pre-release suffix, a
/// letter) isn't a version here: a rule on it never matches.
@internal
@immutable
final class SemVer implements Comparable<SemVer> {
  const SemVer(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  static final _pattern = RegExp(
    r'^(\d{1,9})(?:\.(\d{1,9}))?(?:\.(\d{1,9}))?$',
  );

  /// [text] as a version, or `null` if it isn't one.
  static SemVer? tryParse(String text) {
    final match = _pattern.firstMatch(text.trim());
    if (match == null) return null;
    int part(int i) => int.parse(match.group(i) ?? '0');
    return SemVer(part(1), part(2), part(3));
  }

  @override
  int compareTo(SemVer other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  @override
  bool operator ==(Object other) => other is SemVer && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}
