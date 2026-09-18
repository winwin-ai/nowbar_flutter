/// Static design constants that drive the Now Bar layout and motion system.
///
/// The values mirror the dimensions used by the reference Now Bar design so
/// that every surface, shadow, and drag translation stays visually consistent.
///
/// This class cannot be instantiated; it only namespaces the constants.
abstract final class Dimensions {
  /// Corner radius, in logical pixels, applied to every Now Bar surface.
  static const double cornerRadius = 50.0;

  /// Elevation, in logical pixels, of the shadow cast by the bar.
  static const double shadowElevation = 12.0;

  /// Lower and upper bounds, in logical pixels, for vertical drag translation.
  ///
  /// The first component clamps upward movement (negative offsets) and the
  /// second clamps downward movement (positive offsets).
  static const (double, double) translationClamp = (-200.0, 250.0);

  /// Default height, in logical pixels, of a single Now Bar surface.
  static const double nowBarHeight = 80.0;

  /// Fraction of the available width a maximized Now Bar surface occupies.
  static const double fillMaxWidthOffset = 0.9;
}
