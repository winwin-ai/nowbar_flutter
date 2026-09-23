import 'package:flutter/material.dart';

/// Immutable palette applied to a notification surface.
///
/// Despite the historical name, this is a value object rather than a live
/// controller: it carries the background color (or gradient), icon, title, and
/// content colors for one notification. Use [copyWith] to derive a variant
/// without mutating the original.
@immutable
class NotificationColorController {
  /// Creates a palette, defaulting to the standard Now Bar notification
  /// colors.
  const NotificationColorController({
    this.backgroundColor = const Color(0xFF303164),
    this.backgroundColorGradient,
    this.iconColor = Colors.white,
    this.titleColor = Colors.white,
    this.contentColor = Colors.white,
  });

  /// Solid background color, used when [backgroundColorGradient] is null.
  final Color backgroundColor;

  /// Optional background gradient; when set it takes precedence over
  /// [backgroundColor].
  final Gradient? backgroundColorGradient;

  /// Color of the leading notification icon.
  final Color iconColor;

  /// Color of the notification title.
  final Color titleColor;

  /// Color of the notification body text.
  final Color contentColor;

  /// Returns a copy of this palette with the given fields replaced.
  ///
  /// Fields that are omitted keep their current value. Passing `null` for
  /// [backgroundColorGradient] keeps the existing gradient because a null
  /// argument is indistinguishable from an omitted one.
  NotificationColorController copyWith({
    Color? backgroundColor,
    Gradient? backgroundColorGradient,
    Color? iconColor,
    Color? titleColor,
    Color? contentColor,
  }) {
    return NotificationColorController(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundColorGradient:
          backgroundColorGradient ?? this.backgroundColorGradient,
      iconColor: iconColor ?? this.iconColor,
      titleColor: titleColor ?? this.titleColor,
      contentColor: contentColor ?? this.contentColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is NotificationColorController &&
        other.backgroundColor == backgroundColor &&
        other.backgroundColorGradient == backgroundColorGradient &&
        other.iconColor == iconColor &&
        other.titleColor == titleColor &&
        other.contentColor == contentColor;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        backgroundColorGradient,
        iconColor,
        titleColor,
        contentColor,
      );

  @override
  String toString() =>
      'NotificationColorController(backgroundColor: $backgroundColor, '
      'backgroundColorGradient: $backgroundColorGradient, '
      'iconColor: $iconColor, titleColor: $titleColor, '
      'contentColor: $contentColor)';
}
