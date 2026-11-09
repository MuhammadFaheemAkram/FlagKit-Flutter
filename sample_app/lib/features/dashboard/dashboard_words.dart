import 'package:flagkit_sample/core/common/money.dart';
import 'package:flagkit_sample/core/common/time_text.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/domain/demo/demo_server.dart';
import 'package:flagkit_sample/features/common/flag_words.dart';
import 'package:material_ui/material_ui.dart';

export 'package:flagkit_sample/features/common/flag_words.dart'
    show reasonWords;

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

/// The cache's freshness as a chip.
(IconData, String, Color) cacheStyle(CacheState state, AppColors colors) =>
    switch (state) {
      CacheState.fresh => (Icons.check_circle_outline, 'Fresh', colors.fresh),
      CacheState.stale => (Icons.schedule, 'Stale', colors.stale),
      CacheState.expired => (Icons.history, 'Expired', colors.expired),
      CacheState.empty => (Icons.inbox_outlined, 'Empty', colors.empty),
    };

/// What the cache's freshness means, in words.
String cacheWords(CacheState state) => switch (state) {
  CacheState.fresh => 'Fetched recently: no refresh needed.',
  CacheState.stale => 'Due for a refresh; the flags are still used.',
  CacheState.expired => 'Old: still used, refreshed at every chance.',
  CacheState.empty => 'Nothing cached: every flag is the app\'s default.',
};

/// A refresh's result, for the SnackBar.
String refreshResultWords(RefreshSummary result) => switch (result) {
  RefreshSummary(kind: RefreshKind.updated, changed: 0, :final skipped) =>
    'Refreshed: no flag changed.${_skippedWords(skipped)}',
  RefreshSummary(kind: RefreshKind.updated, :final changed, :final skipped) =>
    'Refreshed: ${changed == 1 ? '1 flag' : '$changed flags'} changed.'
        '${_skippedWords(skipped)}',
  RefreshSummary(kind: RefreshKind.upToDate) =>
    'Up to date: the server has nothing new.',
  RefreshSummary(kind: RefreshKind.offline) =>
    'You\'re offline: the flags stay as they are.',
  RefreshSummary(kind: RefreshKind.failed, :final reason) =>
    'The refresh failed (${reason ?? 'unknown'}). The flags stay as they are.',
  RefreshSummary(kind: RefreshKind.rejected) =>
    'The server rejected the API key. The flags stay as they are.',
};

String _skippedWords(int skipped) => switch (skipped) {
  0 => '',
  1 => ' 1 invalid flag was left out.',
  _ => ' $skipped invalid flags were left out.',
};

/// Why a refresh ran, in words.
String causeWords(RefreshCause cause) => switch (cause) {
  RefreshCause.startup => 'At start',
  RefreshCause.interval => 'Every minute',
  RefreshCause.resumed => 'Back in the app',
  RefreshCause.reconnect => 'Back online',
  RefreshCause.manual => 'Refresh',
};

/// What a refresh did, in a word or two.
String outcomeWords(RefreshKind kind) => switch (kind) {
  RefreshKind.updated => 'Updated',
  RefreshKind.upToDate => 'Up to date',
  RefreshKind.offline => 'Offline',
  RefreshKind.failed => 'Failed',
  RefreshKind.rejected => 'Key rejected',
};

/// A flag's kind of value, in a word or two.
String kindWords(FlagKind kind) => switch (kind) {
  FlagKind.onOff => 'on/off',
  FlagKind.text => 'text',
  FlagKind.wholeNumber => 'whole number',
  FlagKind.number => 'number',
  FlagKind.json => 'JSON',
};

/// A reading's value, kind and reason in one line, with the bucket for a
/// rollout: "true · on/off · you're in the rollout (bucket 404, 25 %)".
String readingLine(FlagReading reading) {
  final bucket = switch (reading) {
    FlagReading(:final bucket?, :final rolloutPercent?) =>
      ' (bucket $bucket, rollout ${formatPercent(rolloutPercent)})',
    _ => '',
  };
  return [
    reading.value,
    if (reading.kind case final kind?) kindWords(kind),
    '${reasonWords(reading.reason)}$bucket',
  ].join(' · ');
}

/// The server's failure rate, as a choice.
String failuresWords(ServerFailures failures) => switch (failures) {
  ServerFailures.none => '0 %',
  ServerFailures.half => '50 %',
  ServerFailures.all => '100 %',
};

/// The server's speed, as a choice.
String speedWords(ServerSpeed speed) => switch (speed) {
  ServerSpeed.fast => 'Fast',
  ServerSpeed.normal => 'Normal',
  ServerSpeed.slow => 'Slow',
};

/// A refresh in the log: "At start · Updated · 09:41:00".
String refreshLine(LastRefresh refresh) => [
  causeWords(refresh.cause),
  outcomeWords(refresh.kind),
  clockTime(refresh.at),
  ?refresh.error,
].join(' · ');
