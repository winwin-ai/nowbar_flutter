/// Golden-image regression tests for the package's Now Bar surfaces.
///
/// The captures are tagged `golden` because their pixels depend on the host's
/// font rasterizer; CI runs `flutter test --exclude-tags golden` and skips
/// them. Regenerate the images in `test/goldens/` from the package root with:
///
/// ```sh
/// flutter test --update-goldens --tags golden
/// ```
///
/// Most cases install a 400x800 logical viewport at a 1.0 device pixel ratio,
/// so each golden is a deterministic, logical-resolution image. The deck's
/// second mid-drag case uses a 2.25 device pixel ratio to pin the conversion
/// from the physical-pixel drag offsets to logical rendering. The deck cases
/// reuse the pan helpers from `now_bar_widget_test.dart`: the bar owns the
/// only pan recognizer under a pointer, so the pan is accepted on pointer-down
/// and every move is delivered in full.
@Tags(<String>['golden'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/nowbar_flutter.dart';

/// Key of the [RepaintBoundary] captured by every case.
const Key _boundaryKey = ValueKey<String>('golden-boundary');

/// Logical size of a Now Bar slot on a 400 logical pixel wide screen.
const Size _slotSize = Size(360, 80);

/// The deterministic viewport installed for every case.
const Size _screenSize = Size(400, 800);

/// 32 x 32 indigo-to-violet gradient, locally generated and embedded so the
/// media surface has real cover artwork without any bundled third-party asset.
const String _coverVioletPng =
    'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAABOUlEQVR42rXMCUeDAQAG4PevJCnd'
    '10x3zczMrDIz61yttVat1Vpr5rO2Ws1nbbXWacp0mSkSiUQiEomMSCQSiUgkEvUr3ucHPMjLMBZk'
    'moqyzCXZfWU5/ZJcmzTfXlnoqC4eqy0dry/3yCSCXDqhqPArqwKqmhl1nahpmG2SRbTyqE4R0yuX'
    'DarVVnW8XbPR2Zjoat4yaXfMuqRFn7Ia9gdbDkDdh9oOQd2HO45A3R3GY1B3Z/cJqLur5xTU3d17'
    'BurusZyDugvWC1B378AlqLvPdgXqPmm/BnUPjNyAugdHb0HdRWca1D3kugN1D7vvQd3nPA+g7lHh'
    'EdQ95n0CdV/yPYO6r/hfQN3Xpl5B3ePTb6Du68F3UPeE+AHqvhn6BHXfDn+Buu9GvkHdk/M/oO6p'
    'hV9Q973Fv38TD9ZcOeUQwAAAAABJRU5ErkJggg==';

/// 32 x 32 plum-to-amber gradient, locally generated and embedded so the
/// media surface has real cover artwork without any bundled third-party asset.
const String _coverAmberPng =
    'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAABNUlEQVR42rXMbUcDAQAH8P8nSSS9'
    'SBLZTte22kPXrtvzbtfdzphKmSmVZSplplSmJ2XKVKYyZUQiIhIRSUQiIhKJRPS6T/H/fYAf5BqL'
    'r9YarLOG6wW1QdAb28wmMdEsJlva+1ttgxZbSrCnRfuIzTHm6JhwdWY9zinJOSO7coo773fPBz2L'
    'EU9B7VrRpDVD2jC7iwnvdtJb6pN3B+TyUA+o+0FKAXWvpBVQ96NhH6h7ddQH6n4y7gd1P80EQN3P'
    'sgFQ9/PJIKj7xXQI1P1yNgTqfpULg7pf58Og7jdzEVD324UoqPvdUhTU/b6ggro/LEdB3R9XVVD3'
    'p/UYqPvzZgzU/aWogbq/bmmg7m+lXlD39x0d1P1jTwd1/ywboO5f+wao+/ehAer+U4mDuv8ex0Hd'
    '/6rmPzXtTzLm29QdAAAAAElFTkSuQmCC';

/// Decoded violet cover, created once so the image cache key stays stable.
final MemoryImage _coverViolet = MemoryImage(base64Decode(_coverVioletPng));

/// Decoded amber cover, created once so the image cache key stays stable.
final MemoryImage _coverAmber = MemoryImage(base64Decode(_coverAmberPng));

/// Installs the fixed viewport that makes every capture deterministic.
void _useFixedViewport(WidgetTester tester) {
  tester.view.physicalSize = _screenSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Hosts one demo surface in the chrome the real app gives it: a dark Now Bar
/// theme over a black scaffold, inside a keyed [RepaintBoundary] that bounds
/// the capture to the 360x80 slot.
Widget _slot(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: NowBarTheme.buildThemeData(dark: true),
    home: NowBarTheme.dark(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: RepaintBoundary(
            key: _boundaryKey,
            child: SizedBox.fromSize(size: _slotSize, child: child),
          ),
        ),
      ),
    ),
  );
}

