import 'package:flutter/material.dart';

/// Typography used by Now Bar surfaces.
///
/// The reference theme bundles Inter in three weights (regular, semibold, and
/// bold) and overrides three Material 3 text styles. This package registers
/// the same family as `'Inter'` in `pubspec.yaml`, so the styles below only
/// need to reference the family name.
///
/// The reference theme expresses line height as an absolute value in scaled
/// pixels, while Flutter expresses it as a multiple of the font size, so every
/// [TextStyle.height] here is derived as `lineHeight / fontSize` to preserve
/// the exact reference metrics.
abstract final class NowBarTypography {
  /// The bundled font family every style in this class resolves to.
  static const String fontFamily = 'Inter';

  /// Primary body style (reference `bodyLarge`): Inter regular, 16px with a
  /// 24px line box (height `1.5`) and `0.5` letter spacing.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.5,
  );

  /// Prominent title style (reference `titleLarge`): Inter bold, 22px with a
  /// 28px line box and no letter spacing.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: 0,
  );

  /// Small label style (reference `labelSmall`): Inter semibold, 11px with a
  /// 16px line box and `0.5` letter spacing.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 0.5,
  );

  /// The full Material 3 text theme with the Inter family applied to every
  /// style and the three reference styles above overridden exactly.
  ///
  /// The base geometry comes from Flutter's Material 3 typography so styles
  /// the reference theme leaves untouched (such as `bodyMedium` or
  /// `displayLarge`) keep their Material 3 metrics. Styles carry no color;
  /// [NowBarTheme] colors them from the active color scheme's `onSurface`
  /// role.
  static final TextTheme textTheme = Typography.material2021()
      .englishLike
      .apply(fontFamily: fontFamily)
      .copyWith(
        bodyLarge: bodyLarge,
        titleLarge: titleLarge,
        labelSmall: labelSmall,
      );
}
