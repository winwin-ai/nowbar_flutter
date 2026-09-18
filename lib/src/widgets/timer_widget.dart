import 'dart:async';

import 'package:flutter/material.dart';

import '../metrics/dimensions.dart';
import '../theme/now_bar_icons.dart';
import '../theme/now_bar_typography.dart';

/// Solid background of the timer surface, from the reference palette.
const Color _timerBackground = Color(0xFF503164);

/// Accent while the countdown has passed zero, from the reference palette.
const Color _expiredColor = Color(0xFFFF4800);

/// Accent while the countdown is paused, from the reference palette.
const Color _pausedColor = Color(0xFFAF88DA);

/// Reset action tint, matching the reference's pure red.
const Color _resetColor = Color(0xFFFF0000);

/// How long the accent color takes to travel between timer states.
const Duration _colorTransition = Duration(milliseconds: 300);

/// Now Bar surface that presents a countdown timer.
///
/// The countdown starts running immediately at [seconds] and ticks once per
/// second. It keeps counting below zero, at which point the accent turns
/// [_expiredColor]; while running above zero it is white, and while paused it
/// is [_pausedColor]. The play/pause action is offered above zero, and the red
/// reset action while running. Resetting restores [seconds] and pauses.
class TimerWidget extends StatefulWidget {
  /// Creates a [TimerWidget] that counts down from [seconds].
  const TimerWidget({super.key, required this.seconds});

  /// Initial countdown length, in seconds.
  final int seconds;

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _remaining;
  bool _isRunning = true;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer _) {
      setState(() {
        _remaining -= 1;
      });
    });
  }

  void _toggleRunning() {
    setState(() {
      _isRunning = !_isRunning;
    });
    if (_isRunning) {
      _startTicker();
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _reset() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _remaining = widget.seconds;
      _isRunning = false;
    });
  }

  Color get _accentColor {
    if (_remaining < 0) {
      return _expiredColor;
    }
    return _isRunning ? Colors.white : _pausedColor;
  }

  /// Formats the remaining time as `[-]MM:SS`.
  ///
  /// The absolute value is split first, which reproduces the reference's
  /// truncation-toward-zero arithmetic without Dart's floor-style remainder.
  String get _formattedTime {
    final int absoluteSeconds = _remaining.abs();
    final String minutes = (absoluteSeconds ~/ 60).toString().padLeft(2, '0');
    final String seconds = (absoluteSeconds % 60).toString().padLeft(2, '0');
    final String sign = _remaining < 0 ? '-' : '';
    return '$sign$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
      child: ColoredBox(
        color: _timerBackground,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(begin: _accentColor, end: _accentColor),
              duration: _colorTransition,
              builder: (BuildContext context, Color? color, Widget? child) {
                final Color accent = color ?? _accentColor;
                return Row(
                  children: <Widget>[
                    Icon(NowBarIcons.timer, size: 40, color: accent),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        _formattedTime,
                        style: TextStyle(
                          fontFamily: NowBarTypography.fontFamily,
                          fontSize: 28,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                    if (_remaining >= 0)
                      _TimerButton(
                        icon: _isRunning ? NowBarIcons.pause : NowBarIcons.play,
                        iconSize: 25,
                        color: Colors.white,
                        label: 'Start or pause timer',
                        onPressed: _toggleRunning,
                      ),
                    const SizedBox(width: 10),
                    if (_isRunning)
                      _TimerButton(
                        icon: NowBarIcons.restart,
                        iconSize: 28,
                        color: _resetColor,
                        label: 'Reset timer',
                        onPressed: _reset,
                      ),
                    const SizedBox(width: 30),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Fixed 40 by 40 action that hosts a Material [IconButton].
class _TimerButton extends StatelessWidget {
  const _TimerButton({
    required this.icon,
    required this.iconSize,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final double iconSize;
  final Color color;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: label,
        icon: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}
