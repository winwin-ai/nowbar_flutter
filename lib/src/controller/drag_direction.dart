/// The axis resolved for the gesture currently being tracked.
///
/// A drag starts as [none]; once the movement is large enough, the dominant
/// axis is locked to either [horizontal] or [vertical] for the rest of the
/// gesture.
enum DragDirection {
  /// No dominant axis has been resolved yet.
  none,

  /// The drag is dominated by horizontal movement.
  horizontal,

  /// The drag is dominated by vertical movement.
  vertical,
}
