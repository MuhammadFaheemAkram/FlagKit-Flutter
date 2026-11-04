import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:material_ui/material_ui.dart';

/// A reading's source as a chip: an icon, a word and a color (never the
/// color alone).
(IconData, String, Color) sourceStyle(ReadingSource source, AppColors colors) =>
    switch (source) {
      ReadingSource.override => (
        Icons.edit_outlined,
        'Override',
        colors.overridden,
      ),
      ReadingSource.server => (
        Icons.cloud_done_outlined,
        'Server',
        colors.server,
      ),
      ReadingSource.cache => (Icons.save_outlined, 'Cache', colors.cache),
      ReadingSource.appDefault => (
        Icons.settings_backup_restore,
        'Default',
        colors.appDefault,
      ),
    };

/// Why a reading has its value, in words.
String reasonWords(ReadingReason reason) => switch (reason) {
  ReadingReason.override => 'overridden on this device',
  ReadingReason.switchedOff => 'switched off on the server',
  ReadingReason.rulesMatched => 'the targeting rules match you',
  ReadingReason.rulesMissed => 'the targeting rules don\'t match you',
  ReadingReason.inRollout => 'you\'re in the rollout',
  ReadingReason.outsideRollout => 'you\'re outside the rollout',
  ReadingReason.onForEveryone => 'on for everyone',
  ReadingReason.notRunning => 'FlagKit isn\'t running',
  ReadingReason.unknownFlag => 'FlagKit doesn\'t know this flag yet',
  ReadingReason.wrongType => 'the server sends another type',
};
