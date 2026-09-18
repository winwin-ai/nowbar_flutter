import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../metrics/dimensions.dart';
import '../theme/now_bar_typography.dart';

/// Translucent base color of the sports surface, from the reference palette.
const Color _sportsBaseColor = Color(0x48C1C1F3);

/// Blur sigma applied to the optional backdrop.
///
/// The reference asks for a 40dp blur; the filter operates in logical pixels,
/// so the sigma equals the reference radius.
const double _backdropBlurSigma = 40;

/// Competition line style: grey and compact.
const TextStyle _competitionStyle = TextStyle(
  fontFamily: NowBarTypography.fontFamily,
  fontSize: 10,
  height: 1,
  fontWeight: FontWeight.w400,
  color: Color(0xFFB7B7B7),
);

/// Matchup line style: white semibold.
const TextStyle _matchupStyle = TextStyle(
  fontFamily: NowBarTypography.fontFamily,
  fontSize: 13,
  height: 1,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

/// Score line style: bold orange.
const TextStyle _scoreStyle = TextStyle(
  fontFamily: NowBarTypography.fontFamily,
  fontSize: 15,
  height: 1,
  fontWeight: FontWeight.w700,
  color: Color(0xFFFA945B),
);

/// Now Bar surface that presents a live sports score.
///
/// [title] carries two lines separated by the first `'\n'`: the competition
/// goes on top in grey and the matchup below it in white. A title without a
/// separator renders as a single competition line. [content] is the bold
/// orange score line. [leading] and [trailing] are optional badges (for
/// example flags) rendered inside 40 by 40 boxes; the caller supplies the
/// imagery so no team or brand assets are bundled. [backgroundImage] is an
/// optional backdrop painted full bleed behind a large blur.
class SportsWidget extends StatelessWidget {
  /// Creates a [SportsWidget] with a [title], [content], and optional imagery.
  const SportsWidget({
    super.key,
    required this.title,
    required this.content,
    this.backgroundImage,
    this.leading,
    this.trailing,
  });

  /// Two-line heading, split on the first newline.
  final String title;

  /// Score or result line shown in orange.
  final String content;

  /// Optional full-bleed backdrop, blurred behind the text.
  final ImageProvider? backgroundImage;

  /// Optional left badge, laid out in a 40 by 40 box.
  final Widget? leading;

  /// Optional right badge, laid out in a 40 by 40 box.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final List<String> lines = title.split('\n');
    final String competition = lines.first;
    final String matchup = lines.length > 1 ? lines[1] : '';
    final ImageProvider? backdrop = backgroundImage;
    final Widget? leadingBadge = leading;
    final Widget? trailingBadge = trailing;

    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
      child: ColoredBox(
        color: _sportsBaseColor,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (backdrop != null)
              ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: _backdropBlurSigma,
                  sigmaY: _backdropBlurSigma,
                ),
                child: Image(image: backdrop, fit: BoxFit.cover),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: <Widget>[
                    if (leadingBadge != null) _TeamBadge(child: leadingBadge),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            competition,
                            textAlign: TextAlign.center,
                            style: _competitionStyle,
                          ),
                          if (lines.length > 1) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              matchup,
                              textAlign: TextAlign.center,
                              style: _matchupStyle,
                            ),
                          ],
                          const SizedBox(height: 2),
                          Text(content, style: _scoreStyle),
                        ],
                      ),
                    ),
                    if (trailingBadge != null) _TeamBadge(child: trailingBadge),
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

/// Keeps an optional badge at the reference 40 logical pixel extent.
///
/// Icon badges resolve to 40 logical pixels through the ambient [IconTheme];
/// the color is left untouched so the caller controls tinting.
class _TeamBadge extends StatelessWidget {
  const _TeamBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: const IconThemeData(size: 40),
      child: SizedBox(width: 40, height: 40, child: Center(child: child)),
    );
  }
}
