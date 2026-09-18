import 'package:flutter/material.dart';

/// Color seeds and Material color schemes used by Now Bar surfaces.
///
/// The six seeds port the reference theme's color definitions one-to-one: a
/// purple, a purple-grey, and a pink swatch for each brightness. The light
/// scheme assigns the `40` swatches to the `primary`, `secondary`, and
/// `tertiary` roles and the dark scheme assigns the `80` swatches, matching
/// the reference theme's role assignments.
///
/// The reference theme also offers Android 12+ dynamic color. Dynamic color is
/// derived from the host wallpaper and has no portable equivalent in Flutter,
/// so it is intentionally omitted here; the schemes below are stable on every
/// platform.
abstract final class NowBarColors {
  /// Dark-theme primary seed (`0xFFD0BCFF`), ported from the reference
  /// theme's purple-80 swatch.
  static const Color purple80 = Color(0xFFD0BCFF);

  /// Dark-theme secondary seed (`0xFFCCC2DC`), ported from the reference
  /// theme's purple-grey-80 swatch.
  static const Color purpleGrey80 = Color(0xFFCCC2DC);

  /// Dark-theme tertiary seed (`0xFFEFB8C8`), ported from the reference
  /// theme's pink-80 swatch.
  static const Color pink80 = Color(0xFFEFB8C8);

  /// Light-theme primary seed (`0xFF6650A4`), ported from the reference
  /// theme's purple-40 swatch.
  static const Color purple40 = Color(0xFF6650A4);

  /// Light-theme secondary seed (`0xFF625B71`), ported from the reference
  /// theme's purple-grey-40 swatch.
  static const Color purpleGrey40 = Color(0xFF625B71);

  /// Light-theme tertiary seed (`0xFF7D5260`), ported from the reference
  /// theme's pink-40 swatch.
  static const Color pink40 = Color(0xFF7D5260);

  /// Light Material 3 color scheme for Now Bar surfaces.
  ///
  /// The scheme is generated from [purple40] so the remaining roles follow the
  /// Material 3 tonal system, then the reference theme's exact `primary`,
  /// `secondary`, and `tertiary` seeds are pinned on top of the generated
  /// values.
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: purple40,
    brightness: Brightness.light,
  ).copyWith(primary: purple40, secondary: purpleGrey40, tertiary: pink40);

  /// Dark Material 3 color scheme for Now Bar surfaces.
  ///
  /// Like [lightColorScheme], the scheme is generated from [purple40] so the
  /// remaining roles follow the Material 3 tonal system, then the reference
  /// theme's exact `primary`, `secondary`, and `tertiary` seeds for dark
  /// surfaces are pinned on top of the generated values.
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: purple40,
    brightness: Brightness.dark,
  ).copyWith(primary: purple80, secondary: purpleGrey80, tertiary: pink80);
}
