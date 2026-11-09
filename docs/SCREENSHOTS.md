# Screenshots

Captured on Tuesday 10 November 2026 on an **iPhone 17 Pro simulator** (iOS, debug build, status bar fixed at 9:41), then downscaled to 1000 px tall. The flags are real: each screen reads them through the SDK, from the demo server's config (`sample_app/assets/remote_config.json`), for the user Profile sets.

## The three looks (`home_theme`)

`home_theme` is "modern" for users in Pakistan and the UAE, "classic" for everyone else. The third look, "ocean", is set here with a **local override** from the Dashboard.

| Classic (no country) | Modern (PK) | Ocean (an override) |
|:---:|:---:|:---:|
| <img src="screenshots/home-classic.png" width="250" alt="Home in the indigo classic look: the Spring sale banner, then 'Why am I seeing this?' open: 'You see the new home because the flag is on for everyone. You see the classic look because the flag targets other users: its rules don't match you.' Then the Deals section"> | <img src="screenshots/home-modern.png" width="250" alt="Home in the teal modern look, the same banner and sections, for a user in Pakistan"> | <img src="screenshots/home-ocean.png" width="250" alt="Home in the blue ocean look; the why line says 'You see the ocean look because it's overridden on this device.'"> |

## A rollout, targeting and an override

| Checkout (bucket 404, in the 25 %) | Profile | A flag's rules | An override |
|:---:|:---:|:---:|:---:|
| <img src="screenshots/checkout-rollout.png" width="200" alt="The one-page checkout. 'You see the one-page checkout because you're in its 25 % rollout (bucket 404 of 10,000, below 2500). From the server. You see a 15.5 % discount because the flag's targeting rules match you.' The cart, a 15.5 % discount of $9.69, total $52.81"> | <img src="screenshots/profile.png" width="200" alt="Profile: signed in as maya, 'Rollouts now use this id, so the same flags follow you to any device', the install id 'Not used while you're signed in', country PK, app version 2.1.0"> | <img src="screenshots/flag-rules.png" width="200" alt="home_theme's page: what you get, modern, the targeting rules match you; on the server switched on, value modern, off value classic, kind text; Targeting: a green check, 'country is one of PK, AE', 'Matches you'"> | <img src="screenshots/flag-override.png" width="200" alt="home_theme's page in the ocean look: 'Overridden with \"ocean\".', the override value field, an Override button and Clear override"> |

## The Dashboard

| The cache and actions | Every flag | With an override |
|:---:|:---:|:---:|
| <img src="screenshots/dashboard.png" width="250" alt="The Dashboard: Fresh, flags cached 6, overrides 0, config version 2, fetched and last refresh times, the install id; Refresh and Clear cache"> | <img src="screenshots/dashboard-flags.png" width="250" alt="The flag list: new_checkout true, on/off, you're in the rollout (bucket 404, rollout 25 %); home_theme modern, the targeting rules match you; feed_page_size 12; discount_percentage 15.5; home_config JSON; each with a Server chip; then Try a user"> | <img src="screenshots/dashboard-override.png" width="250" alt="The flag list with home_theme 'ocean', overridden on this device, and an Override chip with a pencil icon instead of Server"> |

## Dark: the demo's controls

| The server console | Device offline | Try a user |
|:---:|:---:|:---:|
| <img src="screenshots/console-dark.png" width="250" alt="Dark mode, the server console: each flag with a switch; new_checkout rolled out to 25 % with a choice of 0, 10, 25, 50, 100 %; home_theme with a choice of classic, modern, ocean"> | <img src="screenshots/offline-dark.png" width="250" alt="Dark mode: Offline (simulated) with a crossed-out wifi icon, the Device offline switch on, and the flag list still serving every value"> | <img src="screenshots/try-user-dark.png" width="250" alt="Dark mode, Try a user with 'sam': new_checkout false, you're outside the rollout (bucket 4011, rollout 25 %), while the app's own user stays in it"> |

## Large text

Accessibility text size **AX3** (about 235 %), light mode. Past 130 %, side-by-side layouts stack: a flag's source chip goes under its details, and a stat's value goes under its label.

| Checkout's why line | The Dashboard |
|:---:|:---:|
| <img src="screenshots/checkout-large.png" width="250" alt="Checkout at AX3: 'Why am I seeing this?' and the rollout sentence wrapping over many lines"> | <img src="screenshots/dashboard-large.png" width="250" alt="The Dashboard at AX3: Fresh, then Flags cached, Overrides and Config version each with its value under the label"> |

The Dashboard's first large-text screenshot found a layout bug: "Fetched" broke mid-word (`Fetche` / `d`) beside a time. A stat's value now goes under its label past 130 %, and a test checks where it is.