/// Hosts the deck on a full-screen dark scaffold and captures the whole page.
Widget _deck({
  required List<NowBarComponent> components,
  NowBarDragController dragDirection = NowBarDragController.dragVertically,
}) {
  return RepaintBoundary(
    key: _boundaryKey,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: NowBarTheme.buildThemeData(dark: true),
      home: NowBarTheme.dark(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: NowBarWidget(
              innerPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              dragDirection: dragDirection,
              widgets: components,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The shared three-card deck used by every drag-state capture.
///
/// The bar gives its children the full surface, so each label is centered to
/// clear the 50 logical pixel corner radius.
List<NowBarComponent> _deckCards() => <NowBarComponent>[
  NowBarComponent(builder: () => const Center(child: Text('Card A'))),
  NowBarComponent(builder: () => const Center(child: Text('Card B'))),
  NowBarComponent(builder: () => const Center(child: Text('Card C'))),
];

/// Starts a pan at the center of the deck.
///
/// The bar owns the only recognizer for the pointer, so the pan begins on
/// pointer-down and no movement is held back for slop resolution.
Future<TestGesture> _startPan(WidgetTester tester) {
  return tester.startGesture(tester.getCenter(find.byType(NowBarWidget)));
}

/// Captures the keyed boundary as `test/goldens/<name>.png`.
///
/// Golden keys resolve against this test file's directory, so `../goldens/`
/// lands in the package-level `test/goldens/` folder.
Future<void> _capture(WidgetTester tester, String name) {
  return expectLater(
    find.byKey(_boundaryKey),
    matchesGoldenFile('../goldens/$name.png'),
  );
}

/// Decodes every [Image] currently in the tree so captures include artwork
/// rather than an empty box.
Future<void> _precacheImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final Element element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
  });
  await tester.pump();
}

/// Locates the Flutter SDK's copy of the Material icon font.
///
/// The package does not enable `uses-material-design`, so the icon font is not
/// part of its test asset bundle. Goldens are local-only (tagged and excluded
/// from CI), so resolving the font from the SDK cache is enough. The walk
/// starts at `flutter_tester`, which lives at
/// `<flutter>/bin/cache/artifacts/engine/<platform>/`, and climbs to the SDK
/// root; `null` means the goldens fall back to the test glyphs.
File? _materialIconFont() {
  Directory directory = File(Platform.resolvedExecutable).parent;
  while (true) {
    final File candidate = File(
      '${directory.path}/bin/cache/artifacts/material_fonts/'
      'MaterialIcons-Regular.otf',
    );
    if (candidate.existsSync()) {
      return candidate;
    }
    final Directory parent = directory.parent;
    if (parent.path == directory.path) {
      return null;
    }
    directory = parent;
  }
}

/// Registers the Material icon font with the test font collection.
Future<void> _loadMaterialIcons() async {
  final File? font = _materialIconFont();
  if (font == null) {
    return;
  }
  final FontLoader loader = FontLoader('MaterialIcons');
  loader.addFont(
    font.readAsBytes().then((Uint8List bytes) => ByteData.sublistView(bytes)),
  );
  await loader.load();
}

void main() {
  setUpAll(_loadMaterialIcons);

  testWidgets('renders the media player surface', (WidgetTester tester) async {
    _useFixedViewport(tester);

    await tester.pumpWidget(
      _slot(
        MediaPlayerWidget(
          tracks: <MediaPlayerTrack>[
            MediaPlayerTrack(
              image: _coverViolet,
              title: 'Midnight Drive',
              artist: 'Neon Atlas',
            ),
            MediaPlayerTrack(
              image: _coverAmber,
              title: 'Golden Hour',
              artist: 'Wanderlight',
            ),
          ],
        ),
      ),
    );
    await _precacheImages(tester);

    await _capture(tester, 'media_player');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renders the notification surface with its solid color', (
    WidgetTester tester,
  ) async {
    _useFixedViewport(tester);

    await tester.pumpWidget(
      _slot(
        const NotificationWidget(
          icon: Icon(Icons.notifications),
          title: 'Order shipped',
          content: 'Your package is on the way',
        ),
      ),
    );

    await _capture(tester, 'notification_solid');
  });

  testWidgets('renders the notification surface with a diagonal gradient', (
    WidgetTester tester,
  ) async {
    _useFixedViewport(tester);

    await tester.pumpWidget(
      _slot(
        const NotificationWidget(
          icon: Icon(Icons.notifications),
          title: 'Order shipped',
          content: 'Your package is on the way',
          colorController: NotificationColorController(
            backgroundColorGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF0A66C2), Color(0xFFB3D5FA)],
            ),
          ),
        ),
      ),
    );

    await _capture(tester, 'notification_gradient');
  });

  testWidgets('renders the routines surface', (WidgetTester tester) async {
    _useFixedViewport(tester);

    await tester.pumpWidget(
      _slot(const RoutinesWidget(content: 'At work and 2 others running')),
    );

    await _capture(tester, 'routines');
  });

  testWidgets('renders the sports surface with a two-line title', (
    WidgetTester tester,
  ) async {
    _useFixedViewport(tester);

    await tester.pumpWidget(
      _slot(
        const SportsWidget(
          title: 'ICC Champions Trophy 2025 (Final)\nIND vs NZ',
          content: 'IND won by 4 wickets',
        ),
      ),
    );

    await _capture(tester, 'sports');
  });

  testWidgets('renders the timer surface at its initial state', (
    WidgetTester tester,
  ) async {
    _useFixedViewport(tester);

    await tester.pumpWidget(_slot(const TimerWidget(seconds: 65)));

    // No clock advance: the capture is the state directly after first paint.
    await _capture(tester, 'timer_running');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renders the deck at rest', (WidgetTester tester) async {
    _useFixedViewport(tester);

    await tester.pumpWidget(_deck(components: _deckCards()));

    await _capture(tester, 'now_bar_collapsed');
  });

  testWidgets('renders the deck while a vertical drag is held', (
    WidgetTester tester,
  ) async {
    _useFixedViewport(tester);

    await tester.pumpWidget(_deck(components: _deckCards()));

    final TestGesture gesture = await _startPan(tester);
    await gesture.moveBy(const Offset(0, -20));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();

    // Captured mid-gesture, before the finger lifts at -100 logical pixels.
    await _capture(tester, 'now_bar_mid_drag');

    await gesture.up();
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renders the deck mid-drag at a 2.25 device pixel ratio', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.25;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_deck(components: _deckCards()));

    final TestGesture gesture = await _startPan(tester);
    await gesture.moveBy(const Offset(0, -20));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();

    // The same logical drag accumulates 2.25x the physical offset, so this
    // capture pins the px-to-logical conversion in the deck's peek bands.
    await _capture(tester, 'now_bar_mid_drag_dpr2_25');

    await gesture.up();
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renders the deck after dismissing the top card', (
    WidgetTester tester,
  ) async {
    _useFixedViewport(tester);

    await tester.pumpWidget(
      _deck(
        components: _deckCards(),
        dragDirection: NowBarDragController.dragHorizontally,
      ),
    );

    final TestGesture gesture = await _startPan(tester);
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(280, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    // Complete the 800ms slide-out and the removal that follows.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    await _capture(tester, 'now_bar_after_dismiss');

    await tester.pumpWidget(const SizedBox());
  });
}
