import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/src/internal/animatable_value.dart';

void main() {
  group('AnimatableValue', () {
    testWidgets('starts at the requested initial value', (tester) async {
      final value = AnimatableValue(vsync: const TestVSync(), initialValue: 42);
      addTearDown(value.dispose);

      expect(value.value, 42.0);
      expect(value.isAnimating, isFalse);
    });

    testWidgets('defaults to zero', (tester) async {
      final value = AnimatableValue(vsync: const TestVSync());
      addTearDown(value.dispose);

      expect(value.value, 0.0);
    });

    testWidgets('snapTo applies immediately and notifies listeners', (
      tester,
    ) async {
      final value = AnimatableValue(vsync: const TestVSync());
      addTearDown(value.dispose);
      var notifications = 0;
      value.listenable.addListener(() => notifications++);

      value.snapTo(7.5);

      expect(value.value, 7.5);
      expect(notifications, 1);
      expect(value.isAnimating, isFalse);
    });

    testWidgets('snapTo supports values outside 0..1', (tester) async {
      final value = AnimatableValue(vsync: const TestVSync());
      addTearDown(value.dispose);

      value.snapTo(-500);
      expect(value.value, -500.0);

      value.snapTo(1234.5);
      expect(value.value, 1234.5);
    });

    testWidgets('snapTo cancels a running animation', (tester) async {
      final value = AnimatableValue(vsync: const TestVSync());
      addTearDown(value.dispose);

      final animation = value.animateTo(
        100,
        duration: const Duration(seconds: 1),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(value.isAnimating, isTrue);

      value.snapTo(-3);

      expect(value.value, -3.0);
      expect(value.isAnimating, isFalse);
      await expectLater(animation, completes);
    });

    testWidgets('animateTo reaches the target at the given duration', (
      tester,
    ) async {
      final value = AnimatableValue(vsync: const TestVSync());
      addTearDown(value.dispose);

      final animation = value.animateTo(
        100,
        duration: const Duration(seconds: 1),
        curve: Curves.linear,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(value.value, closeTo(50.0, 0.001));
      expect(value.isAnimating, isTrue);

      await tester.pump(const Duration(milliseconds: 500));
      // The controller only settles once a frame passes the duration.
      await tester.pump(const Duration(milliseconds: 1));

      expect(value.value, closeTo(100.0, 0.001));
      await animation;
      expect(value.isAnimating, isFalse);
    });

    testWidgets('animateTo defaults to a 300ms fastOutSlowIn tween', (
      tester,
    ) async {
      final value = AnimatableValue(vsync: const TestVSync());
      addTearDown(value.dispose);

      final animation = value.animateTo(100);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // fastOutSlowIn eases out, so the halfway frame is past halfway.
      expect(value.value, greaterThan(50.0));

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 1));

      expect(value.value, closeTo(100.0, 0.001));
      await animation;
    });

    testWidgets('notifies listeners while animating', (tester) async {
      final value = AnimatableValue(vsync: const TestVSync());
      addTearDown(value.dispose);
      var notifications = 0;
      value.listenable.addListener(() => notifications++);

      final animation = value.animateTo(
        10,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final halfwayNotifications = notifications;

      expect(halfwayNotifications, greaterThan(0));

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 1));
      expect(notifications, greaterThan(halfwayNotifications));
      await animation;
    });

    testWidgets('a superseded animation completes without throwing', (
      tester,
    ) async {
      final value = AnimatableValue(vsync: const TestVSync());
      addTearDown(value.dispose);

      final first = value.animateTo(100, duration: const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final second = value.animateTo(
        -100,
        duration: const Duration(seconds: 1),
      );

      await expectLater(first, completes);

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 1));

      await expectLater(second, completes);
      expect(value.value, closeTo(-100.0, 0.001));
      expect(value.isAnimating, isFalse);
    });

    testWidgets('dispose completes a pending animation future', (tester) async {
      final value = AnimatableValue(vsync: const TestVSync());

      final animation = value.animateTo(
        100,
        duration: const Duration(seconds: 1),
      );
      await tester.pump();
      expect(value.isAnimating, isTrue);

      value.dispose();

      await expectLater(animation, completes);
    });

    testWidgets('animateTo with a zero duration applies immediately', (
      tester,
    ) async {
      final value = AnimatableValue(vsync: const TestVSync());
      addTearDown(value.dispose);

      await value.animateTo(25, duration: Duration.zero);

      expect(value.value, 25.0);
      expect(value.isAnimating, isFalse);
    });
  });
}
