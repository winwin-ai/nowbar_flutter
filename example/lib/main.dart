import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart' hide FontFeature;
import 'package:flutter/services.dart';

const MethodChannel _timerChannel = MethodChannel('nowbar/live_timer');

const int _secondsPerMinute = 60;

const int _secondsPerHour = 60 * _secondsPerMinute;

const int _minDurationSeconds = _secondsPerMinute;

const int _maxDurationSeconds = 4 * _secondsPerHour;

const Duration _tickInterval = Duration(milliseconds: 250);

const List<int> _presetMinutes = <int>[1, 3, 5, 10, 15, 30, 60];

/// Starts the example application.
void main() => runApp(const NowBarExampleApp());

/// Root widget of the example application.
///
/// Shows a live timer on a dark Material 3 theme. The screen mirrors its
/// countdown to the host platform over the `nowbar/live_timer` channel and
/// keeps counting on its own when no host implementation is registered.
class NowBarExampleApp extends StatelessWidget {
  /// Creates the example application.
  const NowBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Now Bar Live Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        fontFamilyFallback: const <String>['NotoSansKR'],
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF503164),
          brightness: Brightness.dark,
        ),
      ),
      home: const _TimerPage(),
    );
  }
}

enum _TimerPhase { idle, running, finished }

class _TimerPage extends StatefulWidget {
  const _TimerPage();

