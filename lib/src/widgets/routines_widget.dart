import 'package:flutter/material.dart';

import '../metrics/dimensions.dart';
import '../theme/now_bar_icons.dart';
import '../theme/now_bar_typography.dart';

/// Solid background of the routines surface, from the reference palette.
const Color _routinesBackground = Color(0xFF303164);

/// Muted label color of the routines surface, from the reference palette.
const Color _routinesLabelColor = Color(0xFF6E85B3);

/// Now Bar surface that presents the state of the device's routines.
///
/// The surface shows the neutral routines glyph, a small muted [title], and a
/// bold white [content] line. The default title is `'Routines'`; the reference
/// app labels it with a vendor name, which this package deliberately avoids.
class RoutinesWidget extends StatelessWidget {
  /// Creates a [RoutinesWidget] with a [title] and a [content] line.
  const RoutinesWidget({
    super.key,
    this.title = 'Routines',
    required this.content,
  });

  /// Muted line shown above [content].
  final String title;

  /// Prominent line describing the running routines.
  final String content;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
      child: ColoredBox(
        color: _routinesBackground,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(NowBarIcons.check, size: 40, color: Colors.white),
                const SizedBox(width: 15),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: NowBarTypography.fontFamily,
                          fontSize: 11,
                          height: 1,
                          fontWeight: FontWeight.w400,
                          color: _routinesLabelColor,
                        ),
                      ),
                      Text(
                        content,
                        style: const TextStyle(
                          fontFamily: NowBarTypography.fontFamily,
                          fontSize: 16,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
