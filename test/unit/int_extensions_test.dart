import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/src/internal/int_extensions.dart';

void main() {
  group('int.clampRange', () {
    test('keeps a value inside the interval unchanged', () {
      expect(5.clampRange(0, 10), 5);
    });

    test('returns the lower bound for a value below the interval', () {
      expect((-5).clampRange(0, 10), 0);
    });

    test('returns the upper bound for a value above the interval', () {
      expect(15.clampRange(0, 10), 10);
    });

    test('keeps boundary values unchanged', () {
      expect(0.clampRange(0, 10), 0);
      expect(10.clampRange(0, 10), 10);
    });

    test('supports negative intervals', () {
      expect((-20).clampRange(-10, -5), -10);
      expect((-1).clampRange(-10, -5), -5);
      expect((-7).clampRange(-10, -5), -7);
    });
  });
}
