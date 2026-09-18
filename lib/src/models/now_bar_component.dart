import 'package:flutter/widgets.dart';

/// A single entry in the Now Bar rotation.
///
/// A component pairs a [builder] that produces the surface content with a
/// [dismissible] flag. Equality is intentionally identity-based: each
/// component owns a distinct builder, so components are tracked by object
/// identity while the rotation cycles or dismisses entries.
class NowBarComponent {
  /// Creates a component whose surface is produced by [builder].
  ///
  /// Set [dismissible] to `false` to prevent a horizontal swipe from removing
  /// the component from the rotation.
  const NowBarComponent({required this.builder, this.dismissible = true});

  /// Builds the surface shown for this component.
  final Widget Function() builder;

  /// Whether a swipe gesture may remove this component from the rotation.
  final bool dismissible;
}
