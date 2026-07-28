# Analytics

**Analytics is optional, off by default, and opt-in.** Nobody sees a consent
prompt at all unless the build they are running has at least one analytics
vendor configured — which the official build only does if the project's
maintainers choose to supply the keys described in
[`SECRETS_SETUP.md`](SECRETS_SETUP.md). A build with nothing configured (every
local `flutter run`, every `dart run bin/build.dart` without those
environment variables set, and every fork that has not added its own keys)
behaves exactly as this project always has: no consent prompt, no script, no
network request, nothing to disable.

This document is what [`PRIVACY.md`](PRIVACY.md) points to for the specifics:
every vendor a build can report to, and every event either surface can send.
Nothing is ever reported outside this list.

## Consent

- **App:** the first time a build with a vendor configured finishes starting,
  a dialog asks before anything is sent. The choice is stored on-device and
  can be changed at any time from **About → Privacy & analytics**.
- **Landing site:** a banner at the bottom of the page asks the same question
  before any vendor script loads. The choice is stored in `localStorage` and
  can be reopened from the **"Manage analytics"** link in the footer.
- Declining, or later withdrawing consent, stops any further reporting
  immediately. Nothing is sent while a choice is pending.

## What is never collected

The photos and documents a person works with in the app never leave their
device for any reason — analytics or otherwise — and the code paths that
build analytics events have no access to file contents, file names, or any
other data about what was opened. Analytics events carry only the fields
listed below: short identifiers like a tool's id, an export format, or a
locale code.

## Vendors

| Vendor | Used for | Surfaces | Data controller |
| --- | --- | --- | --- |
| [Firebase Analytics](https://firebase.google.com/docs/analytics) (Google) | Event analytics | App (Android, web), landing site | Google Ireland Limited |
| [AppMetrica](https://appmetrica.yandex.com/) (Yandex) | Event analytics | App (Android via native SDK, web via loader), landing site | Yandex LLC / Yandex Europe |
| [Yandex Metrica](https://metrica.yandex.com/) | Web analytics | App (web build only), landing site | Yandex LLC / Yandex Europe |

A given build reports only to the vendors it was actually given keys for —
see `AnalyticsConfig`/`AnalyticsBuildConfig` in the source for how that is
decided. Each vendor processes what it receives under its own privacy policy;
this project does not control their infrastructure or retention.

## Events

Every event either surface can send. Both are implemented from the same list
on purpose, so this table is the single source of truth — see
`apps/mellisuga/lib/core/analytics/analytics_events.dart` for the app and
`apps/jasper/lib/src/analytics.dart`/`layout.dart` for the site.

| Event | Sent by | Parameters | When |
| --- | --- | --- | --- |
| `app_open` | App | — | The app finishes starting, once analytics is enabled |
| `page_view` | Site | `page` (path) | A page loads, once analytics is enabled |
| `tool_opened` | App | `tool_id` | A tool screen is opened |
| `export_completed` | App | `tool_id`, `format`, `page_count` | An export (PDF or image) finishes and is saved |
| `theme_changed` | App | `mode` (`light`/`dark`/`system`) | The theme is changed |
| `locale_changed` | App | `locale` (language code or `system`) | The display language is changed |
| `consent_changed` | App, site | `granted` (`true`/`false`) | Consent is changed after the first prompt |

Mobile AppMetrica (the native Android SDK, via `appmetrica_plugin`) reports
the event name only — its public API does not expose an attributes map — so
on Android specifically, AppMetrica events carry no parameters. Firebase
Analytics and the web builds of AppMetrica and Yandex Metrica receive the
full parameter set shown above.

## Where the code lives

- `apps/mellisuga/lib/core/analytics/` — the app's consent state
  (`analytics_consent.dart`), the event taxonomy (`analytics_events.dart`),
  build-time configuration (`analytics_build_config.dart`), and the service
  that fans events out to each backend (`analytics_service.dart`).
- `apps/jasper/lib/src/analytics.dart` and `analytics_config.dart` — the
  landing site's consent banner and vendor loaders, built only when
  `AnalyticsConfig.anyEnabled` is true.

## Changing what is reported

Because the event list lives in source rather than a vendor dashboard,
proposing a new event or removing one is an ordinary pull request against the
files above — and against this document, which must stay in sync with them.
