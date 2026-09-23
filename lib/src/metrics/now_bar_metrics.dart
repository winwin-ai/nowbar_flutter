import 'package:flutter/foundation.dart';

import 'dimensions.dart';

/// Immutable layout metrics used to size and animate Now Bar surfaces.
///
/// Every field defaults to the matching constant in [Dimensions], so a plain
/// `const NowBarMetrics()` reproduces the reference layout. Use [copyWith] to
/// override individual values.
@immutable
class NowBarMetrics {
  /// Creates a metrics set, defaulting to the standard [Dimensions] values.
  const NowBarMetrics({
    this.cornerRadius = Dimensions.cornerRadius,
    this.widgetHeight = Dimensions.nowBarHeight,
    this.translationClamp = Dimensions.translationClamp,
    this.shadowElevation = Dimensions.shadowElevation,
    this.fillMaxWidthOffset = Dimensions.fillMaxWidthOffset,
    this.animationMultiplier = 1,
  });

  /// Corner radius, in logical pixels, applied to the bar surface.
  final double cornerRadius;

  /// Height, in logical pixels, of a single bar surface.
  final double widgetHeight;

  /// Lower and upper bounds, in logical pixels, for vertical drag translation.
  final (double, double) translationClamp;

  /// Elevation, in logical pixels, of the shadow cast by the bar.
  final double shadowElevation;

  /// Fraction of the available width the bar occupies when maximized.
  final double fillMaxWidthOffset;

  /// Multiplier applied to animation durations; values above 1 slow motion
  /// down, values below 1 speed it up.
  final int animationMultiplier;

  /// Returns a copy of these metrics with the given fields replaced.
  ///
  /// Fields that are omitted keep their current value.
  NowBarMetrics copyWith({
    double? cornerRadius,
    double? widgetHeight,
    (double, double)? translationClamp,
    double? shadowElevation,
    double? fillMaxWidthOffset,
    int? animationMultiplier,
  }) {
    return NowBarMetrics(
      cornerRadius: cornerRadius ?? this.cornerRadius,
      widgetHeight: widgetHeight ?? this.widgetHeight,
      translationClamp: translationClamp ?? this.translationClamp,
      shadowElevation: shadowElevation ?? this.shadowElevation,
      fillMaxWidthOffset: fillMaxWidthOffset ?? this.fillMaxWidthOffset,
      animationMultiplier: animationMultiplier ?? this.animationMultiplier,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is NowBarMetrics &&
        other.cornerRadius == cornerRadius &&
        other.widgetHeight == widgetHeight &&
        other.translationClamp == translationClamp &&
        other.shadowElevation == shadowElevation &&
        other.fillMaxWidthOffset == fillMaxWidthOffset &&
        other.animationMultiplier == animationMultiplier;
  }

  @override
  int get hashCode => Object.hash(
        cornerRadius,
        widgetHeight,
        translationClamp,
        shadowElevation,
        fillMaxWidthOffset,
        animationMultiplier,
      );

  @override
  String toString() =>
      'NowBarMetrics(cornerRadius: $cornerRadius, widgetHeight: $widgetHeight, '
      'translationClamp: $translationClamp, shadowElevation: $shadowElevation, '
      'fillMaxWidthOffset: $fillMaxWidthOffset, '
      'animationMultiplier: $animationMultiplier)';
}
