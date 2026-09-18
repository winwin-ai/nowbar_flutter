[English](README.md) | 한국어

# nowbar_flutter

삼성 Now Bar를 순수 Dart로 다시 구현한 Flutter 패키지입니다. 앱 하단에
고정되는, 드래그 가능한 카드 덱 형태로 미디어·알림·루틴·스포츠·타이머
화면을 쌓아 올려 보여줍니다.

> **영감을 준 프로젝트:** Jetpack Compose 프로젝트
> [`styropyr0/NowBar`](https://github.com/styropyr0/NowBar). 이 패키지는 해당
> 디자인을 독립적으로 클린룸 포팅한 Dart 구현입니다. **삼성 또는 원작자와
> 제휴·후원·보증 관계가 없으며**, 원본 저장소의 코드나 아트워크를 포함하지
> 않습니다.

[![CI](https://github.com/winwin-ai/nowbar_flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/winwin-ai/nowbar_flutter/actions/workflows/ci.yml)
<!-- [![pub package](https://img.shields.io/pub/v/nowbar_flutter.svg)](https://pub.dev/packages/nowbar_flutter) -->
<!-- pub.dev 배지는 아직 게시 전이라 보류 중 -->

> **상태: 프리릴리스(0.1.0).** 아직 pub.dev에 게시되지 않았습니다. 아래 공개
> API는 첫 릴리스를 기준으로 확정되었습니다. 내장 위젯은 실제 시스템 연동이
> 아니라 데모용 화면입니다(자세한 내용은
> [범위](#범위-이-패키지는-ui-재현입니다) 참고).

<!-- TODO: pub.dev 첫 릴리스 전에 스크린샷 추가 -->

## 범위 (이 패키지는 UI 재현입니다)

`nowbar_flutter`는 Now Bar의 *겉모습과 움직임*을 재현합니다. 표현 계층만
담당합니다.

- 실제 미디어 재생, 백그라운드 오디오, 플랫폼 미디어 세션은 없습니다.
- 시스템 알림, Android/iOS 알림 API와 연동하지 않습니다.
- 백그라운드 실행, 위치 정보, 건강/피트니스 데이터 접근이 없습니다.

내장된 5개 위젯은 전달받은 값을 그대로 그리는 데모 화면입니다. 실제 상태,
컨트롤러, 플랫폼 서비스 연결은 사용하는 쪽에서 처리하세요.

## 기능

- **드래그 가능한 카드 덱.** 하단에 고정된 화면 위에서 컴포넌트가 순환하며,
  드래그 방향을 설정할 수 있습니다.
- **내장 데모 위젯 5종:** 미디어 플레이어, 알림, 루틴, 스포츠, 타이머.
- **순수 Dart, 네이티브 코드 없음.** 플랫폼 채널·플러그인·`MethodChannel`이
  없어 Android, iOS, 데스크톱, 웹에서 모두 동작합니다.
- **레이아웃 전면 제어.** 불변 `NowBarMetrics`로 모서리 반경, 높이, 이동
  클램프, 그림자, 너비 비율, 애니메이션 속도를 조절합니다.
- **테마 지원.** 원본 디자인에서 포팅한 Material 3 색상 스킴과 `seedColor`
  기반 커스텀 팔레트를 라이트/다크 모두 제공합니다.
- **Inter 서체 내장**(Regular 400, SemiBold 600, Bold 700). 폰트 다운로드가
  필요 없습니다.
- **교체 가능한 컴포넌트 화면.** `NowBarComponent.builder`에 원하는 위젯을
  넣을 수 있습니다.

## 요구 사항

| 항목 | 버전 |
| --- | --- |
| Flutter | `>= 3.44.0` |
| Dart SDK | `^3.12.0` |
| 지원 플랫폼 | Android, iOS, macOS, Linux, Windows, 웹 |

순수 Dart 패키지입니다. 플랫폼 플러그인을 선언하지 않고 네이티브 코드를
호출하지 않으므로, 별도 설정 없이 모든 Flutter 타깃에서 빌드됩니다.

## 설치

pub.dev 게시 후에는 다음 한 줄이면 됩니다.

```sh
flutter pub add nowbar_flutter
```

`pubspec.yaml`에 직접 추가해도 됩니다.

```yaml
dependencies:
  nowbar_flutter: ^0.1.0
```

첫 릴리스 전에는 저장소를 직접 참조하세요.

```yaml
# 로컬 체크아웃 경로 의존성
dependencies:
  nowbar_flutter:
    path: ../nowbar_flutter
```

```yaml
# Git 의존성
dependencies:
  nowbar_flutter:
    git:
      url: https://github.com/winwin-ai/nowbar_flutter.git
      ref: main
```

저장소는 현재 비공개이며, Git 의존성은 저장소가 공개되어 자격 증명으로 접근
가능해진 뒤를 전제로 합니다.

## 빠른 시작

아래 코드는 그대로 실행 가능한 완전한 예제입니다. Now Bar 테마를 설치하고,
화면 하단에 바를 배치한 뒤 컴포넌트 3개를 등록합니다.

```dart
import 'package:flutter/material.dart';
import 'package:nowbar_flutter/nowbar_flutter.dart';

void main() => runApp(const NowBarExampleApp());

class NowBarExampleApp extends StatelessWidget {
  const NowBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Now Bar Demo',
      debugShowCheckedModeBanner: false,
      home: NowBarTheme(
        darkTheme: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: NowBarWidget(
                innerPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                dragDirection: NowBarDragController.dragVertically,
                metrics: const NowBarMetrics(
                  cornerRadius: 32,
                  widgetHeight: 88,
                ),
                widgets: [
                  NowBarComponent(
                    builder: () => MediaPlayerWidget(
                      tracks: [
                        MediaPlayerTrack(
                          image: const NetworkImage(
                            'https://picsum.photos/seed/nowbar/200',
                          ),
                          title: 'Midnight City',
                          artist: 'M83',
                        ),
                      ],
                    ),
                  ),
                  NowBarComponent(
                    builder: () => const NotificationWidget(
                      icon: Icon(NowBarIcons.check),
                      title: 'Order shipped',
                      content: 'Your package is on the way',
                    ),
                  ),
                  NowBarComponent(
                    builder: () => const RoutinesWidget(content: 'Run 5 km'),
                    dismissible: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

참고:

- `NowBarComponent`는 `Widget Function()`을 받으므로 클로저를 넘깁니다
  (`builder: () => ...`). 함수 리터럴은 상수가 될 수 없어 `widgets` 목록
  자체에는 `const`를 붙일 수 없습니다.
- `NetworkImage` 자리에는 원하는 아트워크에 맞춰 `AssetImage`, `FileImage`
  등 아무 `ImageProvider`나 넣으면 됩니다.

## API 레퍼런스

아래 타입은 모두 `package:nowbar_flutter/nowbar_flutter.dart`에서
내보냅니다.

### `NowBarWidget`

활성 컴포넌트를 담고 순환시키는 루트 화면입니다.

```dart
NowBarWidget({
  Key? key,
  EdgeInsets innerPadding = EdgeInsets.zero,
  required List<NowBarComponent> widgets,
  NowBarMetrics metrics = const NowBarMetrics(),
  NowBarDragController dragDirection = NowBarDragController.dragUp,
})
```

| 매개변수 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `innerPadding` | `EdgeInsets` | `EdgeInsets.zero` | 바 화면 안쪽에 적용할 패딩. |
| `widgets` | `List<NowBarComponent>` | 필수 | 표시 순서대로 나열한 컴포넌트 목록. |
| `metrics` | `NowBarMetrics` | `const NowBarMetrics()` | 레이아웃과 모션 지표. |
| `dragDirection` | `NowBarDragController` | `NowBarDragController.dragUp` | 화면이 반응할 제스처 방향. |

### `NowBarComponent`

순환 목록의 한 항목입니다. 화면 내용을 만드는 빌더와 닫기 가능 여부를
가집니다.

```dart
NowBarComponent({
  required Widget Function() builder,
  bool dismissible = true,
})
```

| 매개변수 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `builder` | `Widget Function()` | 필수 | 이 컴포넌트가 활성일 때 표시할 위젯을 만듭니다. |
| `dismissible` | `bool` | `true` | 스와이프로 순환 목록에서 제거할 수 있는지 여부. |

동등성은 객체 아이덴티티를 기준으로 합니다. 각 컴포넌트가 고유한 빌더를
가지므로 순환·해제 시 아이덴티티로 추적합니다.

### `NowBarMetrics`

불변 레이아웃·애니메이션 지표입니다. 모든 필드의 기본값은 원본 디자인
값입니다.

```dart
const NowBarMetrics({
  double cornerRadius = 50,
  double widgetHeight = 80,
  (double, double) translationClamp = (-200, 250),
  double shadowElevation = 12,
  double fillMaxWidthOffset = 0.9,
  int animationMultiplier = 1,
})
```

| 필드 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `cornerRadius` | `double` | `50` | 바 화면의 모서리 반경(논리 픽셀). |
| `widgetHeight` | `double` | `80` | 화면 한 개의 높이(논리 픽셀). |
| `translationClamp` | `(double, double)` | `(-200, 250)` | 세로 드래그 이동의 하한·상한. 첫 값은 위쪽 이동, 둘째 값은 아래쪽 이동을 제한합니다. |
| `shadowElevation` | `double` | `12` | 바가 드리우는 그림자의 높이(논리 픽셀). |
| `fillMaxWidthOffset` | `double` | `0.9` | 최대 확장 시 바가 차지하는 가용 너비 비율. |
| `animationMultiplier` | `int` | `1` | 애니메이션 시간에 곱하는 값. `1`보다 크면 느려지고 작으면 빨라집니다. |

원본을 바꾸지 않고 변형을 만들려면 `copyWith`를 사용하세요.

```dart
const base = NowBarMetrics();
final compact = base.copyWith(widgetHeight: 64, cornerRadius: 24);
```

### `NowBarDragController`

화면이 반응하는 제스처 방향입니다.

| 값 | 설명 |
| --- | --- |
| `dragUp` | 위로 드래그할 때만 다음 컴포넌트로 넘어갑니다. |
| `dragDown` | 아래로 드래그할 때만 이전 컴포넌트로 돌아갑니다. |
| `dragVertically` | 위·아래 드래그로 컴포넌트를 넘나듭니다. |
| `dragHorizontally` | 가로 드래그로 활성 컴포넌트를 닫습니다. |

### `NotificationColorController`

알림 화면의 불변 팔레트입니다. 배경(단색 또는 그라디언트), 아이콘, 제목,
본문 색을 담습니다. 이름과 달리 살아 있는 컨트롤러가 아니라 값 객체입니다.
변형은 `copyWith`로 만드세요.

```dart
const NotificationColorController({
  Color backgroundColor = Color(0xFF303164),
  Gradient? backgroundColorGradient,
  Color iconColor = Colors.white,
  Color titleColor = Colors.white,
  Color contentColor = Colors.white,
})
```

| 필드 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `backgroundColor` | `Color` | `Color(0xFF303164)` | `backgroundColorGradient`가 `null`일 때 쓰는 단색 배경. |
| `backgroundColorGradient` | `Gradient?` | `null` | 선택 그라디언트. 설정하면 `backgroundColor`보다 우선합니다. |
| `iconColor` | `Color` | `Colors.white` | 앞쪽 아이콘 색. |
| `titleColor` | `Color` | `Colors.white` | 제목 색. |
| `contentColor` | `Color` | `Colors.white` | 본문 색. |

### `NowBarTheme`

`child`를 Now Bar 색상 스킴과 타이포그래피로 구성한 Material 테마로 감쌉니다.
하위 위젯은 `Theme.of(context)`로 색과 텍스트 스타일을 읽을 수 있습니다.

```dart
const NowBarTheme({
  Key? key,
  required Widget child,
  bool darkTheme = false,
  Color? seedColor,
})
```

| 매개변수 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `child` | `Widget` | 필수 | 테마를 적용할 하위 트리. |
| `darkTheme` | `bool` | `false` | 다크 스킴 선택. `false`면 라이트 스킴. |
| `seedColor` | `Color?` | `null` | 이 색으로 커스텀 Material 3 스킴을 생성합니다. `null`이면 포팅된 Now Bar 팔레트를 사용합니다. |

명명 생성자:

| 생성자 | 설명 |
| --- | --- |
| `NowBarTheme.light({...})` | 항상 라이트 스킴을 사용합니다. |
| `NowBarTheme.dark({...})` | 항상 다크 스킴을 사용합니다. |

정적 빌더:

```dart
static ThemeData buildThemeData({bool dark = false, Color? seedColor})
```

`buildThemeData`는 래퍼가 적용하는 `ThemeData`를 반환합니다. 정적 멤버가
상속받은 인스턴스 `build` 메서드와 같은 이름을 가질 수 없다는 Dart 규칙
때문에 `build` 대신 이 이름을 씁니다. 직접 만든 `MaterialApp`에 테마를
합성할 때 사용하세요.

```dart
MaterialApp(
  theme: NowBarTheme.buildThemeData(),
  darkTheme: NowBarTheme.buildThemeData(dark: true),
  home: const HomePage(),
)
```

### `NowBarColors`

Now Bar 화면에 쓰이는 색상 시드와 Material 3 색상 스킴 두 가지입니다.

| 멤버 | 타입 | 값 |
| --- | --- | --- |
| `purple80` | `Color` | `Color(0xFFD0BCFF)` |
| `purpleGrey80` | `Color` | `Color(0xFFCCC2DC)` |
| `pink80` | `Color` | `Color(0xFFEFB8C8)` |
| `purple40` | `Color` | `Color(0xFF6650A4)` |
| `purpleGrey40` | `Color` | `Color(0xFF625B71)` |
| `pink40` | `Color` | `Color(0xFF7D5260)` |
| `lightColorScheme` | `ColorScheme` | 원본의 `primary`/`secondary`/`tertiary` 시드를 고정한 Material 3 라이트 스킴. |
| `darkColorScheme` | `ColorScheme` | 원본 시드를 고정한 Material 3 다크 스킴. |

원본 테마의 Android 12+ 다이내믹 컬러는 의도적으로 제외했습니다. 배경화면에서
색을 끌어오는 기능은 Flutter에 이식 가능한 대응물이 없어, 위 스킴은 모든
플랫폼에서 동일하게 동작합니다.

### `NowBarTypography`

Now Bar 화면의 타이포그래피입니다. 재정의한 세 스타일은 원본 지표를 그대로
유지하며, 원본의 절대 행간을 Flutter의 `TextStyle.height`(배수)로 환산합니다.

| 멤버 | 타입 | 설명 |
| --- | --- | --- |
| `fontFamily` | `const String` | 내장 패밀리 이름 `'Inter'`. |
| `bodyLarge` | `TextStyle` | Inter Regular, 16px, 24px 줄 높이, 자간 `0.5`. |
| `titleLarge` | `TextStyle` | Inter Bold, 22px, 28px 줄 높이, 자간 없음. |
| `labelSmall` | `TextStyle` | Inter SemiBold, 11px, 16px 줄 높이, 자간 `0.5`. |
| `textTheme` | `TextTheme` | Inter를 적용하고 위 세 스타일을 재정의한 전체 Material 3 텍스트 테마. |

### `NowBarIcons`

가장 가까운 Material 아이콘에 연결한 중립 아이콘 모음입니다. 브랜드
아트워크는 포함하지 않습니다.

| 멤버 | `IconData` |
| --- | --- |
| `play` | `Icons.play_arrow` |
| `pause` | `Icons.pause` |
| `skipNext` | `Icons.skip_next` |
| `skipPrevious` | `Icons.skip_previous` |
| `restart` | `Icons.replay` |
| `timer` | `Icons.timer` |
| `check` | `Icons.check` |
| `share` | `Icons.share` |

## 내장 위젯

각 위젯은 데모 화면입니다. `NowBarComponent.builder` 안에 넣고 데이터를 직접
전달하세요.

### `MediaPlayerWidget`

트랙과 재생 컨트롤을 보여줍니다.

```dart
const MediaPlayerWidget({
  Key? key,
  required List<MediaPlayerTrack> tracks,
  EdgeInsets innerPadding = EdgeInsets.zero,
})
```

| 매개변수 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `tracks` | `List<MediaPlayerTrack>` | 필수 | 표시할 트랙 목록. |
| `innerPadding` | `EdgeInsets` | `EdgeInsets.zero` | 화면 안쪽 패딩. |

#### `MediaPlayerTrack`

```dart
const MediaPlayerTrack({
  required ImageProvider image,
  required String title,
  required String artist,
})
```

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `image` | `ImageProvider` | 커버 아트워크. 아무 `ImageProvider`나 가능합니다(`AssetImage`, `NetworkImage`, `FileImage` 등). |
| `title` | `String` | 트랙 제목. |
| `artist` | `String` | 아티스트. |

### `NotificationWidget`

진행 중이거나 최근의 알림을 보여줍니다.

```dart
const NotificationWidget({
  Key? key,
  required Widget icon,
  required String title,
  required String content,
  NotificationColorController colorController =
      const NotificationColorController(),
})
```

| 매개변수 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `icon` | `Widget` | 필수 | 앞쪽 아이콘. 보통 `Icon`을 씁니다. |
| `title` | `String` | 필수 | 알림 제목. |
| `content` | `String` | 필수 | 알림 본문. |
| `colorController` | `NotificationColorController` | `const NotificationColorController()` | 화면 색과 선택 그라디언트. |

### `RoutinesWidget`

운동 루틴이나 활동 세션을 보여줍니다.

```dart
const RoutinesWidget({
  Key? key,
  String title = 'Routines',
  required String content,
})
```

| 매개변수 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `title` | `String` | `'Routines'` | 제목 텍스트. |
| `content` | `String` | 필수 | 루틴 설명 또는 진행 상황 텍스트. |

### `SportsWidget`

실시간 스포츠 점수를 보여줍니다.

```dart
const SportsWidget({
  Key? key,
  required String title,
  required String content,
  ImageProvider? backgroundImage,
  Widget? leading,
  Widget? trailing,
})
```

| 매개변수 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `title` | `String` | 필수 | 경기·이벤트 제목. |
| `content` | `String` | 필수 | 점수 또는 상태 텍스트. |
| `backgroundImage` | `ImageProvider?` | `null` | 선택 배경 아트워크. |
| `leading` | `Widget?` | `null` | 팀 엠블럼 등 선택 앞쪽 위젯. |
| `trailing` | `Widget?` | `null` | 액션 등 선택 뒤쪽 위젯. |

### `TimerWidget`

카운트다운 타이머나 스톱워치를 보여줍니다.

```dart
const TimerWidget({
  Key? key,
  required int seconds,
})
```

| 매개변수 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `seconds` | `int` | 필수 | 남은 시간 또는 경과 시간(초). |

## 커스터마이징

### 지표(Metrics)

`NowBarMetrics`가 형상과 모션을 제어합니다. 필요한 값만 `copyWith`로
바꾸거나, 전체를 새로 만들 수 있습니다.

```dart
const NowBarMetrics(
  cornerRadius: 24,          // 더 둥글거나 각진 화면
  widgetHeight: 72,          // 더 높거나 낮은 바
  translationClamp: (-120, 180), // 바가 움직일 수 있는 범위 제한
  shadowElevation: 8,        // 옅은 그림자
  fillMaxWidthOffset: 0.85,  // 가용 너비 비율
  animationMultiplier: 2,    // 더 느리고 신중한 움직임
)
```

| 조절값 | 효과 |
| --- | --- |
| `cornerRadius` | 화면 모서리의 둥글기. |
| `widgetHeight` | 화면 높이. |
| `translationClamp` | 드래그 이동의 `(하한, 상한)`. 첫 값은 위쪽, 둘째 값은 아래쪽 이동을 제한합니다. |
| `shadowElevation` | 그림자 깊이. |
| `fillMaxWidthOffset` | 가용 공간 대비 너비 비율(예: `0.9` = 90%). |
| `animationMultiplier` | 전역 애니메이션 속도. `> 1`이면 느려지고 `< 1`이면 빨라집니다. |

### 드래그 방향

UX에 맞는 제스처 축을 고르세요.

```dart
NowBarWidget(
  dragDirection: NowBarDragController.dragVertically,
  widgets: [...],
)
```

`dragVertically`로 순환 목록을 넘겨 보고, `dismissible`이 `true`인
컴포넌트에는 `dragHorizontally`로 스와이프 닫기를 활성화할 수 있습니다.

### 알림 색상과 그라디언트

```dart
const NotificationWidget(
  icon: Icon(NowBarIcons.check),
  title: 'Delivered',
  content: 'Left at the front door',
  colorController: NotificationColorController(
    backgroundColorGradient: LinearGradient(
      colors: [Color(0xFF6A5AE0), Color(0xFF303164)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    iconColor: Colors.amber,
    titleColor: Colors.white,
    contentColor: Colors.white70,
  ),
)
```

`backgroundColorGradient`가 설정되면 `backgroundColor`보다 우선합니다.
`copyWith`는 그라디언트를 생략한 경우와 `null`을 넘긴 경우를 구분할 수
없으므로, 그라디언트를 지울 때는 생성자를 사용하세요.

### 테마와 시드 색상

Now Bar 콘텐츠를 그리는 하위 트리를 감싸 주세요. 포팅된 팔레트를 그대로
쓰거나, 색 하나로 커스텀 Material 3 스킴을 생성할 수 있습니다.

```dart
MaterialApp(
  home: NowBarTheme(
    darkTheme: true,
    seedColor: const Color(0xFF00BFA5),
    child: const HomePage(),
  ),
)
```

`seedColor`를 빼면 포팅된 Now Bar 팔레트를 유지합니다. `darkTheme`를 빼거나
`NowBarTheme.light`를 쓰면 라이트 스킴이 됩니다. `NowBarTheme`는 `child`를
`Theme`로 감싸므로 `MaterialApp` *아래*에 두세요. `MaterialApp` 위에 두면
앱 자체 테마에 가려집니다. 앱 전체에 테마를 적용하려면 대신
`NowBarTheme.buildThemeData()` 결과를 `theme`/`darkTheme`에 넘기세요.

## 플랫폼 참고

- **블러(Blur).** 블러 효과는 `ImageFiltered`로 구현합니다. 웹에서는
  CanvasKit 또는 skwasm 렌더러가 필요하며, 구형 HTML 렌더러는 지원하지
  않습니다. 웹을 제외한 모든 타깃에서는 별도 설정 없이 동작합니다.
- **그 외 기능은 렌더러와 무관합니다.** 레이아웃, 애니메이션, 드래그,
  그라디언트, 그림자, 내장 Inter 폰트는 Android, iOS, macOS, Linux,
  Windows, 웹에서 동일하게 렌더링됩니다.
- **플랫폼 채널이 없습니다.** `AndroidManifest`, `Info.plist`, 데스크톱
  러너에 설정할 것이 없습니다.

## 예제 앱

실행 가능한 앱이 [`example/`](example)에 있습니다. 패키지를 경로로
참조하므로 체크아웃에서 실행하세요.

```sh
cd example
flutter run
```

## 테스트

저장소 루트에서 패키지 테스트를 실행합니다.

```sh
flutter test
```

테스트는 `FontLoader`로 내장 Inter 폰트를 불러오므로, 기기나 에뮬레이터
없이 타이포그래피 변경까지 검증합니다.

## 기여

이슈와 풀 리퀘스트는
[GitHub](https://github.com/winwin-ai/nowbar_flutter)에서 환영합니다. PR을
열기 전에 확인하세요.

1. `dart format .`, `flutter analyze`, `flutter test`를 실행해 모두
   통과하는지 확인합니다.
2. 변경 범위를 좁게 유지하고, 동작 변경에는 테스트를 추가합니다.
3. 기존 코드 스타일과 공개 API 이름 규칙을 따릅니다.

## 라이선스

MIT 라이선스로 배포됩니다. [`LICENSE`](LICENSE)를 참고하세요.

## 서드파티 고지

이 패키지는 **Inter** 서체(Regular 400, SemiBold 600, Bold 700)를
<https://github.com/rsms/inter>에서 가져와 포함하며, **SIL Open Font
License, Version 1.1**을 따릅니다. 폰트 파일은 수정 없이 배포하며, 예약
폰트 이름 "Inter"는 수정되지 않은 원본 폰트를 가리키는 용도로만 씁니다.
전체 라이선스 전문은
[`assets/fonts/OFL.txt`](assets/fonts/OFL.txt)에 포함되어 있습니다. 자세한
내용은 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)를 참고하세요.

## 크레딧

- 디자인 언어는 Jetpack Compose 프로젝트
  [`styropyr0/NowBar`](https://github.com/styropyr0/NowBar)에서 영감을
  받았습니다.
- Inter 서체: [Rasmus Andersson](https://rsms.me/inter/).
- [Flutter](https://flutter.dev)로 제작했습니다.
