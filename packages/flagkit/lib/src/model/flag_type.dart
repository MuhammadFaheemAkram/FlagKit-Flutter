/// The type of a flag's values: the server decides it, and a read asks for
/// one.
///
/// A read of the wrong type (`getInt` on a string flag) gets the caller's
/// default, never a converted value: `"30"` silently becoming `30` today
/// and failing tomorrow is worse than an obvious default. The one widening
/// is `getDouble` on an [integer] flag, which loses nothing.
enum FlagType {
  /// `true` or `false`: a feature on or off.
  boolean('boolean'),

  /// Text: a theme name, a copy variant, a URL.
  string('string'),

  /// A whole number: a page size, a limit.
  integer('int'),

  /// A number with a fraction: a percentage, a ratio.
  decimal('double'),

  /// A JSON object: several settings that change together.
  json('json');

  const FlagType(this.wireName);

  /// The type's name in the server's JSON (`"int"`, `"double"`, …).
  final String wireName;

  /// The type named [wireName] on the wire, or `null` for one this SDK
  /// doesn't know (a newer server's): such a flag is skipped, not fatal.
  static FlagType? fromWireName(String wireName) {
    for (final type in values) {
      if (type.wireName == wireName) return type;
    }
    return null;
  }
}
