import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../metrics/dimensions.dart';
import '../theme/now_bar_icons.dart';
import '../theme/now_bar_typography.dart';

/// One item of media that a [MediaPlayerWidget] can present.
///
/// The cover art is caller supplied so the package never bundles or references
/// third-party artwork or brand assets.
class MediaPlayerTrack {
  /// Creates a track with its cover [image], [title], and [artist].
  const MediaPlayerTrack({
    required this.image,
    required this.title,
    required this.artist,
  });

  /// Cover artwork for the track, painted full bleed behind the controls.
  final ImageProvider image;

  /// Prominent line of the track caption.
  final String title;

  /// Secondary line of the track caption.
  final String artist;
}

/// Now Bar surface that presents media playback state and transport controls.
///
/// The surface shows blurred cover art for the selected track with a 20% black
/// scrim, previous/play-pause/next controls, the track and artist caption, and
/// a share action. Playback is visual only: [tracks] is cycled locally and no
/// audio is played.
///
/// The horizontal inset matches the reference layout. The reference also pads
/// the control row vertically, but that padding is clamped away by the fixed
/// height of a Now Bar surface, so the row is vertically centered instead.
class MediaPlayerWidget extends StatefulWidget {
  /// Creates a [MediaPlayerWidget] that starts on the first of [tracks].
  const MediaPlayerWidget({
    super.key,
    required this.tracks,
    this.innerPadding = EdgeInsets.zero,
  });

  /// The selectable media items, in display order.
  ///
  /// When the list is empty the surface renders as an empty rounded card.
  final List<MediaPlayerTrack> tracks;

  /// Padding applied between the rounded surface and its content.
  final EdgeInsets innerPadding;

  @override
  State<MediaPlayerWidget> createState() => _MediaPlayerWidgetState();
}

/// Matches the reference blur radius of 8dp: the filter operates in logical
/// pixels, so the sigma equals the reference radius.
const double _artBlurSigma = 8;

/// Reference scrim: black at 20% opacity.
const Color _scrimColor = Color(0x33000000);

/// Tint applied to the share action while it is toggled on.
const Color _shareHighlightColor = Color(0xFF43B3FF);

/// Horizontal inset of the transport row, from the reference layout.
const EdgeInsets _rowInset = EdgeInsets.symmetric(horizontal: 30);

/// Square extent of a transport button, from the reference layout.
const double _controlExtent = 35;

/// Caption styles, sized and weighted like the reference media surface.
const TextStyle _trackTitleStyle = TextStyle(
  fontFamily: NowBarTypography.fontFamily,
  fontSize: 16,
  height: 1,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

const TextStyle _trackArtistStyle = TextStyle(
  fontFamily: NowBarTypography.fontFamily,
  fontSize: 10,
  height: 1,
  fontWeight: FontWeight.w400,
  color: Colors.white,
);

class _MediaPlayerWidgetState extends State<MediaPlayerWidget> {
  int _trackIndex = 0;
  bool _isPlaying = false;
  bool _isSharing = false;

  @override
  void didUpdateWidget(MediaPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_trackIndex >= widget.tracks.length) {
      _trackIndex = 0;
    }
  }

  void _showPreviousTrack() {
    if (widget.tracks.isEmpty) {
      return;
    }
    setState(() {
      _trackIndex =
          (_trackIndex - 1 + widget.tracks.length) % widget.tracks.length;
    });
  }

  void _showNextTrack() {
    if (widget.tracks.isEmpty) {
      return;
    }
    setState(() {
      _trackIndex = (_trackIndex + 1) % widget.tracks.length;
    });
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleSharing() {
    setState(() {
      _isSharing = !_isSharing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tracks.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
        child: const SizedBox.expand(),
      );
    }

    final MediaPlayerTrack track = widget.tracks[_trackIndex];

    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
      child: Padding(
        padding: widget.innerPadding,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _artBlurSigma,
                sigmaY: _artBlurSigma,
              ),
              child: Image(image: track.image, fit: BoxFit.cover),
            ),
            const ColoredBox(color: _scrimColor),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: _rowInset,
                child: Row(
                  children: <Widget>[
                    _TransportButton(
                      icon: NowBarIcons.skipPrevious,
                      iconSize: 25,
                      semanticLabel: 'Previous track',
                      onPressed: _showPreviousTrack,
                    ),
                    _TransportButton(
                      icon: _isPlaying ? NowBarIcons.pause : NowBarIcons.play,
                      iconSize: 20,
                      semanticLabel: _isPlaying ? 'Pause' : 'Play',
                      onPressed: _togglePlayback,
                    ),
                    _TransportButton(
                      icon: NowBarIcons.skipNext,
                      iconSize: 25,
                      semanticLabel: 'Next track',
                      onPressed: _showNextTrack,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _trackTitleStyle,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _trackArtistStyle,
                          ),
                        ],
                      ),
                    ),
                    _TransportButton(
                      icon: NowBarIcons.share,
                      iconSize: 25,
                      semanticLabel: 'Share track',
                      color: _isSharing ? _shareHighlightColor : Colors.white,
                      onPressed: _toggleSharing,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fixed-size square control that hosts a Material [IconButton].
class _TransportButton extends StatelessWidget {
  const _TransportButton({
    required this.icon,
    required this.iconSize,
    required this.semanticLabel,
    required this.onPressed,
    this.color = Colors.white,
  });

  final IconData icon;
  final double iconSize;
  final String semanticLabel;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _controlExtent,
      height: _controlExtent,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(icon, size: iconSize, color: color),
        tooltip: semanticLabel,
      ),
    );
  }
}
