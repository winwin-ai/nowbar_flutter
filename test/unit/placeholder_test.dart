import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder unit test passes', () {
    expect(1 + 1, equals(2));
  });

  testWidgets('bundled Inter font assets are loadable', (tester) async {
    final bytes = await rootBundle.load('assets/fonts/Inter-Regular.otf');
    expect(bytes.lengthInBytes, greaterThan(100000));
  });
}
