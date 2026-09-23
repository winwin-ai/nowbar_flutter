English | [한국어](README.ko.md)

# nowbar_flutter

[![CI](https://github.com/winwin-ai/nowbar_flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/winwin-ai/nowbar_flutter/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/nowbar_flutter.svg)](https://pub.dev/packages/nowbar_flutter)

> **Status: 0.2.x (pre-1.0).** The package is published on pub.dev. Its public
> API is frozen for the 0.2 line; the surface widgets are demo components, not
> live system integrations.

This repository holds two things: the `nowbar_flutter` package and the Android
16 Live Update timer app under [`example/`](example). `nowbar_flutter` is a
pure-Dart Flutter recreation of the Samsung Now Bar: a compact, draggable card
deck that stacks animated surfaces for media, notifications, routines, sports,
and timers. The example app drives a real Android 16 Live Update notification.

## Requirements

| Requirement | Version |
| --- | --- |
| Flutter | `>= 3.10.0` |
| Dart SDK | `^3.0.0` |
| Platform | Android |

- The package is pure Dart: no platform channels, no plugins, no native code.
- **The example app's Live Update surfaces require Android 16 (API 36)**: the
  notification shade's "Live info" (실시간 정보) section, the lock-screen Now
  Bar card, and the status-bar chip. Requesting promotion is API 36.1.
- The timer still works on older Android as a standard ongoing countdown
  notification (the example's `minSdk` is 24 / Android 7.0).

## Android 16 Live Update timer

The app under [`example/`](example) is a countdown timer that drives an Android
16 Live Update. Pick a 1, 3, 5, 10, 15, 30, or 60-minute preset, or fine-tune
with the `−1분` / `+1분` steppers (1 minute to 4 hours), then press `시작` to
start and `종료` to stop. On Android 16+ it appears in the shade's "Live info"
section, a lock-screen Now Bar card, and a status-bar chip; on Android 7.0–15
it posts a standard ongoing countdown notification instead. See
[`example/README.md`](example/README.md) for the channel contract.

<p align="center"><img src="doc/screenshots/timer-app.jpg" width="230" alt="Timer app with a running countdown and a status-bar chip"/> <img src="doc/screenshots/timer-lockscreen.jpg" width="230" alt="Lock screen Now Bar card showing the running timer"/> <img src="doc/screenshots/timer-shade.jpg" width="420" alt="Notification shade Live info section showing the timer card"/></p>

## Install

```sh
flutter pub add nowbar_flutter
```

```yaml
dependencies:
  nowbar_flutter: ^0.2.1
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:nowbar_flutter/nowbar_flutter.dart';

void main() => runApp(
  NowBarTheme(
    darkTheme: true,
    child: Scaffold(
      backgroundColor: Colors.black,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: NowBarWidget(
          widgets: [
            NowBarComponent(
              builder: () => const NotificationWidget(
                icon: Icon(NowBarIcons.check),
                title: 'Order shipped',
                content: 'Your package is on the way',
              ),
            ),
            NowBarComponent(
              builder: () => const RoutinesWidget(content: 'Run 5 km'),
            ),
          ],
        ),
      ),
    ),
  ),
);
```

- `builder:` takes a `Widget Function()`, so pass a closure (`builder: () => ...`).
  Function literals aren't constants, so the `widgets` list can't be `const`.
- Tune geometry and motion with `NowBarMetrics` (`cornerRadius`, `widgetHeight`,
  `translationClamp`, `shadowElevation`, `fillMaxWidthOffset`,
  `animationMultiplier`).

## What's in the package

- A draggable, stacked card deck with configurable drag directions.
- Five built-in demo surfaces: media, notification, routines, sports, and timer.
- `NowBarMetrics` for corner radius, height, translation clamp, shadow, width
  fraction, and animation speed.
- Material 3 theming, including `seedColor` for a custom palette.
- The bundled Inter typeface, no font download required.
- Swappable surfaces via `NowBarComponent.builder`.

## Links

- API reference: <https://pub.dev/documentation/nowbar_flutter/latest/>
- Example guide: [`example/README.md`](example/README.md)
- Changelog: [`CHANGELOG.md`](CHANGELOG.md)
- License: [`LICENSE`](LICENSE)
- Third-party notices: [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)

## Credits

- Inspired by the Jetpack Compose project
  [`styropyr0/NowBar`](https://github.com/styropyr0/NowBar). This package is an
  independent reimplementation, and it is **not affiliated with, sponsored by,
  or endorsed by Samsung or the original author**. It ships **no code or
  artwork** from the original repository, and a **license request to the
  upstream author is in progress**.
- Inter typeface by [Rasmus Andersson](https://rsms.me/inter/).

## License

Released under the MIT License. See [`LICENSE`](LICENSE).
