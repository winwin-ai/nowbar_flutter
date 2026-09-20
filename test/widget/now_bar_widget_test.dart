/// Engine tests for [NowBarWidget] driving real pan gestures on a fixed
/// 400x800 viewport.
///
/// The viewport makes every motion threshold deterministic: a vertical drag
/// advances at 150 logical pixels, and a horizontal drag dismisses above 200
/// logical pixels (half of 400). The bar owns the only pan recognizer under a
/// pointer, so the gesture arena accepts it as soon as it closes on
/// pointer-down: every move is dispatched to `onPanUpdate` in full, and the
/// accumulated offset always equals the sum of the moves sent by the helpers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/nowbar_flutter.dart';

/// The logical screen installed for every test.
const Size _screenSize = Size(400, 800);

/// The rendered bar size: 90% of the 400px width and the default 80px height.
const Size _barSize = Size(360, 80);

/// Horizontal dismiss threshold. Dismissal needs a strictly larger offset.
const double _halfWidth = 200;

/// Installs the deterministic viewport for the current test.
void _useFixedViewport(WidgetTester tester) {
  tester.view.physicalSize = _screenSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Creates a component that renders [label].
NowBarComponent _card(String label, {bool dismissible = true}) {
  return NowBarComponent(builder: () => Text(label), dismissible: dismissible);
}

/// Hosts [components] in a bottom-aligned bar.
Widget _harness({
  required List<NowBarComponent> components,
  NowBarMetrics metrics = const NowBarMetrics(),
  NowBarDragController dragDirection = NowBarDragController.dragUp,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: NowBarWidget(
          widgets: components,
          metrics: metrics,
          dragDirection: dragDirection,
        ),
      ),
    ),
  );
}

/// Everything rendered inside the bar, in tree order.
Finder _barDescendants(Finder matching) {
  return find.descendant(of: find.byType(NowBarWidget), matching: matching);
}

/// The label of the topmost card.
///
/// Surfaces are emitted for index count-1 down to 0, so the card on top is
/// built last and owns the last [Text] in tree order.
String? _topLabel(WidgetTester tester) {
  return tester
      .widgetList<Text>(_barDescendants(find.byType(Text)))
      .map((text) => text.data)
      .last;
}

/// The rendered translation of the surface built from [component].
Offset _translationOf(WidgetTester tester, NowBarComponent component) {
  final Transform transform = tester.widget<Transform>(
    find
        .descendant(
          of: find.byKey(ObjectKey(component)),
          matching: find.byType(Transform),
        )
        .first,
  );
  final Matrix4 matrix = transform.transform;
  return Offset(matrix.storage[12], matrix.storage[13]);
}

/// Starts a pan at the center of the bar.
///
/// The bar owns the only recognizer for the pointer, so the pan begins on
/// pointer-down and no movement is held back for slop resolution.
Future<TestGesture> _startPan(WidgetTester tester) async {
  return tester.startGesture(tester.getCenter(find.byType(NowBarWidget)));
}

