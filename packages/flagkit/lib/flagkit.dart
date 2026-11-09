/// FlagKit: a small feature flag SDK for Flutter apps.
///
/// This is the whole public API. Everything else lives in `lib/src/` and can
/// change in any version; the names below change only with a new major
/// version (and are checked by `test/public_api_test.dart`).
library;

export 'package:flagkit/src/client/flagkit_client.dart' show FlagKitClient;
export 'package:flagkit/src/config/flagkit_config.dart' show FlagKitConfig;
export 'package:flagkit/src/connectivity/network_monitor.dart'
    show ConnectivityNetworkMonitor, NetworkMonitor;
export 'package:flagkit/src/debug/flagkit_debug.dart' show FlagKitDebug;
export 'package:flagkit/src/flagkit.dart' show FlagKit;
export 'package:flagkit/src/model/cache_status.dart' show CacheStatus;
export 'package:flagkit/src/model/evaluation_context.dart'
    show EvaluationContext;
export 'package:flagkit/src/model/evaluation_reason.dart' show EvaluationReason;
export 'package:flagkit/src/model/flag_detail.dart' show FlagDetail;
export 'package:flagkit/src/model/flag_source.dart' show FlagSource;
export 'package:flagkit/src/model/flag_type.dart' show FlagType;
export 'package:flagkit/src/model/flag_value.dart'
    show BoolValue, DoubleValue, FlagValue, IntValue, JsonValue, StringValue;
export 'package:flagkit/src/model/flagkit_stats.dart' show FlagKitStats;
export 'package:flagkit/src/model/refresh_record.dart'
    show RefreshOutcome, RefreshRecord, RefreshTrigger;
export 'package:flagkit/src/model/refresh_result.dart'
    show
        Failed,
        NotInitialized,
        NotModified,
        Offline,
        RefreshResult,
        Unauthorized,
        Updated;
export 'package:flagkit/src/model/targeting_rule.dart'
    show TargetingOperator, TargetingRule;
export 'package:flagkit/src/network/fake_remote_config_server.dart'
    show FakeRemoteConfigServer, FakeServerStats;
export 'package:flagkit/src/network/remote_config_transport.dart'
    show
        ApiKeyRejected,
        ConfigNotModified,
        FetchRequest,
        FetchResponse,
        FetchedConfig,
        RemoteConfigTransport,
        ServerFailure,
        ServerUnreachable,
        TransportException;
