import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/src/internal/list_extensions.dart';

void main() {
  group('List.sortWithTopValueAscending(value)', () {
    test('moves a middle value first and reverses both runs', () {
      final list = <String>['a', 'b', 'c', 'd', 'e'];

      final result = list.sortWithTopValueAscending('c');

      expect(result, same(list));
      expect(list, <String>['c', 'b', 'a', 'e', 'd']);
    });

    test('moves the first value first and reverses the remainder', () {
      final list = <int>[1, 2, 3, 4];

      list.sortWithTopValueAscending(1);

      expect(list, <int>[1, 4, 3, 2]);
    });

    test('reverses the whole list when the last value is first', () {
      final list = <int>[1, 2, 3, 4];

      list.sortWithTopValueAscending(4);

      expect(list, <int>[4, 3, 2, 1]);
    });

    test('empties the list when the value is absent', () {
      final list = <int>[1, 2, 3];

      list.sortWithTopValueAscending(9);

      expect(list, isEmpty);
    });
  });

  group('List.sortWithTopValueAtPosition(position)', () {
    test('moves the element at the position first and reverses both runs', () {
      final list = <String>['a', 'b', 'c', 'd', 'e'];

      final result = list.sortWithTopValueAtPosition(2);

      expect(result, same(list));
      expect(list, <String>['c', 'b', 'a', 'e', 'd']);
    });

    test('reverses only the tail when the first position is requested', () {
      final list = <int>[1, 2, 3];

      list.sortWithTopValueAtPosition(0);

      expect(list, <int>[1, 3, 2]);
    });

    test('reverses the whole list when the last position is requested', () {
      final list = <int>[1, 2, 3];

      list.sortWithTopValueAtPosition(2);

      expect(list, <int>[3, 2, 1]);
    });

    test('empties the list for an out-of-range position', () {
      final list = <int>[1, 2, 3];

      list.sortWithTopValueAtPosition(3);

      expect(list, isEmpty);
    });

    test('empties the list for a negative position', () {
      final list = <int>[1, 2, 3];

      list.sortWithTopValueAtPosition(-1);

      expect(list, isEmpty);
    });
  });
}
