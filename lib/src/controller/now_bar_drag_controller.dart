/// The gesture direction a Now Bar surface responds to.
///
/// The value is chosen by the host app to restrict how the bar can be
/// manipulated: vertical modes cycle through components, while
/// [dragHorizontally] enables the swipe-to-dismiss axis.
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
