[English](README.md) | 한국어

# nowbar_flutter

[![CI](https://github.com/winwin-ai/nowbar_flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/winwin-ai/nowbar_flutter/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/nowbar_flutter.svg)](https://pub.dev/packages/nowbar_flutter)

> **상태: 0.2.x (프리 1.0).** 패키지는 pub.dev에 게시되어 있습니다. 공개
> API는 0.2 라인을 기준으로 확정되었습니다. 내장 위젯은 실제 시스템 연동이
> 아니라 데모용 화면입니다.

이 저장소에는 `nowbar_flutter` 패키지와 [`example/`](example)의 Android 16
Live Update 타이머 앱, 두 가지가 들어 있습니다. `nowbar_flutter`는 삼성 Now
Bar를 순수 Dart로 다시 구현한 패키지로, 앱 하단에 고정되는 드래그 가능한 카드
덱 형태로 미디어·알림·루틴·스포츠·타이머 화면을 쌓아 올려 보여줍니다. 예제
앱은 실제 Android 16 Live Update 알림을 구동합니다.

## 요구 사항

| 항목 | 버전 |
| --- | --- |
| Flutter | `>= 3.10.0` |
| Dart SDK | `^3.0.0` |
| 지원 플랫폼 | Android |

- 순수 Dart 패키지입니다. 플랫폼 채널도, 플러그인도, 네이티브 코드도 없습니다.
- **예제 앱의 Live Update 화면에는 Android 16(API 36) 이상이 필요합니다.**
  알림 창의 **"실시간 정보"(Live info)** 섹션, 잠금화면의 Now Bar 카드, 상태
  표시줄 칩이 여기에 해당합니다. 승격 요청은 API 36.1입니다.
- 타이머 자체는 구형 Android에서도 표준 상시 카운트다운 알림으로 동작합니다
  (예제의 `minSdk`는 24 / Android 7.0).

## Android 16 실시간 정보 타이머

[`example/`](example)에 있는 앱은 Android 16 Live Update를 구동하는 카운트다운
타이머입니다. 1, 3, 5, 10, 15, 30, 60분 프리셋으로 시간을 정하거나 `−1분` /
`+1분` 스테퍼로 1분~4시간 사이에서 조절한 뒤 `시작`을 눌러 시작하고 `종료`로
멈춥니다. Android 16 이상에서는 알림 창의 "실시간 정보" 섹션, 잠금화면 Now Bar
카드, 상태 표시줄 칩 세 곳에 나타나고, Android 7.0~15에서는 대신 표준 상시
카운트다운 알림으로 표시됩니다. 채널 규약은
[`example/README.md`](example/README.md)를 참고하세요.

<p align="center"><img src="doc/screenshots/timer-app.jpg" width="230" alt="실행 중인 카운트다운과 상태 표시줄 칩이 있는 타이머 앱"/> <img src="doc/screenshots/timer-lockscreen.jpg" width="230" alt="실행 중인 타이머를 보여주는 잠금화면 Now Bar 카드"/> <img src="doc/screenshots/timer-shade.jpg" width="420" alt="타이머 카드가 보이는 알림 창의 실시간 정보 섹션"/></p>

## 설치

```sh
flutter pub add nowbar_flutter
```

```yaml
dependencies:
  nowbar_flutter: ^0.2.1
```

## 사용법

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

- `builder:`는 `Widget Function()`을 받으므로 클로저를 넘깁니다
  (`builder: () => ...`). 함수 리터럴은 상수가 될 수 없어 `widgets` 목록
  자체에는 `const`를 붙일 수 없습니다.
- 형상과 모션은 `NowBarMetrics`로 조절합니다(`cornerRadius`, `widgetHeight`,
  `translationClamp`, `shadowElevation`, `fillMaxWidthOffset`,
  `animationMultiplier`).

## 패키지 구성

- 드래그 방향을 설정할 수 있는, 쌓이는 카드 덱.
- 내장 데모 화면 5종: 미디어, 알림, 루틴, 스포츠, 타이머.
- 모서리 반경, 높이, 이동 클램프, 그림자, 너비 비율, 애니메이션 속도를 위한
  `NowBarMetrics`.
- 커스텀 팔레트를 위한 `seedColor`를 포함한 Material 3 테마.
- 내장 Inter 서체. 폰트 다운로드가 필요 없습니다.
- `NowBarComponent.builder`로 교체 가능한 화면.

## 링크

- API 레퍼런스: <https://pub.dev/documentation/nowbar_flutter/latest/>
- 예제 가이드: [`example/README.md`](example/README.md)
- 변경 내역: [`CHANGELOG.md`](CHANGELOG.md)
- 라이선스: [`LICENSE`](LICENSE)
- 서드파티 고지: [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)

## 크레딧

- 디자인 언어는 Jetpack Compose 프로젝트
  [`styropyr0/NowBar`](https://github.com/styropyr0/NowBar)에서 영감을
  받았습니다. 이 패키지는 독립적으로 다시 구현한 것이며, **삼성 또는 원작자와
  제휴·후원·보증 관계가 없습니다**. 원본 저장소의 코드나 아트워크를 **포함하지
  않으며**, 원작자에게 보낸 **라이선스 요청은 진행 중**입니다.
- Inter 서체: [Rasmus Andersson](https://rsms.me/inter/).

## 라이선스

MIT 라이선스로 배포됩니다. [`LICENSE`](LICENSE)를 참고하세요.
