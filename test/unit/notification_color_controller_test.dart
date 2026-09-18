import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/src/models/notification_color_controller.dart';

void main() {
  group('NotificationColorController', () {
    test('defaults to the standard notification palette', () {
      const controller = NotificationColorController();

      expect(controller.backgroundColor, const Color(0xFF303164));
      expect(controller.backgroundColorGradient, isNull);
      expect(controller.iconColor, Colors.white);
      expect(controller.titleColor, Colors.white);
      expect(controller.contentColor, Colors.white);
    });

    test('keeps explicitly supplied colors and gradient', () {
      const gradient = LinearGradient(
        colors: <Color>[Color(0xFF0A66C2), Color(0xFFB3D5FA)],
      );
      const controller = NotificationColorController(
        backgroundColor: Colors.black,
        backgroundColorGradient: gradient,
        iconColor: Colors.amber,
        titleColor: Colors.red,
        contentColor: Colors.green,
      );

      expect(controller.backgroundColor, Colors.black);
      expect(controller.backgroundColorGradient, gradient);
      expect(controller.iconColor, Colors.amber);
      expect(controller.titleColor, Colors.red);
      expect(controller.contentColor, Colors.green);
    });

    test('copyWith replaces only the supplied fields', () {
      const original = NotificationColorController();
      final copy = original.copyWith(iconColor: Colors.amber);

      expect(copy.iconColor, Colors.amber);
      expect(copy.backgroundColor, original.backgroundColor);
      expect(copy.backgroundColorGradient, original.backgroundColorGradient);
      expect(copy.titleColor, original.titleColor);
      expect(copy.contentColor, original.contentColor);
      expect(original.iconColor, Colors.white);
    });

    test('copyWith can attach a gradient without touching the solid color', () {
      const gradient = LinearGradient(
        colors: <Color>[Color(0xFFFADC1E), Color(0xFF0D69B3)],
      );
      const original = NotificationColorController();
      final copy = original.copyWith(backgroundColorGradient: gradient);

      expect(copy.backgroundColorGradient, gradient);
      expect(copy.backgroundColor, original.backgroundColor);
    });

    test('compares by value', () {
      const first = NotificationColorController();
      const second = NotificationColorController();

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
      expect(first.copyWith(iconColor: Colors.amber), isNot(equals(first)));
    });
  });
}
