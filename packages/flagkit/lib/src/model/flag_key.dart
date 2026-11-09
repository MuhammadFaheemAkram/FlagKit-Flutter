import 'package:meta/meta.dart';

final _pattern = RegExp(r'^[a-z0-9_.-]{1,64}$');

/// Whether [key] is a valid flag key: 1–64 characters of `a–z`, `0–9`,
/// `_`, `.` and `-`.
@internal
bool isValidFlagKey(String key) => _pattern.hasMatch(key);
