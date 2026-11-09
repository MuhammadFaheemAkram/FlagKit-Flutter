# Roadmap

All six build phases are complete (see the [phase summaries](.)). These are the ideas after them, roughly in order of value.

## Transport and delivery

- **A real HTTP transport** as its own package: `ETag` / `If-None-Match` for the config version, `Retry-After` and backoff, gzip, the key in a header. The SDK's `RemoteConfigTransport` contract already fits it.
- **Streaming updates** (server-sent events) instead of polling, so a kill switch reaches every running app in seconds.
- **Background refresh** with `workmanager`, for apps that read flags at a cold start before any network ([TrackLite](https://github.com/MuhammadFaheemAkram/TrackLite-Flutter) shows the pattern).
- **Fetch / activate** (Firebase's model): fetch now, apply at the next launch, so a screen never changes under the user mid-flow.

## Evaluation

- **Multi-variant flags** (A / B / C with weights) and **experiments with sticky assignment**: a user keeps their variant even if the weights change.
- **Exposure events** (which variation a user saw), sent through an analytics SDK such as TrackLite, to measure an experiment.
- **Segments** (reusable rule groups), **OR between rule groups**, and **scheduled rollouts** (ramp 5 % → 50 % over a week).
- **A "serve defaults when expired" option** and **per-flag expiry**, for flags that must not outlive their data.

## Developer experience

- **Code generation** of a typed flags class from the server's definitions, so a key or a type can't be mistyped (the sample's `AppFlags` port, written by hand today).
- **Overrides that expire**, and overrides for a user rather than a device.
- **A live reads count** on the Dashboard (today the count is as of the stats' last change).

## Distribution

- **Publishing to pub.dev** (the name `flagkit` is taken: it would need another), with the `dart doc` output.
- **A web implementation:** the 32-bit hash needs care with JavaScript numbers (the multiply overflows a double); a `BigInt` or split multiply would keep the golden vectors.
