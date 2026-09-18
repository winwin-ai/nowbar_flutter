import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/src/internal/float_extensions.dart';

void main() {
  group('double.clampRange(min, max)', () {
    test('keeps a value inside the interval unchanged', () {
      expect(5.0.clampRange(0.0, 10.0), 5.0);
    });

    test('returns the lower bound for a value below the interval', () {
      expect((-5.0).clampRange(0.0, 10.0), 0.0);
    });

    test('returns the upper bound for a value above the interval', () {
      expect(15.0.clampRange(0.0, 10.0), 10.0);
    });

    test('keeps boundary values unchanged', () {
      expect(0.0.clampRange(0.0, 10.0), 0.0);
      expect(10.0.clampRange(0.0, 10.0), 10.0);
    });

    test('supports negative intervals', () {
      expect((-20.0).clampRange(-10.0, -5.0), -10.0);
      expect((-1.0).clampRange(-10.0, -5.0), -5.0);
      expect((-7.0).clampRange(-10.0, -5.0), -7.0);
    });
  });

  group('double.clampRange(record)', () {
    test('reads the record as (min, max)', () {
      expect(15.0.clampRange((0.0, 10.0)), 10.0);
      expect((-1.0).clampRange((0.0, 10.0)), 0.0);
      expect(5.0.clampRange((0.0, 10.0)), 5.0);
    });

    test('applies the record bounds in order when they descend', () {
      // The first comparison wins for descending bounds, matching the
      // two-argument form.
      expect(15.0.clampRange((10.0, 0.0)), 0.0);
      expect(5.0.clampRange((10.0, 0.0)), 10.0);
      expect((-1.0).clampRange((10.0, 0.0)), 10.0);
    });

    test('throws when only a lower bound is supplied', () {
      expect(() => 5.0.clampRange(0.0), throwsArgumentError);
    });
  });

  group('double.mapRange', () {
    test('maps an ascending source interval onto an ascending target', () {
      expect(100.0.mapRange(0.0, 200.0, 0.0, 10.0), 5.0);
      expect(0.0.mapRange(0.0, 200.0, 0.0, 10.0), 0.0);
      expect(200.0.mapRange(0.0, 200.0, 0.0, 10.0), 10.0);
    });

    test('clamps values outside the source interval', () {
      expect(300.0.mapRange(0.0, 200.0, 0.0, 10.0), 10.0);
      expect((-50.0).mapRange(0.0, 200.0, 0.0, 10.0), 0.0);
    });

    test('maps a descending source interval onto an ascending target', () {
      expect(100.0.mapRange(200.0, 0.0, 0.9, 1.0), closeTo(0.95, 1e-9));
      expect(200.0.mapRange(200.0, 0.0, 0.9, 1.0), 0.9);
      expect(0.0.mapRange(200.0, 0.0, 0.9, 1.0), 1.0);
    });

    test('clamps a descending source interval outside its bounds', () {
      expect(300.0.mapRange(200.0, 0.0, 0.9, 1.0), 0.9);
      expect((-100.0).mapRange(200.0, 0.0, 0.9, 1.0), 1.0);
    });

    test('maps an ascending source interval onto a descending target', () {
      expect(100.0.mapRange(0.0, 200.0, 1.0, 0.0), closeTo(0.5, 1e-9));
      expect(0.0.mapRange(0.0, 200.0, 1.0, 0.0), 1.0);
      expect(200.0.mapRange(0.0, 200.0, 1.0, 0.0), 0.0);
    });

    test('clamps a descending target interval outside its bounds', () {
      expect(300.0.mapRange(0.0, 200.0, 1.0, 0.0), 0.0);
      expect((-50.0).mapRange(0.0, 200.0, 1.0, 0.0), 1.0);
    });

    test('maps a descending source interval onto a descending target', () {
      expect(100.0.mapRange(200.0, 0.0, 1.0, 0.0), closeTo(0.5, 1e-9));
      expect(200.0.mapRange(200.0, 0.0, 1.0, 0.0), 1.0);
      expect(0.0.mapRange(200.0, 0.0, 1.0, 0.0), 0.0);
    });
  });
}
