import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/nowbar_flutter.dart';

/// A 1x1 transparent PNG standing in for caller-supplied imagery.
final Uint8List _imageBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

/// Width of the simulated Now Bar slot.
const double _surfaceWidth = 320;

/// Height of the simulated Now Bar slot.
const double _surfaceHeight = 80;

/// Hosts [child] in the fixed slot the engine gives every demo surface.
Widget _surface(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: _surfaceWidth,
          height: _surfaceHeight,
          child: child,
        ),
      ),
    ),
  );
}

/// Reads the first [DecoratedBox] decoration inside a [NotificationWidget].
BoxDecoration _notificationDecoration(WidgetTester tester) {
  final DecoratedBox box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(NotificationWidget),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return box.decoration as BoxDecoration;
}

void main() {
  group('MediaPlayerWidget', () {
    final List<MediaPlayerTrack> tracks = <MediaPlayerTrack>[
      MediaPlayerTrack(
        image: MemoryImage(_imageBytes),
        title: 'Alpha',
        artist: 'First Artist',
      ),
      MediaPlayerTrack(
        image: MemoryImage(_imageBytes),
        title: 'Bravo',
        artist: 'Second Artist',
      ),
      MediaPlayerTrack(
        image: MemoryImage(_imageBytes),
        title: 'Charlie',
        artist: 'Third Artist',
      ),
    ];

    testWidgets('fills the slot and shows the first track with its controls', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_surface(MediaPlayerWidget(tracks: tracks)));

      expect(
        tester.getSize(find.byType(MediaPlayerWidget)),
        const Size(_surfaceWidth, _surfaceHeight),
      );
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('First Artist'), findsOneWidget);
      expect(find.byIcon(NowBarIcons.skipPrevious), findsOneWidget);
      expect(find.byIcon(NowBarIcons.play), findsOneWidget);
      expect(find.byIcon(NowBarIcons.skipNext), findsOneWidget);
      expect(find.byIcon(NowBarIcons.share), findsOneWidget);

      final Text title = tester.widget<Text>(find.text('Alpha'));
      expect(title.style?.fontSize, 16);
      expect(title.style?.fontWeight, FontWeight.w700);
      expect(title.maxLines, 1);
      expect(title.overflow, TextOverflow.ellipsis);

      final Text artist = tester.widget<Text>(find.text('First Artist'));
      expect(artist.style?.fontSize, 10);
      expect(artist.style?.fontWeight, FontWeight.w400);
      expect(artist.maxLines, 1);
      expect(artist.overflow, TextOverflow.ellipsis);
    });

    testWidgets('cycles the track index forwards and backwards with wrap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_surface(MediaPlayerWidget(tracks: tracks)));

      await tester.tap(find.byIcon(NowBarIcons.skipNext));
      await tester.pump();
      expect(find.text('Bravo'), findsOneWidget);

      await tester.tap(find.byIcon(NowBarIcons.skipNext));
      await tester.pump();
      expect(find.text('Charlie'), findsOneWidget);

      await tester.tap(find.byIcon(NowBarIcons.skipNext));
      await tester.pump();
      expect(find.text('Alpha'), findsOneWidget);

      await tester.tap(find.byIcon(NowBarIcons.skipPrevious));
      await tester.pump();
      expect(find.text('Charlie'), findsOneWidget);
    });

    testWidgets('toggles between play and pause locally', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_surface(MediaPlayerWidget(tracks: tracks)));

      expect(find.byIcon(NowBarIcons.play), findsOneWidget);
      expect(find.byIcon(NowBarIcons.pause), findsNothing);

      await tester.tap(find.byIcon(NowBarIcons.play));
      await tester.pump();
      expect(find.byIcon(NowBarIcons.pause), findsOneWidget);
      expect(find.byIcon(NowBarIcons.play), findsNothing);

      await tester.tap(find.byIcon(NowBarIcons.pause));
      await tester.pump();
      expect(find.byIcon(NowBarIcons.play), findsOneWidget);
      expect(find.byIcon(NowBarIcons.pause), findsNothing);
    });

    testWidgets('toggles the share tint between white and accent blue', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_surface(MediaPlayerWidget(tracks: tracks)));

      Icon shareIcon() => tester.widget<Icon>(find.byIcon(NowBarIcons.share));

      expect(shareIcon().color, Colors.white);

      await tester.tap(find.byIcon(NowBarIcons.share));
      await tester.pump();
      expect(shareIcon().color, const Color(0xFF43B3FF));

      await tester.tap(find.byIcon(NowBarIcons.share));
      await tester.pump();
      expect(shareIcon().color, Colors.white);
    });
  });

  group('NotificationWidget', () {
    testWidgets('falls back to the solid background color', (
      WidgetTester tester,
    ) async {
      const NotificationColorController colors = NotificationColorController(
        backgroundColor: Color(0xFF112233),
        iconColor: Color(0xFFFF0000),
        titleColor: Color(0xFF00FF00),
        contentColor: Color(0xFF0000FF),
      );

      await tester.pumpWidget(
        _surface(
          const NotificationWidget(
            icon: Icon(Icons.notifications),
            title: 'Title',
            content: 'Body',
            colorController: colors,
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(NotificationWidget)),
        const Size(_surfaceWidth, _surfaceHeight),
      );

      final BoxDecoration decoration = _notificationDecoration(tester);
      expect(decoration.color, const Color(0xFF112233));
      expect(decoration.gradient, isNull);

      final IconTheme iconTheme = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byIcon(Icons.notifications),
              matching: find.byType(IconTheme),
            )
            .first,
      );
      expect(iconTheme.data.size, 40);
      expect(iconTheme.data.color, const Color(0xFFFF0000));

      final Text title = tester.widget<Text>(find.text('Title'));
      expect(title.style?.fontSize, 13);
      expect(title.style?.fontWeight, FontWeight.w700);
      expect(title.style?.color, const Color(0xFF00FF00));

      final Text content = tester.widget<Text>(find.text('Body'));
      expect(content.style?.fontSize, 13);
      expect(content.style?.fontWeight, FontWeight.w400);
      expect(content.style?.color, const Color(0xFF0000FF));
      expect(content.overflow, TextOverflow.ellipsis);
    });

    testWidgets('prefers the gradient when the palette supplies one', (
      WidgetTester tester,
    ) async {
      const LinearGradient gradient = LinearGradient(
        colors: <Color>[Color(0xFF0A66C2), Color(0xFFB3D5FA)],
      );
      const NotificationColorController colors = NotificationColorController(
        backgroundColor: Color(0xFF112233),
        backgroundColorGradient: gradient,
      );

      await tester.pumpWidget(
        _surface(
          const NotificationWidget(
            icon: Icon(Icons.notifications),
            title: 'Title',
            content: 'Body',
            colorController: colors,
          ),
        ),
      );

      final BoxDecoration decoration = _notificationDecoration(tester);
      expect(decoration.gradient, gradient);
      expect(decoration.color, isNull);
    });
  });

  group('RoutinesWidget', () {
    testWidgets('renders the glyph, muted title, and bold content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _surface(const RoutinesWidget(content: 'At work and 2 others running')),
      );

      expect(
        tester.getSize(find.byType(RoutinesWidget)),
        const Size(_surfaceWidth, _surfaceHeight),
      );
      expect(find.byIcon(NowBarIcons.check), findsOneWidget);
      expect(find.text('Routines'), findsOneWidget);
      expect(find.text('At work and 2 others running'), findsOneWidget);

      final ColoredBox background = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(RoutinesWidget),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(background.color, const Color(0xFF303164));

      final Icon glyph = tester.widget<Icon>(find.byIcon(NowBarIcons.check));
      expect(glyph.size, 40);
      expect(glyph.color, Colors.white);

      final Text title = tester.widget<Text>(find.text('Routines'));
      expect(title.style?.fontSize, 11);
      expect(title.style?.fontWeight, FontWeight.w400);
      expect(title.style?.color, const Color(0xFF6E85B3));

      final Text content = tester.widget<Text>(
        find.text('At work and 2 others running'),
      );
      expect(content.style?.fontSize, 16);
      expect(content.style?.fontWeight, FontWeight.w700);
      expect(content.style?.color, Colors.white);
    });

    testWidgets('honors a caller-provided title', (WidgetTester tester) async {
      await tester.pumpWidget(
        _surface(const RoutinesWidget(title: 'Sleep mode', content: 'Bedtime')),
      );

      expect(find.text('Sleep mode'), findsOneWidget);
      expect(find.text('Bedtime'), findsOneWidget);
      expect(find.text('Routines'), findsNothing);
    });
  });

  group('SportsWidget', () {
    testWidgets('splits the title into competition and matchup lines', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _surface(
          const SportsWidget(
            title: 'ICC Champions Trophy 2025 (Final)\nIND vs NZ',
            content: 'IND won by 4 wickets',
            leading: Icon(NowBarIcons.check),
            trailing: Icon(NowBarIcons.restart),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(SportsWidget)),
        const Size(_surfaceWidth, _surfaceHeight),
      );
      expect(find.text('ICC Champions Trophy 2025 (Final)'), findsOneWidget);
      expect(find.text('IND vs NZ'), findsOneWidget);
      expect(find.text('IND won by 4 wickets'), findsOneWidget);
      expect(
        tester.getSize(find.byIcon(NowBarIcons.check)),
        const Size(40, 40),
      );
      expect(
        tester.getSize(find.byIcon(NowBarIcons.restart)),
        const Size(40, 40),
      );

      final Text competition = tester.widget<Text>(
        find.text('ICC Champions Trophy 2025 (Final)'),
      );
      expect(competition.style?.fontSize, 10);
      expect(competition.style?.fontWeight, FontWeight.w400);
      expect(competition.style?.color, const Color(0xFFB7B7B7));
      expect(competition.textAlign, TextAlign.center);

      final Text matchup = tester.widget<Text>(find.text('IND vs NZ'));
      expect(matchup.style?.fontSize, 13);
      expect(matchup.style?.fontWeight, FontWeight.w600);
      expect(matchup.style?.color, Colors.white);
      expect(matchup.textAlign, TextAlign.center);

      final Text score = tester.widget<Text>(find.text('IND won by 4 wickets'));
      expect(score.style?.fontSize, 15);
      expect(score.style?.fontWeight, FontWeight.w700);
      expect(score.style?.color, const Color(0xFFFA945B));
    });

    testWidgets('guards a title without a newline separator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _surface(
          const SportsWidget(title: 'Only competition', content: 'Score line'),
        ),
      );

      expect(find.text('Only competition'), findsOneWidget);
      expect(find.text('Score line'), findsOneWidget);
      expect(find.text(''), findsNothing);
    });
  });

  group('TimerWidget', () {
    testWidgets('ticks once per second and formats as MM:SS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_surface(const TimerWidget(seconds: 65)));

      expect(
        tester.getSize(find.byType(TimerWidget)),
        const Size(_surfaceWidth, _surfaceHeight),
      );
      expect(find.text('01:05'), findsOneWidget);
      expect(find.byIcon(NowBarIcons.timer), findsOneWidget);
      expect(find.byIcon(NowBarIcons.pause), findsOneWidget);
      expect(find.byIcon(NowBarIcons.restart), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('01:04'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('counts below zero and formats negative time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_surface(const TimerWidget(seconds: 65)));

      await tester.pump(const Duration(seconds: 66));
      expect(find.text('-00:01'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('hides the play/pause action below zero but keeps reset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_surface(const TimerWidget(seconds: 1)));

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('-00:01'), findsOneWidget);
      expect(find.byIcon(NowBarIcons.pause), findsNothing);
      expect(find.byIcon(NowBarIcons.play), findsNothing);
      expect(find.byIcon(NowBarIcons.restart), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('pauses and resumes the countdown', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_surface(const TimerWidget(seconds: 10)));

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:08'), findsOneWidget);

      await tester.tap(find.byIcon(NowBarIcons.pause));
      await tester.pump();
      expect(find.byIcon(NowBarIcons.play), findsOneWidget);
      expect(find.byIcon(NowBarIcons.pause), findsNothing);

      await tester.pump(const Duration(seconds: 5));
      expect(find.text('00:08'), findsOneWidget);

      await tester.tap(find.byIcon(NowBarIcons.play));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:07'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('resets to the initial seconds and pauses', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_surface(const TimerWidget(seconds: 30)));

      await tester.pump(const Duration(seconds: 5));
      expect(find.text('00:25'), findsOneWidget);

      await tester.tap(find.byIcon(NowBarIcons.restart));
      await tester.pump();
      expect(find.text('00:30'), findsOneWidget);
      expect(find.byIcon(NowBarIcons.play), findsOneWidget);
      expect(find.byIcon(NowBarIcons.restart), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('00:30'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('animates the accent color between its three states', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_surface(const TimerWidget(seconds: 2)));
      await tester.pump(const Duration(milliseconds: 300));

      Color accent() =>
          tester.widget<Icon>(find.byIcon(NowBarIcons.timer)).color!;

      expect(accent(), Colors.white);

      await tester.tap(find.byIcon(NowBarIcons.pause));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(accent(), const Color(0xFFAF88DA));

      await tester.tap(find.byIcon(NowBarIcons.play));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 300));
      expect(accent(), const Color(0xFFFF4800));

      await tester.pumpWidget(const SizedBox());
    });
  });
}
