import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The app talks to the SDK through its own ports (AppFlags, UserContext,
// FlagsDebug). Only the files that wire the SDK in may import it: the
// adapters, the DI module, the SDK's config and main(). A Cubit or a
// screen that imported it would tie the app's logic to one vendor, and
// scatter flag keys through the widgets.
void main() {
  test('only the wiring imports package:flagkit', () {
    final importers = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.endsWith('.config.dart'))
        .where(
          (file) =>
              file.readAsStringSync().contains("import 'package:flagkit/"),
        )
        .map((file) => file.path)
        .toList();

    expect(
      importers,
      unorderedEquals([
        'lib/app/bootstrap.dart',
        'lib/app/sample_flagkit_config.dart',
        'lib/data/flags/flagkit_app_flags.dart',
        'lib/data/flags/flagkit_flags_debug.dart',
        'lib/data/context/flagkit_user_context.dart',
        'lib/di/app_module.dart',
      ]),
    );
  });

  test('flag keys are written in one place', () {
    final keyFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => file.readAsStringSync().contains("'new_home_screen'"))
        .map((file) => file.path);

    expect(keyFiles, ['lib/data/flags/app_flag_keys.dart']);
  });
}
