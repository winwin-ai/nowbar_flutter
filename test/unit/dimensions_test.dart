import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/src/metrics/dimensions.dart';

void main() {
  group('Dimensions', () {
    test('exposes the reference corner radius', () {
      expect(Dimensions.cornerRadius, 50.0);
    });

    test('exposes the reference shadow elevation', () {
      expect(Dimensions.shadowElevation, 12.0);
    });

    test('exposes the vertical translation clamp', () {
      expect(Dimensions.translationClamp, (-200.0, 250.0));
      expect(Dimensions.translationClamp.$1, lessThan(0.0));
      expect(Dimensions.translationClamp.$2, greaterThan(0.0));
    });

    test('exposes the reference bar height', () {
      expect(Dimensions.nowBarHeight, 80.0);
    });

    test('exposes the maximized width fraction', () {
      expect(Dimensions.fillMaxWidthOffset, 0.9);
    });
  });
}
