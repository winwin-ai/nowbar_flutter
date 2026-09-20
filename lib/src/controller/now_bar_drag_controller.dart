/// The gesture direction a Now Bar surface responds to.
///
/// The value is chosen by the host app to restrict how the bar cycles through
/// components: [dragUp], [dragDown], and [dragVertically] gate the vertical
/// cycling axis.
///
/// Horizontal swipe-to-dismiss is independent of this setting. It is always
/// available for any active component whose `dismissible` flag is `true`,
/// regardless of the chosen value. [dragHorizontally] does not enable or
/// disable dismissal; it is the value used when the bar should not cycle
/// vertically.
enum NowBarDragController {
  /// Only upward drags advance to the next component.
  dragUp,

  /// Only downward drags step back to the previous component.
  dragDown,

  /// Both upward and downward drags step through components.
  dragVertically,

  /// Horizontal drags dismiss the active component.
  dragHorizontally,
}
