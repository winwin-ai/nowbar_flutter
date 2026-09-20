import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// A single [double] that can be snapped or animated to a target.
///
/// This is the Flutter analogue of Compose's `Animatable`: it wraps an
/// [AnimationController.unbounded] so the value may move outside the `0..1`
/// range, exposes [value] for synchronous reads, and offers both an immediate
/// [snapTo] and an awaited [animateTo].
class AnimatableValue {
  /// Creates a value that starts at [initialValue].
  ///
  /// The [vsync] provider owns the underlying ticker and must outlive this
  /// object; call [dispose] when the value is no longer needed.
  AnimatableValue({required TickerProvider vsync, double initialValue = 0})
    : _controller = AnimationController.unbounded(
        vsync: vsync,
        value: initialValue,
      );

  final AnimationController _controller;

  Completer<void>? _activeAnimationCompletion;

  bool _disposed = false;

  /// The current value.
  ///
  /// The value is not constrained to `0..1`; any finite double is valid.
  double get value => _controller.value;

  /// Notifies listeners whenever [value] changes.
  ///
  /// Suitable for an `AnimatedBuilder` or any other [Listenable] consumer.
  Listenable get listenable => _controller;

  /// Whether an [animateTo] animation is currently in progress.
  bool get isAnimating => _controller.isAnimating;

  /// Immediately moves the value to [target], cancelling any running
  /// animation.
  ///
  /// Listeners are notified synchronously. Once [dispose] has run this is a
  /// no-op, so a release handler that outlives its state cannot touch the
  /// disposed controller.
  void snapTo(double target) {
    if (_disposed) {
      return;
    }
    _completeActiveAnimation();
    _controller.value = target;
  }

  /// Animates the value to [target] over [duration] using [curve].
  ///
  /// The returned future completes once [target] is reached. If the animation
  /// is superseded by another [animateTo] or by [snapTo], it completes
  /// normally instead of reporting an error. Once [dispose] has run the
  /// returned future is already complete and the value does not move.
  Future<void> animateTo(
    double target, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.fastOutSlowIn,
  }) {
    if (_disposed) {
      return Future<void>.value();
    }
    _completeActiveAnimation();
    final completion = Completer<void>();
    if (duration <= Duration.zero) {
      _controller.value = target;
      completion.complete();
      return completion.future;
    }
    _activeAnimationCompletion = completion;
    _controller
        .animateTo(target, duration: duration, curve: curve)
        .whenCompleteOrCancel(() {
          if (!completion.isCompleted) {
            completion.complete();
          }
        });
    return completion.future;
  }

  /// Releases the underlying controller.
  ///
  /// Any pending [animateTo] future completes normally, and the value must not
  /// be used afterwards: [snapTo] becomes a no-op and [animateTo] returns an
  /// already completed future.
  void dispose() {
    _disposed = true;
    _completeActiveAnimation();
    _controller.dispose();
  }

  void _completeActiveAnimation() {
    final completion = _activeAnimationCompletion;
    _activeAnimationCompletion = null;
    if (completion != null && !completion.isCompleted) {
      completion.complete();
    }
  }
}