/// Sends [delta] in a single move and lifts the finger.
Future<void> _pan(WidgetTester tester, Offset delta) async {
  final TestGesture gesture = await _startPan(tester);
  await gesture.moveBy(delta);
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

/// Completes an 800ms snap-back animation.
Future<void> _settleSnapBack(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pump();
}

/// Completes the 300ms overshoot leg and the fixed 200ms return leg.
///
/// An animation controller marks a simulation done only once its elapsed time
/// is strictly greater than its duration, so a leg reaches its end value one
/// frame before the awaited future resolves. The extra 1ms frame is what
/// releases the next leg (and the index change after it). The leading pump is
/// a no-op for a leg that already ticked and the first frame for one that did
/// not.
Future<void> _settleOvershoot(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();
}

/// Completes an 800ms dismiss slide-out and the removal that follows.
Future<void> _settleDismiss(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();
}

/// Drags upward past the clamp, advances one card, and settles both legs.
Future<void> _advanceUp(WidgetTester tester) async {
  await _pan(tester, const Offset(0, -300));
  await _settleOvershoot(tester);
}

/// Drags downward past the clamp, steps back one card, and settles both legs.
Future<void> _stepBackDown(WidgetTester tester) async {
  await _pan(tester, const Offset(0, 300));
  await _settleOvershoot(tester);
}

void main() {
  group('rendering', () {
    testWidgets('shows one surface per component with the first on top', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');
      final NowBarComponent c = _card('Card C');

      await tester.pumpWidget(_harness(components: <NowBarComponent>[a, b, c]));

      expect(_barDescendants(find.byType(Text)), findsNWidgets(3));
      expect(find.text('Card A'), findsOneWidget);
      expect(find.text('Card B'), findsOneWidget);
      expect(find.text('Card C'), findsOneWidget);
      expect(_topLabel(tester), 'Card A');
      expect(_translationOf(tester, a), Offset.zero);
    });

    testWidgets('sizes surfaces to 90% of the width and the metric height', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent card = _card('Card A');

      await tester.pumpWidget(_harness(components: <NowBarComponent>[card]));

      expect(tester.getSize(find.byType(NowBarWidget)), _barSize);
      expect(tester.getSize(find.byKey(ObjectKey(card))), _barSize);

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[card],
          metrics: const NowBarMetrics(widgetHeight: 64),
        ),
      );

      expect(tester.getSize(find.byType(NowBarWidget)), const Size(360, 64));
    });

    testWidgets('renders nothing for an empty list and ignores gestures', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);

      await tester.pumpWidget(
        _harness(
          components: const <NowBarComponent>[],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      expect(_barDescendants(find.byType(Text)), findsNothing);
      expect(_barDescendants(find.byType(Transform)), findsNothing);

      final TestGesture gesture = await tester.startGesture(
        const Offset(200, 400),
      );
      await gesture.moveBy(const Offset(0, -300));
      await gesture.up();
      await tester.pump();

      expect(_barDescendants(find.byType(Text)), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('axis locking', () {
    testWidgets(
      'locks to the horizontal axis and ignores later vertical moves',
      (WidgetTester tester) async {
        _useFixedViewport(tester);
        final NowBarComponent a = _card('Card A');
        final NowBarComponent b = _card('Card B');

        await tester.pumpWidget(
          _harness(
            components: <NowBarComponent>[a, b],
            dragDirection: NowBarDragController.dragVertically,
          ),
        );

        final TestGesture gesture = await _startPan(tester);
        await gesture.moveBy(const Offset(60, 10));
        await tester.pump();
        expect(_translationOf(tester, a), const Offset(60, 0));

        await gesture.moveBy(const Offset(0, -100));
        await tester.pump();
        expect(_translationOf(tester, a), const Offset(60, 0));

        await gesture.moveBy(const Offset(40, 0));
        await tester.pump();
        expect(_translationOf(tester, a), const Offset(100, 0));

        await gesture.up();
        await _settleSnapBack(tester);
        expect(_translationOf(tester, a), Offset.zero);
        expect(_topLabel(tester), 'Card A');
      },
    );

    testWidgets(
      'locks to the vertical axis and ignores later horizontal moves',
      (WidgetTester tester) async {
        _useFixedViewport(tester);
        final NowBarComponent a = _card('Card A');
        final NowBarComponent b = _card('Card B');

        await tester.pumpWidget(
          _harness(
            components: <NowBarComponent>[a, b],
            dragDirection: NowBarDragController.dragVertically,
          ),
        );

        final TestGesture gesture = await _startPan(tester);
        await gesture.moveBy(const Offset(10, 60));
        await tester.pump();
        expect(_translationOf(tester, a), const Offset(0, 60));

        await gesture.moveBy(const Offset(100, 0));
        await tester.pump();
        expect(_translationOf(tester, a), const Offset(0, 60));

        await gesture.moveBy(const Offset(0, 30));
        await tester.pump();
        expect(_translationOf(tester, a), const Offset(0, 90));

        await gesture.up();
        await _settleSnapBack(tester);
        expect(_translationOf(tester, a), Offset.zero);
        expect(_topLabel(tester), 'Card A');
      },
    );
  });

  group('vertical drags', () {
    testWidgets('snaps a short upward drag back without advancing', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      await _pan(tester, const Offset(0, -100));
      expect(_topLabel(tester), 'Card A');

      // Halfway through the 800ms return the card is still travelling.
      await tester.pump(const Duration(milliseconds: 400));
      expect(_translationOf(tester, a).dy, lessThan(0));

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(_translationOf(tester, a), Offset.zero);
      expect(_topLabel(tester), 'Card A');
    });

    testWidgets('snaps a short downward drag back without stepping back', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      await _pan(tester, const Offset(0, 100));
      expect(_topLabel(tester), 'Card A');

      await tester.pump(const Duration(milliseconds: 400));
      expect(_translationOf(tester, a).dy, greaterThan(0));

      await _settleSnapBack(tester);
      expect(_translationOf(tester, a), Offset.zero);
      expect(_topLabel(tester), 'Card A');
    });

    testWidgets('treats the 50 and 150 thresholds as exclusive', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      for (final double offset in <double>[-50, -150, 50, 150]) {
        await _pan(tester, Offset(0, offset));
        await _settleSnapBack(tester);
        expect(_translationOf(tester, a), Offset.zero);
        expect(_topLabel(tester), 'Card A');
      }
    });

    testWidgets('advances through the deck and wraps past the last card', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');
      final NowBarComponent c = _card('Card C');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b, c],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      await _advanceUp(tester);
      expect(_topLabel(tester), 'Card B');
      expect(_translationOf(tester, b), Offset.zero);

      await _advanceUp(tester);
      expect(_topLabel(tester), 'Card C');

      await _advanceUp(tester);
      expect(_topLabel(tester), 'Card A');
    });

    testWidgets('steps back through the deck and wraps to the last card', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');
      final NowBarComponent c = _card('Card C');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b, c],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      await _stepBackDown(tester);
      expect(_topLabel(tester), 'Card C');

      await _stepBackDown(tester);
      expect(_topLabel(tester), 'Card B');

      await _stepBackDown(tester);
      expect(_topLabel(tester), 'Card A');
    });

    testWidgets('overshoots to the clamp before returning and switching', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      // A drag past the threshold but short of the clamp.
      await _pan(tester, const Offset(0, -160));
      expect(_translationOf(tester, a).dy, -160);

      // The overshoot leg ends at the upper clamp...
      await tester.pump(const Duration(milliseconds: 300));
      expect(_translationOf(tester, a).dy, -200);

      // ...then the return leg is back at zero before the index changes.
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(_translationOf(tester, a), Offset.zero);
      expect(_topLabel(tester), 'Card A');

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(_topLabel(tester), 'Card B');
    });

    testWidgets(
      'saturates rendered translation at the clamp while dragging on',
      (WidgetTester tester) async {
        _useFixedViewport(tester);
        final NowBarComponent a = _card('Card A');
        final NowBarComponent b = _card('Card B');

        await tester.pumpWidget(
          _harness(
            components: <NowBarComponent>[a, b],
            dragDirection: NowBarDragController.dragVertically,
          ),
        );

        final TestGesture up = await _startPan(tester);
        await up.moveBy(const Offset(0, -300));
        await tester.pump();
        expect(_translationOf(tester, a).dy, -200);

        await up.moveBy(const Offset(0, -300));
        await tester.pump();
        expect(_translationOf(tester, a).dy, -200);

        await up.up();
        await _settleOvershoot(tester);
        expect(_topLabel(tester), 'Card B');
        expect(_translationOf(tester, b), Offset.zero);

        final TestGesture down = await _startPan(tester);
        await down.moveBy(const Offset(0, 300));
        await tester.pump();
        expect(_translationOf(tester, b).dy, 250);

        await down.moveBy(const Offset(0, 300));
        await tester.pump();
        expect(_translationOf(tester, b).dy, 250);

        await down.up();
        await _settleOvershoot(tester);
        expect(_topLabel(tester), 'Card A');
        expect(_translationOf(tester, a), Offset.zero);
      },
    );

    testWidgets('dragUp rejects a long downward drag', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(_harness(components: <NowBarComponent>[a, b]));

      await _pan(tester, const Offset(0, 200));

      // 500ms in, an allowed switch would already be on its return leg.
      await tester.pump(const Duration(milliseconds: 500));
      expect(_topLabel(tester), 'Card A');
      expect(_translationOf(tester, a).dy, greaterThan(0));

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(_topLabel(tester), 'Card A');
      expect(_translationOf(tester, a), Offset.zero);
    });

    testWidgets('dragDown rejects a long upward drag', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          dragDirection: NowBarDragController.dragDown,
        ),
      );

      await _pan(tester, const Offset(0, -200));

      await tester.pump(const Duration(milliseconds: 500));
      expect(_topLabel(tester), 'Card A');
      expect(_translationOf(tester, a).dy, lessThan(0));

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(_topLabel(tester), 'Card A');
      expect(_translationOf(tester, a), Offset.zero);
    });

    testWidgets('animationMultiplier stretches the 800ms snap-back', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          metrics: const NowBarMetrics(animationMultiplier: 2),
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      await _pan(tester, const Offset(0, -100));

      await tester.pump(const Duration(milliseconds: 800));
      expect(_translationOf(tester, a).dy, isNot(closeTo(0, 0.001)));

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(_translationOf(tester, a), Offset.zero);
      expect(_topLabel(tester), 'Card A');
    });

    testWidgets('animationMultiplier stretches the overshoot, not the return', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          metrics: const NowBarMetrics(animationMultiplier: 2),
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      await _pan(tester, const Offset(0, -300));

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(_topLabel(tester), 'Card A');

      // The overshoot runs 600ms with the multiplier; the return leg stays at
      // 200ms. An unmultiplied overshoot would switch during the frame below.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(_topLabel(tester), 'Card A');

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(_topLabel(tester), 'Card B');
    });
  });

  group('horizontal drags', () {
    testWidgets('dismisses a dismissible card dragged past half the width', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          dragDirection: NowBarDragController.dragHorizontally,
        ),
      );

      await _pan(tester, const Offset(300, 0));
      expect(_translationOf(tester, a), const Offset(300, 0));

      // Mid-flight the card is still in the deck and travelling off-screen.
      await tester.pump(const Duration(milliseconds: 400));
      expect(_translationOf(tester, a).dx, greaterThan(300));
      expect(_topLabel(tester), 'Card A');

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(find.text('Card A'), findsNothing);
      expect(_barDescendants(find.byType(Text)), findsOneWidget);
      expect(_topLabel(tester), 'Card B');
      expect(_translationOf(tester, b), Offset.zero);
    });

    testWidgets('keeps a non-dismissible card and snaps it back', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A', dismissible: false);
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          dragDirection: NowBarDragController.dragHorizontally,
        ),
      );

      await _pan(tester, const Offset(300, 0));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();

      expect(_barDescendants(find.byType(Text)), findsNWidgets(2));
      expect(find.text('Card A'), findsOneWidget);
      expect(_topLabel(tester), 'Card A');
      expect(_translationOf(tester, a), Offset.zero);
    });

    testWidgets('does not dismiss at exactly half the width', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          dragDirection: NowBarDragController.dragHorizontally,
        ),
      );

      await _pan(tester, const Offset(_halfWidth, 0));
      expect(_translationOf(tester, a).dx, _halfWidth);

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();

      expect(_barDescendants(find.byType(Text)), findsNWidgets(2));
      expect(_topLabel(tester), 'Card A');
      expect(_translationOf(tester, a), Offset.zero);
    });

    testWidgets('never dismisses on a leftward drag', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          dragDirection: NowBarDragController.dragHorizontally,
        ),
      );

      await _pan(tester, const Offset(-300, 0));
      expect(_translationOf(tester, a).dx, -300);

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();

      expect(_barDescendants(find.byType(Text)), findsNWidgets(2));
      expect(_topLabel(tester), 'Card A');
      expect(_translationOf(tester, a), Offset.zero);
    });

    testWidgets('normalizes the top index after a removal', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');
      final NowBarComponent c = _card('Card C');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b, c],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      await _advanceUp(tester);
      await _advanceUp(tester);
      expect(_topLabel(tester), 'Card C');

      await _pan(tester, const Offset(300, 0));
      await _settleDismiss(tester);

      // Removing the last entry clamps the top index back into range.
      expect(_barDescendants(find.byType(Text)), findsNWidgets(2));
      expect(find.text('Card C'), findsNothing);
      expect(_topLabel(tester), 'Card B');
    });

    testWidgets(
      'animationMultiplier leaves the horizontal snap-back at 800ms',
      (WidgetTester tester) async {
        _useFixedViewport(tester);
        final NowBarComponent a = _card('Card A');
        final NowBarComponent b = _card('Card B');

        await tester.pumpWidget(
          _harness(
            components: <NowBarComponent>[a, b],
            metrics: const NowBarMetrics(animationMultiplier: 2),
            dragDirection: NowBarDragController.dragHorizontally,
          ),
        );

        await _pan(tester, const Offset(100, 0));

        await tester.pump(const Duration(milliseconds: 800));
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pump();
        expect(_translationOf(tester, a), Offset.zero);
        expect(_barDescendants(find.byType(Text)), findsNWidgets(2));
      },
    );

    testWidgets('animationMultiplier stretches the dismiss slide-out', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          metrics: const NowBarMetrics(animationMultiplier: 2),
          dragDirection: NowBarDragController.dragHorizontally,
        ),
      );

      await _pan(tester, const Offset(300, 0));

      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('Card A'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(find.text('Card A'), findsNothing);
      expect(_topLabel(tester), 'Card B');
    });
  });

  group('physical pixels', () {
    testWidgets('scales drag deltas by the device pixel ratio', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      // 80 logical pixels of travel is 160 physical pixels: past the 150px
      // switchable threshold, while the rendered offset stays at 80 logical.
      final TestGesture gesture = await _startPan(tester);
      await gesture.moveBy(const Offset(0, -80));
      await tester.pump();
      expect(_translationOf(tester, a), const Offset(0, -80));

      await gesture.up();
      await tester.pump();
      await _settleOvershoot(tester);
      expect(_topLabel(tester), 'Card B');

      await tester.pumpWidget(const SizedBox());

      // The same logical drag at a 1.0 ratio stays below the threshold.
      tester.view.physicalSize = _screenSize;
      tester.view.devicePixelRatio = 1;

      final NowBarComponent c = _card('Card C');
      final NowBarComponent d = _card('Card D');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[c, d],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      await _pan(tester, const Offset(0, -80));
      await _settleSnapBack(tester);
      expect(_topLabel(tester), 'Card C');
    });
  });

  group('rotation safety', () {
    testWidgets('a single card wraps onto itself without crashing', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      await _advanceUp(tester);
      expect(_topLabel(tester), 'Card A');

      await _stepBackDown(tester);
      expect(_topLabel(tester), 'Card A');
      expect(tester.takeException(), isNull);
    });

    testWidgets('dismissing the only card leaves the surface empty', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a],
          dragDirection: NowBarDragController.dragHorizontally,
        ),
      );

      await _pan(tester, const Offset(300, 0));
      await _settleDismiss(tester);

      expect(_barDescendants(find.byType(Text)), findsNothing);
      expect(_barDescendants(find.byType(Transform)), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives disposal during a switch without throwing', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      await _pan(tester, const Offset(0, -300));

      // 150ms into the 300ms overshoot leg the state is unmounted; the pending
      // return leg and the index change must not touch disposed animatables.
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('re-syncs when the component list instance changes', (
      WidgetTester tester,
    ) async {
      _useFixedViewport(tester);
      final NowBarComponent a = _card('Card A');
      final NowBarComponent b = _card('Card B');
      final NowBarComponent c = _card('Card C');

      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[a, b, c],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      await _advanceUp(tester);
      await _advanceUp(tester);
      expect(_topLabel(tester), 'Card C');

      final NowBarComponent d = _card('Card D');
      final NowBarComponent e = _card('Card E');
      await tester.pumpWidget(
        _harness(
          components: <NowBarComponent>[d, e],
          dragDirection: NowBarDragController.dragVertically,
        ),
      );

      expect(_barDescendants(find.byType(Text)), findsNWidgets(2));
      expect(find.text('Card A'), findsNothing);
      expect(find.text('Card B'), findsNothing);
      expect(find.text('Card C'), findsNothing);
      // The stale top index is clamped into the new range.
      expect(_topLabel(tester), 'Card E');
    });
  });
}
