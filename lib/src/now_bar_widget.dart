import 'dart:async';

import 'package:flutter/material.dart';

import 'controller/drag_direction.dart';
import 'controller/now_bar_drag_controller.dart';
import 'internal/animatable_value.dart';
import 'internal/float_extensions.dart';
import 'internal/int_extensions.dart';
import 'metrics/now_bar_metrics.dart';
import 'models/now_bar_component.dart';

/// The root Now Bar surface that hosts and rotates [NowBarComponent]s.
///
/// One component is active at a time, presented as the top card of a stacked
/// deck. Each drag locks to its dominant axis once movement begins: vertical
/// drags step through the rotation in the direction allowed by
/// [dragDirection], while a horizontal drag past half the screen width
/// dismisses the active component when its `dismissible` flag is `true`.
class NowBarWidget extends StatefulWidget {
  /// Creates a [NowBarWidget].
  ///
  /// [innerPadding] is applied inside the bar surface, [widgets] provides the
  /// rotation in display order, and [metrics] and [dragDirection] tune the
  /// layout, motion, and accepted gestures.
  const NowBarWidget({
    super.key,
    this.innerPadding = EdgeInsets.zero,
    required this.widgets,
    this.metrics = const NowBarMetrics(),
    this.dragDirection = NowBarDragController.dragUp,
  });

  /// Padding applied inside the bar surface, around the card deck.
  final EdgeInsets innerPadding;

  /// The components shown in the rotation, in display order.
  final List<NowBarComponent> widgets;

  /// Layout and motion metrics applied to the surfaces.
  final NowBarMetrics metrics;

  /// The gesture direction this surface responds to.
  final NowBarDragController dragDirection;

  @override
  State<NowBarWidget> createState() => _NowBarWidgetState();
}

