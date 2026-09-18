import 'package:flutter/material.dart';

/// Neutral icon catalog shared by the Now Bar component widgets.
///
/// The reference app draws its interface glyphs from bundled vector drawables,
/// including third-party brand marks. This catalog covers only the neutral
/// glyphs (media transport controls, timer actions, confirmation, and share)
/// and maps each one to the closest Material icon, so the package stays
/// dependency-free and ships no branded artwork.
abstract final class NowBarIcons {
  /// Starts or resumes media playback (reference `ic_play`).
  static const IconData play = Icons.play_arrow;

  /// Pauses media playback or a running timer (reference `ic_pause`).
  static const IconData pause = Icons.pause;

  /// Skips to the next media item (reference `ic_next`).
  static const IconData skipNext = Icons.skip_next;

  /// Returns to the previous media item (reference `ic_prev`).
  static const IconData skipPrevious = Icons.skip_previous;

  /// Restarts a finished timer (reference `ic_timer_reset`).
  static const IconData restart = Icons.replay;

  /// Identifies a timer surface (reference `ic_timer_running`).
  static const IconData timer = Icons.timer;

  /// Confirms completion, such as a finished timer.
  static const IconData check = Icons.check;

  /// Shares content with another app or a shared experience (reference
  /// `ic_shared_experiences`).
  static const IconData share = Icons.share;
}