  @override
  State<_TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<_TimerPage> {
  static const int _initialDurationSeconds = 5 * _secondsPerMinute;

  static const List<FontFeature> _tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  _TimerPhase _phase = _TimerPhase.idle;
  int _selectedSeconds = _initialDurationSeconds;
  int _sessionSeconds = _initialDurationSeconds;
  int _remainingSeconds = _initialDurationSeconds;
  bool _completedNaturally = false;
  DateTime? _endAt;
  Timer? _ticker;

  bool get _isRunning => _phase == _TimerPhase.running;

  int get _displaySeconds {
    switch (_phase) {
      case _TimerPhase.idle:
        return _selectedSeconds;
      case _TimerPhase.running:
        return _remainingSeconds;
      case _TimerPhase.finished:
        return _completedNaturally ? 0 : _selectedSeconds;
    }
  }

  bool get _usesHourFormat {
    final int referenceSeconds =
        _isRunning ? _sessionSeconds : _selectedSeconds;
    return referenceSeconds >= _secondsPerHour;
  }

  double get _progress {
    if (!_isRunning || _sessionSeconds == 0) {
      return 0;
    }
    return _remainingSeconds / _sessionSeconds;
  }

  String get _statusLabel {
    switch (_phase) {
      case _TimerPhase.idle:
        return '설정 중';
      case _TimerPhase.running:
        return '실행 중 · 잠금화면에 표시 중';
      case _TimerPhase.finished:
        return '종료됨';
    }
  }

  Color _statusColor(ColorScheme scheme) {
    switch (_phase) {
      case _TimerPhase.idle:
        return scheme.outline;
      case _TimerPhase.running:
        return scheme.primary;
      case _TimerPhase.finished:
        return scheme.onSurfaceVariant;
    }
  }

  String _formatSeconds(int totalSeconds) {
    final int safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final int hours = safeSeconds ~/ _secondsPerHour;
    final int minutes = (safeSeconds % _secondsPerHour) ~/ _secondsPerMinute;
    final int seconds = safeSeconds % _secondsPerMinute;
    final String paddedMinutes = minutes.toString().padLeft(2, '0');
    final String paddedSeconds = seconds.toString().padLeft(2, '0');
    if (_usesHourFormat) {
      final String paddedHours = hours.toString().padLeft(2, '0');
      return '$paddedHours:$paddedMinutes:$paddedSeconds';
    }
    return '$paddedMinutes:$paddedSeconds';
  }

  Future<void> _start() async {
    final int duration = _selectedSeconds;
    final DateTime endAt = DateTime.now().add(Duration(seconds: duration));
    setState(() {
      _sessionSeconds = duration;
      _remainingSeconds = duration;
      _completedNaturally = false;
      _endAt = endAt;
      _phase = _TimerPhase.running;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(_tickInterval, _onTick);
    await _send('start', <String, dynamic>{
      'seconds': duration,
      'totalSeconds': duration,
    });
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _completedNaturally = false;
      _endAt = null;
      _phase = _TimerPhase.finished;
    });
    await _send('stop');
  }

  Future<void> _send(String method, [Map<String, dynamic>? arguments]) async {
    try {
      await _timerChannel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // No host handler is registered for the channel.
    } on PlatformException {
      // The host rejected the call; the in-app countdown keeps running.
    }
  }

  void _onTick(Timer timer) {
    final DateTime? endAt = _endAt;
    if (endAt == null) {
      return;
    }
    final int milliseconds = endAt.difference(DateTime.now()).inMilliseconds;
    if (milliseconds <= 0) {
      _completeCountdown();
      return;
    }
    final int seconds = (milliseconds + 999) ~/ 1000;
    if (seconds != _remainingSeconds) {
      setState(() {
        _remainingSeconds = seconds;
      });
    }
  }

  void _completeCountdown() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _remainingSeconds = 0;
      _completedNaturally = true;
      _endAt = null;
      _phase = _TimerPhase.finished;
    });
    unawaited(_send('stop'));
  }

  void _setDuration(int seconds) {
    if (_isRunning) {
      return;
    }
    setState(() {
      _selectedSeconds =
          seconds.clamp(_minDurationSeconds, _maxDurationSeconds).toInt();
      _completedNaturally = false;
      _phase = _TimerPhase.idle;
    });
  }

  void _stepDuration(int deltaSeconds) {
    _setDuration(_selectedSeconds + deltaSeconds);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _backdropGradient(theme.colorScheme),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _buildHeader(theme),
                            const SizedBox(height: 40),
                            _buildDisplay(theme),
                            const SizedBox(height: 40),
                            _buildControls(theme),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '타이머',
          style: textTheme.labelSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '잠금화면과 실시간 정보에 표시됩니다',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildDisplay(ThemeData theme) {
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              _formatSeconds(_displaySeconds),
              key: ValueKey<_TimerPhase>(_phase),
              textAlign: TextAlign.center,
              style: textTheme.displayLarge?.copyWith(
                color: scheme.onSurface,
                fontSize: 84,
                fontWeight: FontWeight.w600,
                height: 1.1,
                fontFeatures: _tabularFigures,
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                backgroundColor: Color.alphaBlend(
                  scheme.onSurface.withAlpha(0x29),
                  scheme.surface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _statusColor(scheme),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _statusLabel,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(ThemeData theme) {
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final VoidCallback? onDecrease =
        _isRunning ? null : () => _stepDuration(-_secondsPerMinute);
    final VoidCallback? onIncrease =
        _isRunning ? null : () => _stepDuration(_secondsPerMinute);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: Color.alphaBlend(
            scheme.onSurface.withAlpha(0x10),
            scheme.surface,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '설정 시간',
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatSeconds(_selectedSeconds),
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        fontFeatures: _tabularFigures,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      for (final int minutes in _presetMinutes)
                        _buildPresetChip(minutes),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDecrease,
                        child: const Text('−1분'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onIncrease,
                        child: const Text('+1분'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _isRunning ? _stop : _start,
            child: Text(
              _isRunning ? '종료' : '시작',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(int minutes) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$minutes분'),
        selected: _selectedSeconds == minutes * _secondsPerMinute,
        onSelected: _isRunning
            ? null
            : (bool selected) => _setDuration(minutes * _secondsPerMinute),
      ),
    );
  }
}

RadialGradient _backdropGradient(ColorScheme scheme) {
  return RadialGradient(
    center: const Alignment(0, -0.3),
    radius: 1,
    colors: <Color>[
      scheme.primary.withAlpha(0x29),
      scheme.surface,
    ],
  );
}
