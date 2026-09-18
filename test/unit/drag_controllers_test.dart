import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/src/controller/drag_direction.dart';
import 'package:nowbar_flutter/src/controller/now_bar_drag_controller.dart';

void main() {
  group('NowBarDragController', () {
    test('declares the supported gesture modes in reference order', () {
      expect(NowBarDragController.values, <NowBarDragController>[
        NowBarDragController.dragUp,
        NowBarDragController.dragDown,
        NowBarDragController.dragVertically,
        NowBarDragController.dragHorizontally,
      ]);
    });
  });

  group('DragDirection', () {
    test('declares none, horizontal and vertical in reference order', () {
      expect(DragDirection.values, <DragDirection>[
        DragDirection.none,
        DragDirection.horizontal,
        DragDirection.vertical,
      ]);
    });
  });
}
