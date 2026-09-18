import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Global test bootstrap for the package.
///
/// Registered automatically by `flutter test` through the
/// `test/flutter_test_config.dart` convention. It loads the bundled Inter
/// font family into the test font collection so widget and golden tests
/// render with Inter instead of the default test font.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadInterFonts();
  await testMain();
}

Future<void> _loadInterFonts() async {
  const assetPaths = <String>[
    'assets/fonts/Inter-Regular.otf',
    'assets/fonts/Inter-SemiBold.otf',
    'assets/fonts/Inter-Bold.otf',
  ];

  final loader = FontLoader('Inter');
  for (final assetPath in assetPaths) {
    loader.addFont(rootBundle.load(assetPath));
  }
  await loader.load();
}
