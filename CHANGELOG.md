# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.1

### Changed

- Lowered the minimum SDK requirements so the package installs on a much wider
  range of toolchains: Dart SDK `^3.12.0` → `^3.0.0` and Flutter
  `>=3.44.0` → `>=3.10.0`. The code only relies on Dart 3 language features
  (records, patterns, class modifiers) and Flutter APIs available since 3.10,
  so no API changes were needed. `flutter_lints` was lowered to `^3.0.0` to
  match.
- README requirements tables (English and Korean) now state the lowered
  versions, and the stale "not on pub.dev yet" notice was removed.
- The example app was rewritten from a Now Bar demo into a countdown timer app.
  It no longer imports the package's widgets or uses the card deck. Instead it
  drives an Android 16 Live Update (a promoted ongoing notification) over the
  example's own `nowbar/live_timer` method channel, so a running timer appears
  in the notification shade's "Live info" section, as a lock-screen Now Bar
  card, and as a status-bar chip.
- The example bundles a subset of Noto Sans KR (Regular 400, Bold 700) as the
  theme's `fontFamilyFallback` so its Korean labels render on-device and in the
  golden test, and the example golden image was regenerated.

## 0.1.0

### Added

- `NowBarWidget` engine: a stacked, draggable Now Bar card deck with
  axis-locked pan gestures, vertical cycling with wrap-around, swipe-to-dismiss,
  and `NowBarMetrics` for corner radius, height, translation clamp, shadow,
  width fraction, and an animation multiplier.
- `NowBarComponent` (builder slot plus a `dismissible` flag),
  `NowBarDragController` (dragUp, dragDown, dragVertically, dragHorizontally),
  and `NotificationColorController` (solid or gradient fills).
- Five built-in surfaces: `MediaPlayerWidget`, `NotificationWidget`,
  `RoutinesWidget`, `SportsWidget`, and `TimerWidget`.
- Material 3 theme layer: `NowBarTheme` (light, dark, or a seed color),
  `NowBarColors`, `NowBarTypography`, and a neutral `NowBarIcons` catalog.
- Bundled Inter typeface (Regular 400, SemiBold 600, Bold 700) with its
  SIL OFL 1.1 notice.
- Runnable example app demonstrating every surface.
- 116 unit and widget tests plus 10 golden-image tests.
- Android platform support declared in `pubspec.yaml`.
