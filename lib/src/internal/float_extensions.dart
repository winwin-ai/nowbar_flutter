/// Range-mapping helpers on [double].
extension FloatExtensions on double {
  /// Clamps this value to an inclusive interval.
  ///
  /// The interval can be supplied either as two bounds,
  /// `value.clampRange(min, max)`, or as a `(min, max)` record,
  /// `value.clampRange((min, max))`.
  ///
  /// Bounds are compared in order: a value below the lower bound becomes the
  /// lower bound, and a value above the upper bound becomes the upper bound.
  /// When the lower bound is greater than the upper bound, the first
  /// comparison wins, so callers that need direction-agnostic clamping should
  /// order the bounds before calling. A call that supplies neither form throws
  /// an [ArgumentError].
  double clampRange(Object minOrRange, [double? max]) {
    final double lower;
    final double upper;
    if (minOrRange is (double, double)) {
      lower = minOrRange.$1;
      upper = minOrRange.$2;
    } else if (minOrRange is double && max != null) {
      lower = minOrRange;
      upper = max;
    } else {
      throw ArgumentError.value(
        minOrRange,
        'minOrRange',
        'Expected a lower bound with an upper bound, or a (min, max) record',
      );
    }
    if (this < lower) {
      return lower;
    } else if (this > upper) {
      return upper;
    }
    return this;
  }

  /// Remaps this value from one interval to another.
  ///
  /// The source interval runs from [fromMin] to [fromMax] and the destination
  /// interval runs from [toMin] to [toMax]; either interval may be descending
  /// (its first bound greater than its second). Values outside the source
  /// interval are clamped to the destination interval.
  double mapRange(double fromMin, double fromMax, double toMin, double toMax) {
    final mapped =
        ((this - fromMin) / (fromMax - fromMin)) * (toMax - toMin) + toMin;
    final lower = toMin <= toMax ? toMin : toMax;
    final upper = toMin <= toMax ? toMax : toMin;
    return mapped.clampRange(lower, upper);
  }
}
