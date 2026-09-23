/// Full-page golden for the example application.
///
/// Tagged `golden` because the pixels depend on the host's font rasterizer;
/// CI runs `flutter test --exclude-tags golden` and skips it. Regenerate the
/// image in `example/test/goldens/` from the `example/` directory with:
///
/// ```sh
/// flutter test --update-goldens --tags golden
/// ```
///
/// The viewport is a 480 x 1066.67 logical phone at a 2.25 device pixel ratio,
/// so the capture lands at 1080x2400 physical pixels — matching the 1080 px
/// wide, 2.25x density of the upstream reference screenshots.
@Tags(<String>['golden'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter_example/main.dart';

/// Key of the [RepaintBoundary] that wraps the whole example application.
const Key _boundaryKey = ValueKey<String>('example-golden-boundary');

/// Physical size of the captured surface: a 1080x2400 phone screenshot.
const Size _physicalSize = Size(1080, 2400);

/// Device pixel ratio of the captured surface.
const double _devicePixelRatio = 2.25;

/// Registers the fonts the example renders with.
///
/// `example/` has no `test/flutter_test_config.dart` of its own, and the test
/// environment replaces every family with its own test glyphs until a family
/// is loaded. The package's fonts are bundled under the
/// `packages/nowbar_flutter/` prefix because they come from a dependency, and
/// the Material icon font is bundled by `uses-material-design`.
Future<void> _loadFonts() async {
  final FontLoader inter = FontLoader('Inter');
  for (final String assetPath in const <String>[
    'packages/nowbar_flutter/assets/fonts/Inter-Regular.otf',
    'packages/nowbar_flutter/assets/fonts/Inter-SemiBold.otf',
    'packages/nowbar_flutter/assets/fonts/Inter-Bold.otf',
  ]) {
    inter.addFont(rootBundle.load(assetPath));
  }
  final FontLoader icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  final FontLoader korean = FontLoader('NotoSansKR')
    ..addFont(rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansKR-Bold.ttf'));
  await Future.wait(<Future<void>>[inter.load(), icons.load(), korean.load()]);
}

/// Decodes every [Image] currently in the tree so the capture includes the
/// embedded cover artwork rather than empty boxes.
Future<void> _precacheImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final Element element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
  });
  await tester.pump();
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('captures the example home screen at phone resolution', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = _physicalSize;
    tester.view.devicePixelRatio = _devicePixelRatio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const RepaintBoundary(key: _boundaryKey, child: NowBarExampleApp()),
    );
    await _precacheImages(tester);

    // One second in: the countdown has ticked once and every surface is at
    // rest. `pumpAndSettle` is not an option because the timer never settles.
    await tester.pump(const Duration(seconds: 1));

    final RenderRepaintBoundary boundary = tester.renderObject(
      find.byKey(_boundaryKey),
    );
    final ui.Image? image = await tester.runAsync(
      () => boundary.toImage(pixelRatio: _devicePixelRatio),
    );
    expect(image, isNotNull, reason: 'The example page must rasterize.');

    await expectLater(image, matchesGoldenFile('goldens/example_home.png'));

    await tester.pumpWidget(const SizedBox());
  });
}
