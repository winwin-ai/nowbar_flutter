import 'package:flutter/material.dart';

import 'now_bar_colors.dart';
import 'now_bar_typography.dart';

/// Wraps [child] in a Material theme configured for Now Bar surfaces.
///
/// The wrapper applies the ported Now Bar color scheme and typography to every
/// descendant, so components can read colors and text styles through
/// `Theme.of(context)`:
///
/// ```dart
/// NowBarTheme(
///   child: NowBarWidget(),
/// )
/// ```
///
/// Use [NowBarTheme.light] or [NowBarTheme.dark] to select a brightness
/// explicitly, or provide a [seedColor] to generate a custom Material 3
/// scheme from one color.
///
/// The reference theme enables Android 12+ dynamic color, which derives a
/// scheme from the device wallpaper. Flutter has no portable equivalent, so
/// dynamic color is intentionally omitted; the theme always uses the ported
/// Now Bar palette unless a [seedColor] is supplied.
class NowBarTheme extends StatelessWidget {
  /// Creates a Now Bar theme wrapper.
  ///
  /// Defaults to the light scheme; set [darkTheme] for the dark scheme.
  const NowBarTheme({
    super.key,
    required this.child,
    this.darkTheme = false,
    this.seedColor,
  });

  /// Creates a Now Bar theme wrapper that always uses the light scheme.
  const NowBarTheme.light({super.key, required this.child, this.seedColor})
      : darkTheme = false;

  /// Creates a Now Bar theme wrapper that always uses the dark scheme.
  const NowBarTheme.dark({super.key, required this.child, this.seedColor})
      : darkTheme = true;

  /// The widget below this wrapper in the tree.
  final Widget child;

  /// Whether the dark color scheme is applied.
  ///
  /// When `false` the light scheme is applied.
  final bool darkTheme;

  /// Optional seed color for a custom Material 3 scheme.
  ///
  /// When `null`, the ported Now Bar palette is used for the selected
  /// brightness. When set, [ColorScheme.fromSeed] generates the scheme for the
  /// selected brightness.
  final Color? seedColor;

  /// Builds the [ThemeData] this wrapper applies.
  ///
  /// Set [dark] to select the dark scheme and pass a [seedColor] to generate a
  /// custom Material 3 scheme instead of the ported Now Bar palette.
  ///
  /// This builder is named `buildThemeData` rather than `build` because Dart
  /// forbids a static member from sharing a name with the inherited instance
  /// [build] method of a [StatelessWidget], which cannot be renamed.
  static ThemeData buildThemeData({bool dark = false, Color? seedColor}) {
    final Brightness brightness = dark ? Brightness.dark : Brightness.light;
    final ColorScheme colorScheme = seedColor == null
        ? (dark ? NowBarColors.darkColorScheme : NowBarColors.lightColorScheme)
        : ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: NowBarTypography.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildThemeData(dark: darkTheme, seedColor: seedColor),
      child: child,
    );
  }
}
