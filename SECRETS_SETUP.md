# Setting up analytics secrets

Analytics is entirely optional — see [`ANALYTICS.md`](ANALYTICS.md). Skip this
file if you don't want it: the app and the landing site both build and run
exactly as before with none of these set, and no consent prompt ever appears.

If you do want to switch it on for your deployment, none of the values below
are hard-coded anywhere in this repository. They are read from environment
variables at build time (`String.fromEnvironment` in the app,
`Platform.environment` in the site generator) and CI supplies them from
**GitHub repository secrets**. Nothing below is committed to source control,
and nothing needs to be for the project to keep working — a fork with no
secrets configured simply ships without analytics.

## 1. Create the accounts and collect the values

### Firebase Analytics (Google)

1. Go to the [Firebase console](https://console.firebase.google.com/) and
   create a project (or use an existing one).
2. Add a **Web app** to the project: Project settings → General → "Add app" →
   Web. Firebase shows a config object; you need:
   - `apiKey` → `FIREBASE_API_KEY`
   - `appId` → `FIREBASE_APP_ID_WEB`
   - `messagingSenderId` → `FIREBASE_MESSAGING_SENDER_ID`
   - `projectId` → `FIREBASE_PROJECT_ID`
   - `measurementId` (starts with `G-`) → `FIREBASE_MEASUREMENT_ID`
3. Add an **Android app** to the same project: Project settings → General →
   "Add app" → Android. Use `com.example.mellisuga`, or whatever
   `applicationId` is set to in `apps/mellisuga/android/app/build.gradle.kts`,
   as the package name.
   - The Android app's `appId` (also called the Google App ID, shaped like
     `1:1234567890:android:abcdef`) → `FIREBASE_APP_ID_ANDROID`
4. Make sure **Google Analytics** is enabled for the Firebase project
   (Firebase prompts for this when the project is created, or it can be added
   afterwards under Project settings → Integrations).

None of these values are secret in the sense of granting write access to
anything protected — Firebase's own security model assumes the web config
object is public, since it ships inside every page that uses it. They still
go through GitHub secrets rather than a source file, so a fork does not
silently start reporting into the upstream project's Firebase account.

### AppMetrica (Yandex) — mobile

1. Go to the [AppMetrica console](https://appmetrica.yandex.com/) and create
   an application (or use an existing one) for the Android app.
2. Copy its **API key** from the application's settings page →
   `APPMETRICA_API_KEY`.

### AppMetrica (Yandex) — web

1. In the same AppMetrica console, create a second application of type "Site"
   (or reuse one), pointed at the landing site's domain.
2. Copy its **API key** → `APPMETRICA_WEB_API_KEY`.

### Yandex Metrica

1. Go to [Yandex Metrica](https://metrica.yandex.com/) and create a counter
   for the landing site's domain.
2. Copy the **counter ID** (a number) → `YANDEX_METRICA_COUNTER_ID`.

## 2. Add them as GitHub repository secrets

In the repository on GitHub: **Settings → Secrets and variables → Actions →
New repository secret**. Add each value collected above under the exact name
shown:

```
FIREBASE_API_KEY
FIREBASE_APP_ID_ANDROID
FIREBASE_APP_ID_WEB
FIREBASE_MESSAGING_SENDER_ID
FIREBASE_PROJECT_ID
FIREBASE_MEASUREMENT_ID
APPMETRICA_API_KEY
APPMETRICA_WEB_API_KEY
YANDEX_METRICA_COUNTER_ID
```

Or with the [GitHub CLI](https://cli.github.com/), from the repository root:

```bash
gh secret set FIREBASE_API_KEY
gh secret set FIREBASE_APP_ID_ANDROID
gh secret set FIREBASE_APP_ID_WEB
gh secret set FIREBASE_MESSAGING_SENDER_ID
gh secret set FIREBASE_PROJECT_ID
gh secret set FIREBASE_MEASUREMENT_ID
gh secret set APPMETRICA_API_KEY
gh secret set APPMETRICA_WEB_API_KEY
gh secret set YANDEX_METRICA_COUNTER_ID
```

(`gh secret set NAME` without a value prompts for it interactively, so
nothing is ever typed into shell history.)

You do not have to set all nine. Each vendor is switched on independently —
set only Firebase's six, or only the two AppMetrica keys, or only the Yandex
Metrica counter, and the rest simply stay off. `AnalyticsConfig`/
`AnalyticsBuildConfig` in the source treat each vendor as configured only
when every one of *its* values is present.

## 3. That's it

[`deploy-pages.yml`](.github/workflows/deploy-pages.yml) and
[`release.yml`](.github/workflows/release.yml) already read these secrets and
pass them through as `--dart-define` values (app) or environment variables
(landing site build) — see the `Build the app` / `Build Android` and
`Build the landing site` steps in each workflow. Nothing else needs editing.
[`ci.yml`](.github/workflows/ci.yml) intentionally never receives these
secrets: pull request builds, including from forks, must never be able to
read repository secrets, and the whole point of the empty-by-default design
is that CI stays green without them.

To rotate a key, update the GitHub secret and re-run the workflow — nothing
in source needs to change.
