---
name: Bug report
about: Report something that isn't working as expected
title: "[Bug] "
labels: bug
assignees: ''
---

## Description

A clear and concise description of the bug. Is it in the SDK (`packages/flagkit`) or the sample app?

## Steps to reproduce

1.
2.
3.

## Expected behaviour

What you expected to happen.

## Actual behaviour

What actually happened (include the error, or the SDK's log with `debugMode: true`, if any).

## Environment

- Platform: Android / iOS
- Device / emulator / simulator:
- OS version:
- Flutter version (`fvm flutter --version`):
- SDK version (`FlagKit.version`):
- Build: debug / release
- The config, if not the sample's (`FlagKitConfig.toString()` masks the key)
- Network: online / offline / Device offline on
- The flag's page on the Dashboard: its value, source and reason, the bucket, each rule's result, any override
- The context: the user id, country and app version (Profile)
- The demo server: failures and speed, and what the console changed
- Text size and theme (if it's a layout issue):

## Screenshots

If applicable, add screenshots to help explain the problem. A screenshot of the flag's page explains most "why do I see this?" questions.
