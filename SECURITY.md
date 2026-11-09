# Security Policy

## Supported Versions

FlagKit is a learning/reference project. Security fixes are applied to the latest `main` only.

| Version | Supported |
|---------|:---------:|
| `main`  | ✅ |

## Reporting a Vulnerability

Please **do not** open a public issue for security problems.

Instead, email **muhammadfaheem004@gmail.com** with:

- a description of the issue and its impact;
- steps to reproduce (a proof of concept if possible);
- any suggested remediation.

You can expect an acknowledgement within a few business days.

## What the SDK Holds

FlagKit has **no backend and no real API key**. The default transport is a fake server inside the app: nothing leaves the device unless a host app passes its own `RemoteConfigTransport`.

- **Flag definitions** (values, off values, rollouts, rules) live in the SDK's own SQLite database (`flagkit.sqlite`, drift) in the app's documents directory, never in the host's database. They aren't encrypted at rest; the operating system's app sandbox protects them like any app's private files. They're replaced by every refresh, and `clearCache()` removes them.
- **Local overrides** are in the same database until cleared. They're a debug tool: a release build should not offer a way to set them.
- **The identity:** a random anonymous id (a UUID v4) per install, in the same database, used only to bucket rollouts. The evaluation context (a user id, a country, an app version, custom attributes) stays in memory: the SDK never stores it and never sends it. Evaluation happens on the device.
- **The API key** is sent to the transport with each fetch, and **masked** when a config is printed (`FlagKitConfig.toString()`), so it doesn't leak into logs or crash reports.
- **Logs:** without `debugMode` the SDK logs nothing; with it, keys, values and the context go to `dart:developer`'s log. Don't enable it in a release build.
- **Server data is input:** every definition is validated before it's stored (types, keys, rollouts, rules); an invalid flag is skipped, a malformed payload changes nothing, and the database's `CHECK`s refuse anything that slips through. Every value is a bound parameter: nothing from the server reaches SQL as code.

### For a host app

- **Flags are not access control.** A flag decides what a screen shows; anything that must be enforced (a paid feature, an admin action) must be enforced on the server too. Definitions on the device can be read, and overrides can change them.
- **Keep personal data out of the context** unless your privacy policy covers it; it never leaves the device, but your own transport could log it.
- **A real transport should use HTTPS** and send the API key in a header, never in the URL.
- **A key in an app binary is public:** treat it as an identifier for reading flag definitions, never as a secret that grants writes.
- **Hide the debug tools in release builds** (overrides, the dashboard).

The practical attack surface is small. Reports about data handling, dependency issues or unsafe patterns are still very welcome.
