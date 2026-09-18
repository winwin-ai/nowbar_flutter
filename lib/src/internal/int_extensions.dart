/// Range-mapping helpers on [int].
extension IntExtensions on int {
  /// Clamps this value to the inclusive interval from [min] to [max].
  ///
  /// The bounds are compared in order: a value below [min] becomes [min], a
  /// value above [max] becomes [max].
  int clampRange(int min, int max) {
    if (this < min) {
      return min;
    } else if (this > max) {
      return max;
    }
    return this;
  }
}
