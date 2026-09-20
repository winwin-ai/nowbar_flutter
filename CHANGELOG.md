# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
