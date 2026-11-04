## 0.1.0

- The public API's shape:
  - `FlagKit` (`initialize`, `isEnabled`, `getString`, `getInt`, `getDouble`, `getJson`, `getValue`, `detail`, `setContext`, `context`, `changes`, `refresh`, `clearCache`, `shutdown`, `instance`, `version`);
  - `FlagKitClient`, the same calls as an interface;
  - `FlagKitConfig`, with its rules checked at `initialize`;
  - `FlagValue` (`BoolValue`, `StringValue`, `IntValue`, `DoubleValue`, `JsonValue`), `FlagType`, `FlagSource`, `EvaluationReason`, `FlagDetail`, `EvaluationContext`;
  - `RefreshResult` and its six cases.
- Reads never throw and never wait. There are no flags yet, so every read returns the caller's default (`flagNotFound`, or `notInitialized` before `initialize`). The cache comes in 0.2.0 and the server in 0.3.0.
