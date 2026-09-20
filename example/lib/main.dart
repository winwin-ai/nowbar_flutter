import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nowbar_flutter/nowbar_flutter.dart';

/// Starts the example application.
void main() {
  runApp(const NowBarExampleApp());
}

/// Root widget of the example application.
///
/// Installs the dark Now Bar theme on the [MaterialApp] so the app chrome and
/// the bar surfaces share one palette, then shows the demo page.
class NowBarExampleApp extends StatelessWidget {
  /// Creates the example application.
  const NowBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NowBar Flutter Example',
      debugShowCheckedModeBanner: false,
      theme: NowBarTheme.buildThemeData(),
      home: const _DemoPage(),
    );
  }
}

/// Full-screen page that hosts the Now Bar deck.
///
/// The composition mirrors the upstream demo: a [NowBarTheme] wraps a
/// [Scaffold] whose body is a [SafeArea] with a bottom-aligned [Align], offset
/// 50 logical pixels from the bottom edge. A short heading fills the space
/// above the deck and explains the gesture the demo answers to.
class _DemoPage extends StatelessWidget {
  /// Creates the demo page.
  const _DemoPage();

  @override
  Widget build(BuildContext context) {
    return NowBarTheme.light(
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: _backdropGradient),
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                const Positioned.fill(child: _DemoHeading()),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: NowBarWidget(
                      dragDirection: NowBarDragController.dragVertically,
                      widgets: _demoComponents,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Heading shown above the bar deck.
class _DemoHeading extends StatelessWidget {
  /// Creates the demo heading.
  const _DemoHeading();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 56, 32, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'NOW BAR',
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'A glanceable card deck for Flutter',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            'Drag the surface up or down to cycle through media, a timer, '
            'routines, a live score, and notifications.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The rotation shown by the demo, in display order.
///
/// The order mirrors the upstream demo: media player, timer, routines, sports,
/// and two notification cards. Every surface is neutral and self-contained:
/// no brand names, logos, or bundled third-party artwork. The list lives at
/// top level so its identity is stable across rebuilds, which keeps the active
/// card from resetting when the page rebuilds.
final List<NowBarComponent> _demoComponents = <NowBarComponent>[
  NowBarComponent(
    // The media card is not dismissible, matching the upstream demo: the
    // rotation always keeps at least one persistent surface.
    dismissible: false,
    builder: () => MediaPlayerWidget(
      tracks: <MediaPlayerTrack>[
        MediaPlayerTrack(
          image: _coverViolet,
          title: 'Midnight Drive',
          artist: 'Neon Atlas',
        ),
        MediaPlayerTrack(
          image: _coverAmber,
          title: 'Golden Hour',
          artist: 'Wanderlight',
        ),
        MediaPlayerTrack(
          image: _coverTeal,
          title: 'Slow Current',
          artist: 'Tidal Bloom',
        ),
      ],
    ),
  ),
  NowBarComponent(builder: () => const TimerWidget(seconds: 65)),
  NowBarComponent(
    builder: () =>
        const RoutinesWidget(content: 'At work and 2 others running'),
  ),
  NowBarComponent(
    builder: () => SportsWidget(
      title: 'ICC Champions Trophy 2025 (Final)\nIND vs NZ',
      content: 'IND won by 4 wickets',
      backgroundImage: _sportsBackdrop,
      leading: const Icon(Icons.sports_cricket, color: Colors.white),
      trailing: const Icon(Icons.emoji_events, color: Colors.white),
    ),
  ),
  NowBarComponent(
    // Neutral stand-in for a professional-network notification: the gradient
    // echoes a blue social card without using any brand name or logo.
    builder: () => const NotificationWidget(
      icon: Icon(Icons.person_search),
      title: 'Weekly reach',
      content: 'You appeared in 54 searches last week.',
      colorController: NotificationColorController(
        backgroundColorGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF0A66C2), Color(0xFFB3D5FA)],
        ),
      ),
    ),
  ),
  NowBarComponent(
    // Neutral stand-in for a delivery notification. The icon is tinted dark
    // because the leading edge of the gradient is a bright yellow.
    builder: () => const NotificationWidget(
      icon: Icon(Icons.local_shipping),
      title: 'Arriving today',
      content: 'Your order is out for delivery.',
      colorController: NotificationColorController(
        iconColor: Color(0xFF0B2A4A),
        backgroundColorGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFADC1E), Color(0xFF0D69B3)],
        ),
      ),
    ),
  ),
];

/// Full-screen backdrop: white lifting to a soft gray at the bottom, matching
/// the light stage the reference Now Bar sits on.
const LinearGradient _backdropGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF2F2F4)],
);

// ---------------------------------------------------------------------------
// Embedded artwork
// ---------------------------------------------------------------------------
//
// The upstream demo draws album covers and notification logos from bundled
// drawables. This example ships no third-party imagery: the "artwork" here is
// four 32 x 32 diagonal gradient PNGs generated locally and embedded as
// base64. The media surface blurs its cover at an 8 logical pixel sigma and
// the sports surface blurs its backdrop at 40, which hides the low resolution
// completely.

/// Decodes one of the base64 PNGs below into a [MemoryImage].
///
/// Embedding the bytes keeps the example runnable with a stock `pubspec.yaml`
/// and no asset registration. Each provider is created once and reused:
/// [MemoryImage] uses instance identity as its cache key, so constructing a
/// new one on every frame would force the decoder to run again.
MemoryImage _embeddedPng(String base64Png) =>
    MemoryImage(base64Decode(base64Png));

