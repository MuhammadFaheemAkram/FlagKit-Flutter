import 'dart:async';

import 'package:flagkit/src/connectivity/network_monitor.dart';
import 'package:flagkit/src/model/cache_status.dart';
import 'package:flagkit/src/model/refresh_record.dart';
import 'package:flagkit/src/model/refresh_result.dart';
import 'package:flagkit/src/scheduling/app_lifecycle.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:meta/meta.dart';

/// Whether the scheduler may start its interval timer. A host's widget
/// tests turn it off (`FlagKitTesting.disableTimers`): a test fails if a
/// timer is still pending when it ends (conventions §11.101).
@internal
bool schedulerTimersEnabled = true;

/// Decides *when* flags are refreshed, so the app never has to call
/// `refresh()`.
///
/// | Trigger | When |
/// |---|---|
/// | `interval` | the cache turns stale, in the foreground |
/// | `resumed` | the app comes back to the foreground |
/// | `reconnect` | the network comes back |
///
/// (`startup` is the client's, at `initialize`; `manual` is `refresh()`.)
///
/// Every automatic trigger **respects freshness**: with a fresh cache it
/// asks nothing, so a resume a minute after the last refresh costs no
/// request. None runs offline or while the API key is rejected. There is no
/// background refresh: flags are read in the foreground, and `resumed`
/// refreshes a stale cache the moment the app is used again.
@internal
final class RefreshScheduler {
  RefreshScheduler({
    required this._refresh,
    required this._status,
    required this._untilStale,
    required this._monitor,
    required this._lifecycle,
    required this.interval,
    required this._paused,
    required this._logger,
  });

  final Future<RefreshResult> Function(RefreshTrigger trigger) _refresh;
  final CacheStatus Function() _status;

  /// How long until the cache turns stale (zero or less: it isn't fresh).
  final Duration Function() _untilStale;
  final NetworkMonitor _monitor;
  final AppLifecycle _lifecycle;
  final Duration interval;
  final bool Function() _paused;
  final FlagKitLogger _logger;

  final _subscriptions = <StreamSubscription<bool>>[];
  Timer? _timer;
  bool _running = false;

  void start() {
    if (_running) return;
    _running = true;
    _subscriptions
      ..add(_lifecycle.watchForeground().listen(_foregroundChanged))
      // The monitor's stream starts with the current value: only a
      // `false → true` after it is a reconnect.
      ..add(_monitor.watch().skip(1).listen(_onlineChanged));
    if (_lifecycle.isForeground) rearm();
  }

  Future<void> stop() async {
    _running = false;
    _timer?.cancel();
    await Future.wait([for (final s in _subscriptions) s.cancel()]);
    _subscriptions.clear();
  }

  void _foregroundChanged(bool foreground) {
    if (foreground) {
      rearm();
      unawaited(trigger(RefreshTrigger.resumed));
    } else {
      // Out of sight, nothing reads the flags: no timer in the background.
      _timer?.cancel();
    }
  }

  void _onlineChanged(bool online) {
    if (online) unawaited(trigger(RefreshTrigger.reconnect));
  }

  /// Arms the one timer for the moment the cache turns stale: at start,
  /// back in the foreground, and after each time it fires. A refresh from
  /// elsewhere (a reconnect, `refresh()`) needs no call: when the timer
  /// fires and finds the cache fresh again, it re-arms for the new moment.
  ///
  /// Not a periodic timer: started at launch, a period's tick lands just
  /// *before* the cache it fetched turns stale (the fetch took a moment),
  /// finds it fresh, and the refresh waits a whole second period (found on
  /// a device). And never "at once" for a cache already stale: a refresh
  /// that failed leaves it stale, and re-arming at once would loop as fast
  /// as the server fails (conventions §11.100). A stale cache waits one
  /// [interval] before the next try.
  void rearm() {
    _timer?.cancel();
    if (!_running || !_lifecycle.isForeground || !schedulerTimersEnabled) {
      return;
    }
    final untilStale = _untilStale();
    _timer = Timer(
      untilStale > Duration.zero ? untilStale : interval,
      () => unawaited(_onTimer()),
    );
  }

  Future<void> _onTimer() async {
    await trigger(RefreshTrigger.interval);
    // Refreshed, or found fresh (another trigger refreshed meanwhile), or
    // skipped (offline, paused): either way, the next moment from here.
    rearm();
  }

  /// Refreshes for [trigger] if the cache isn't fresh, the device is
  /// online and the key hasn't been rejected.
  Future<void> trigger(RefreshTrigger trigger) async {
    if (!_running) return;
    if (!_monitor.isOnline) {
      _logger.debug('${trigger.name}: offline, nothing attempted');
      return;
    }
    if (_paused()) {
      _logger.debug('${trigger.name}: paused (the API key was rejected)');
      return;
    }
    final status = _status();
    if (status == CacheStatus.fresh) return;
    _logger.debug('${trigger.name}: the cache is ${status.name}, refreshing');
    await _refresh(trigger);
  }
}
