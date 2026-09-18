import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/src/models/now_bar_component.dart';

void main() {
  group('NowBarComponent', () {
    test('defaults to dismissible', () {
      final component = NowBarComponent(builder: () => const SizedBox.shrink());

      expect(component.dismissible, isTrue);
    });

    test('builds the supplied surface', () {
      final component = NowBarComponent(builder: () => const Placeholder());

      expect(component.builder(), isA<Placeholder>());
    });

    test('can be marked non-dismissible', () {
      final component = NowBarComponent(
        builder: () => const SizedBox.shrink(),
        dismissible: false,
      );

      expect(component.dismissible, isFalse);
    });

    test('uses identity equality instead of comparing builders', () {
      Widget buildSurface() => const SizedBox.shrink();

      final first = NowBarComponent(builder: buildSurface);
      final second = NowBarComponent(builder: buildSurface);

      expect(first, equals(first));
      expect(first, isNot(equals(second)));
    });
  });
}