/// 32 x 32 indigo-to-violet gradient, used as a demo track cover.
const String _coverVioletPng =
    'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAABOUlEQVR42rXMCUeDAQAG4PevJCnd'
    '10x3zczMrDIz61yttVat1Vpr5rO2Ws1nbbXWacp0mSkSiUQiEomMSCQSiUgkEvUr3ucHPMjLMBZk'
    'moqyzCXZfWU5/ZJcmzTfXlnoqC4eqy0dry/3yCSCXDqhqPArqwKqmhl1nahpmG2SRbTyqE4R0yuX'
    'DarVVnW8XbPR2Zjoat4yaXfMuqRFn7Ia9gdbDkDdh9oOQd2HO45A3R3GY1B3Z/cJqLur5xTU3d17'
    'BurusZyDugvWC1B378AlqLvPdgXqPmm/BnUPjNyAugdHb0HdRWca1D3kugN1D7vvQd3nPA+g7lHh'
    'EdQ95n0CdV/yPYO6r/hfQN3Xpl5B3ePTb6Du68F3UPeE+AHqvhn6BHXfDn+Buu9GvkHdk/M/oO6p'
    'hV9Q973Fv38TD9ZcOeUQwAAAAABJRU5ErkJggg==';

/// 32 x 32 plum-to-amber gradient, used as a demo track cover.
const String _coverAmberPng =
    'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAABNUlEQVR42rXMbUcDAQAH8P8nSSS9'
    'SBLZTte22kPXrtvzbtfdzphKmSmVZSplplSmJ2XKVKYyZUQiIhIRSUQiIhKJRPS6T/H/fYAf5BqL'
    'r9YarLOG6wW1QdAb28wmMdEsJlva+1ttgxZbSrCnRfuIzTHm6JhwdWY9zinJOSO7coo773fPBz2L'
    'EU9B7VrRpDVD2jC7iwnvdtJb6pN3B+TyUA+o+0FKAXWvpBVQ96NhH6h7ddQH6n4y7gd1P80EQN3P'
    'sgFQ9/PJIKj7xXQI1P1yNgTqfpULg7pf58Og7jdzEVD324UoqPvdUhTU/b6ggro/LEdB3R9XVVD3'
    'p/UYqPvzZgzU/aWogbq/bmmg7m+lXlD39x0d1P1jTwd1/ywboO5f+wao+/ehAer+U4mDuv8ex0Hd'
    '/6rmPzXtTzLm29QdAAAAAElFTkSuQmCC';

/// 32 x 32 teal-to-mint gradient, used as a demo track cover.
const String _coverTealPng =
    'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAABN0lEQVR42rXMaytDAQAG4PczIUQI'
    'IUTINMthG6dtZm0zp802s45La6G10FpoLbeWW8tda6G10FporZSUklJSSsr/8Sve5wc8KFAIhcqB'
    'IpWmWBgsUYulWl2ZaCjXGyuGTZUmc5XFWj1qq5GkWoe9zjleP+Fq8LobZU/TjLfZJ7f4p1vnZ9sC'
    'vvagv2NprjO00BUOdK8GFZHFnuiyciPUuxUGdVfFVkDd+3bXQN2F/Qioe388CuquPloHddecbIK6'
    'a8+3Qd2HEjFQdzG5A+quu9oDddenDkDdDek4qLvx9hDUfSRzDOpuyp6CupsfzkDdLbkLUHdrPgHq'
    'bntKgrqPPV+Cuksv16Du9tcUqLvjLQ3q7ny/AXV3fdyBurs/M6Dunq8sqPvk9z2ou/fnEdRd/s2B'
    'uk/95f8BpgauLacKYzwAAAAASUVORK5CYII=';

/// 32 x 32 deep-blue gradient, used as the sports backdrop.
const String _sportsBackdropPng =
    'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAABL0lEQVR42rXMiypDAQAG4P8RXHIX'
    'sxmzGbMZs7sdc2Z3czbXteZuDQ1rTWtYK0lSkqQkSUqS1JKkJA/mKf7vAT5UyazVcnuNwlmrFOq6'
    '3PUqsUE90ajxNWmDzf3hFl2kVS+1GWLtxlnZ8HyHKS43JxSWZKdtSelY7Xauq1ypHiGtdm9pxEyv'
    'Z1frzfb5c7pAfiBU0IeLhsghqPugVAJ1N0bLoO5D08eg7qaZE1D3kblTUHfzwhmouyV+DupuTVyA'
    'utuSl6Du9sUrUHfH8jWo++jKDai7a+0W1F3YuAN1H0vdg7q70w+g7uObj6Du4vYTqLsn8wzq7t15'
    'AXX37b2Cuvuzb6Dugdw7qHswXwF1D+1/gLqHC5+g7pPFL1D3qYNvUHfp6AfUPVr6BXWPlf/+AfuJ'
    'FD0E9R7kAAAAAElFTkSuQmCC';

/// Decoded violet track cover, created once for a stable cache key.
final MemoryImage _coverViolet = _embeddedPng(_coverVioletPng);

/// Decoded amber track cover, created once for a stable cache key.
final MemoryImage _coverAmber = _embeddedPng(_coverAmberPng);

/// Decoded teal track cover, created once for a stable cache key.
final MemoryImage _coverTeal = _embeddedPng(_coverTealPng);

/// Decoded sports backdrop, created once for a stable cache key.
final MemoryImage _sportsBackdrop = _embeddedPng(_sportsBackdropPng);
