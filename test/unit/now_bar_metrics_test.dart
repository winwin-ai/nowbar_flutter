import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/src/metrics/dimensions.dart';
import 'package:nowbar_flutter/src/metrics/now_bar_metrics.dart';

void main() {
  group('NowBarMetrics', () {
    test('defaults mirror the Dimensions constants', () {
      const metrics = NowBarMetrics();

      expect(metrics.cornerRadius, Dimensions.cornerRadius);
      expect(metrics.widgetHeight, Dimensions.nowBarHeight);
      expect(metrics.translationClamp, Dimensions.translationClamp);
      expect(metrics.shadowElevation, Dimensions.shadowElevation);
      expect(metrics.fillMaxWidthOffset, Dimensions.fillMaxWidthOffset);
      expect(metrics.animationMultiplier, 1);
    });

    test('keeps explicitly supplied values', () {
      const metrics = NowBarMetrics(
        cornerRadius: 8.0,
        widgetHeight: 40.0,
        translationClamp: (-10.0, 20.0),
        shadowElevation: 2.0,
        fillMaxWidthOffset: 0.5,
        animationMultiplier: 3,
      );

      expect(metrics.cornerRadius, 8.0);
      expect(metrics.widgetHeight, 40.0);
      expect(metrics.translationClamp, (-10.0, 20.0));
      expect(metrics.shadowElevation, 2.0);
      expect(metrics.fillMaxWidthOffset, 0.5);
      expect(metrics.animationMultiplier, 3);
    });

    test('copyWith replaces only the supplied fields', () {
      const original = NowBarMetrics();
      final copy = original.copyWith(
        cornerRadius: 12.0,
        translationClamp: (-5.0, 5.0),
        animationMultiplier: 4,
      );

      expect(copy.cornerRadius, 12.0);
      expect(copy.translationClamp, (-5.0, 5.0));
      expect(copy.animationMultiplier, 4);
      expect(copy.widgetHeight, original.widgetHeight);
      expect(copy.shadowElevation, original.shadowElevation);
      expect(copy.fillMaxWidthOffset, original.fillMaxWidthOffset);
      expect(original.cornerRadius, Dimensions.cornerRadius);
    });

    test('compares by value', () {
      const first = NowBarMetrics();
      const second = NowBarMetrics();

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
      expect(first.copyWith(animationMultiplier: 2), isNot(equals(first)));
      expect(first.copyWith(cornerRadius: 0.0), isNot(equals(first)));
    });
  });
}
