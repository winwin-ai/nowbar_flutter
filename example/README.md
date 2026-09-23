# nowbar_flutter example

An Android countdown timer app that runs on
[`nowbar_flutter`](../README.md). It is not a Now Bar demo: the example no
longer imports the package's widgets or uses the card deck. It uses the
package's Material 3 theme layer and drives a native Android 16 Live Update
through a platform channel that the example declares itself.

Android is the only supported platform.

## The screen

The UI is in Korean and has three parts:

- **Set a duration.** Minute presets (1, 3, 5, 10, 15, 30, 60) plus `−1분` /
  `+1분` steppers. The duration is clamped to 1 minute through 4 hours.
- **A countdown display.** A large `MM:SS` readout (it switches to `HH:MM:SS`
  past an hour) with a progress bar and a status line.
- **Start and stop.** A single `시작` / `종료` button toggles the countdown.

The in-app countdown runs on its own, so it keeps ticking even when no host
handler is registered for the channel.

## Running

From this directory, with an Android device or emulator attached:

```sh
flutter run
```

The example depends on the package by path, so run it from a checkout of the
repository.

## Live Update channel

The example sends every start and stop to the host over a `MethodChannel`
named `nowbar/live_timer`. The Android implementation lives in
`android/app/src/main/kotlin/com/example/nowbar_flutter_example/MainActivity.kt`.

| Method | Arguments | Description |
| --- | --- | --- |
| `start` | `{seconds: int, totalSeconds: int}` | Posts the countdown notification. |
| `stop` | none | Cancels the notification. |

The notification uses channel `nowbar_timer` with `IMPORTANCE_HIGH` and public
lock-screen visibility. It is built from `Notification.ProgressStyle` with a
chronometer countdown anchored to an absolute end time, and `shortCriticalText`
set to `타이머`. Promotion to a Live Update is requested through the
`android.requestPromotedOngoing` extra, because the `setRequestPromotedOngoing`
builder API is API 36.1+ and is not available on `compileSdk` 36.

### Required permissions

The example declares both permissions in
`android/app/src/main/AndroidManifest.xml`:

- `POST_NOTIFICATIONS`
- `POST_PROMOTED_NOTIFICATIONS`

Live Updates require Android 16 or newer.

### Where the timer appears

On Android 16 or newer, a running timer shows up in three places:

- the notification shade's "실시간 정보" (Live info) section,
- a lock-screen Now Bar card, and
- a status-bar chip.

## Fonts

The example bundles a subset of Noto Sans KR (Regular 400 and Bold 700) under
`assets/fonts/`, registered as the family `NotoSansKR`. It is set as the
theme's `fontFamilyFallback` so the Korean labels render on-device and in the
golden test. Latin text falls back to the package's bundled Inter typeface.

## Golden test

The example's golden test carries the `golden` tag and is excluded from CI
because golden images are platform-dependent. Regenerate it from this directory:

```sh
flutter test --update-goldens --tags golden
```

See the [main README](../README.md) for the package API and configuration.
