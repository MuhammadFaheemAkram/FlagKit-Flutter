import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
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
String kindWords(RefreshKind kind) => switch (kind) {
  RefreshKind.updated => 'Updated',
  RefreshKind.upToDate => 'Up to date',
  RefreshKind.offline => 'Offline',
  RefreshKind.failed => 'Failed',
  RefreshKind.rejected => 'Key rejected',
};