class _NowBarWidgetState extends State<NowBarWidget>
    with TickerProviderStateMixin {
  late final AnimatableValue _nextScale;
  late final AnimatableValue _offsetX;
  late final AnimatableValue _offsetY;
  late final AnimatableValue _nextY;
  late List<NowBarComponent> _components;

  int _topIndex = 0;
  DragDirection _locked = DragDirection.none;

  @override
  void initState() {
    super.initState();
    _nextScale = AnimatableValue(vsync: this);
    _offsetX = AnimatableValue(vsync: this);
    _offsetY = AnimatableValue(vsync: this);
    _nextY = AnimatableValue(vsync: this, initialValue: -1);
    _components = List.of(widget.widgets);
  }

  @override
  void didUpdateWidget(NowBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.widgets, widget.widgets)) {
      setState(() {
        _components = List.of(widget.widgets);
        _topIndex = _components.isEmpty
            ? 0
            : _topIndex.clampRange(0, _components.length - 1);
      });
    }
  }

  @override
  void dispose() {
    _nextScale.dispose();
    _offsetX.dispose();
    _offsetY.dispose();
    _nextY.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _locked = DragDirection.none;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_components.isEmpty) {
      return;
    }
    final delta = details.delta;
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    if (_locked == DragDirection.none) {
      _locked = delta.dx.abs() > delta.dy.abs()
          ? DragDirection.horizontal
          : DragDirection.vertical;
    }
    if (_locked == DragDirection.horizontal) {
      _offsetX.snapTo(_offsetX.value + delta.dx * dpr);
    } else {
      _offsetY.snapTo(_offsetY.value + delta.dy * dpr);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    unawaited(_handleRelease());
  }

  void _onPanCancel() {
    unawaited(_handleRelease());
  }

  Future<void> _handleRelease() async {
    if (_components.isEmpty) {
      return;
    }
    if (_locked == DragDirection.horizontal) {
      await _releaseHorizontal();
    } else {
      await _releaseVertical();
    }
  }

  Future<void> _releaseHorizontal() async {
    final top = _components[_topIndex.clampRange(0, _components.length - 1)];
    final screenWidth = MediaQuery.sizeOf(context).width;
    final multiplier = widget.metrics.animationMultiplier;
    final duration = Duration(milliseconds: 800 * multiplier);
    if (_offsetX.value > screenWidth * 0.5 && top.dismissible) {
      _nextScale.snapTo(1 - 0.12);
      unawaited(_nextY.animateTo(_offsetY.value, duration: duration));
      unawaited(_nextScale.animateTo(1, duration: duration));
      await _offsetX.animateTo(screenWidth * 3, duration: duration);
      if (!mounted) {
        return;
      }
      setState(() {
        _nextY.snapTo(-1);
        _nextScale.snapTo(0);
        _offsetX.snapTo(0);
        _components.remove(top);
        _topIndex = _components.isEmpty
            ? 0
            : _topIndex.clampRange(0, _components.length - 1);
      });
    } else {
      await _offsetX.animateTo(0, duration: const Duration(milliseconds: 800));
    }
  }

  Future<void> _releaseVertical() async {
    final y = _offsetY.value;
    final clamp = widget.metrics.translationClamp;
    final multiplier = widget.metrics.animationMultiplier;
    final duration = Duration(milliseconds: 800 * multiplier);
    final canAdvance = widget.dragDirection == NowBarDragController.dragUp ||
        widget.dragDirection == NowBarDragController.dragVertically;
    final canStepBack = widget.dragDirection == NowBarDragController.dragDown ||
        widget.dragDirection == NowBarDragController.dragVertically;
    if (y < -50 && canAdvance) {
      if (y < -150) {
        await _offsetY.animateTo(
          clamp.$1,
          duration: Duration(milliseconds: 300 * multiplier),
        );
        if (!mounted) {
          return;
        }
        await _offsetY.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
        );
        if (!mounted) {
          return;
        }
        setState(() => _topIndex = (_topIndex + 1) % _components.length);
      } else {
        await _offsetY.animateTo(0, duration: duration);
      }
    } else if (y > 50 && canStepBack) {
      if (y > 150) {
        await _offsetY.animateTo(
          clamp.$2,
          duration: Duration(milliseconds: 300 * multiplier),
        );
        if (!mounted) {
          return;
        }
        await _offsetY.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
        );
        if (!mounted) {
          return;
        }
        setState(
          () => _topIndex =
              (_topIndex - 1 + _components.length) % _components.length,
        );
      } else {
        await _offsetY.animateTo(0, duration: duration);
      }
    } else {
      await _offsetY.animateTo(0, duration: duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      child: Padding(
        padding: widget.innerPadding,
        child: ListenableBuilder(
          listenable: Listenable.merge([
            _nextScale.listenable,
            _offsetX.listenable,
            _offsetY.listenable,
            _nextY.listenable,
          ]),
          builder: (context, child) => LayoutBuilder(
            builder: (context, constraints) {
              final count = _components.length;
              if (count == 0) {
                return const SizedBox.shrink();
              }
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  for (int i = count - 1; i >= 0; i--)
                    _buildSurface(i, constraints.maxWidth),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSurface(int index, double availableWidth) {
    final component = _components[(_topIndex + index) % _components.length];
    final metrics = widget.metrics;
    final clamp = metrics.translationClamp;
    final isTop = index == 0;
    final isNext = index == 1;

    // Thresholds, clamps, and stack offsets are physical pixels, matching the
    // upstream `detectDragGestures`/`graphicsLayer` semantics; rendering works
    // in logical pixels, so convert back at the transform.
    final double dpr = MediaQuery.devicePixelRatioOf(context);

    final double translationY;
    if (isTop) {
      translationY = _offsetY.value;
    } else if (isNext && _nextY.value != -1) {
      translationY = _nextY.value;
    } else if (_nextY.value != -1 && index < 5) {
      translationY = 25 * (index - 1) * 1.1;
    } else if (index < 4) {
      translationY = 25 * index * 1.1;
    } else {
      translationY = 25 * 1.1;
    }

    final double scale;
    if (isTop) {
      scale = _offsetY.value.abs().mapRange(200, 0, 0.9, 1.0);
    } else if (isNext) {
      scale = _nextScale.value > 0
          ? _nextScale.value
          : _offsetY.value.abs().mapRange(0, 200, 1 - index * 0.12, 1.0);
    } else if (_nextScale.value > 0) {
      scale = _offsetY.value.abs().mapRange(
            0,
            200,
            1 - (index - 1) * 0.12,
            1 - (index - 1) * 0.12 + (index < 5 ? 0.02 : 0),
          );
    } else {
      scale = _offsetY.value.abs().mapRange(
            0,
            200,
            1 - index * 0.12,
            1 - index * 0.12 + (index < 4 ? 0.02 : 0),
          );
    }

    return KeyedSubtree(
      key: ObjectKey(component),
      child: SizedBox(
        width: availableWidth * metrics.fillMaxWidthOffset,
        height: metrics.widgetHeight,
        child: Transform.translate(
          offset: Offset(
            isTop ? _offsetX.value / dpr : 0.0,
            translationY.clampRange(clamp) / dpr,
          ),
          child: Transform.scale(
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(metrics.cornerRadius),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x33000000),
                    blurRadius: metrics.shadowElevation,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(metrics.cornerRadius),
                child: ColoredBox(
                  color: Colors.grey,
                  child: Opacity(
                    opacity: _nextScale.value > 0 ? _nextScale.value : 1,
                    child: component.builder(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
