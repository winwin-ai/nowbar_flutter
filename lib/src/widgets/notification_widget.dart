import 'package:flutter/material.dart';

import '../metrics/dimensions.dart';
import '../models/notification_color_controller.dart';
import '../theme/now_bar_typography.dart';

/// Now Bar surface that presents an ongoing or recent notification.
///
/// The background is the [NotificationColorController.backgroundColorGradient]
/// when one is set, and the solid
/// [NotificationColorController.backgroundColor] otherwise. The [icon] is
/// rendered at 40 logical pixels and tinted through an [IconTheme] using
/// [NotificationColorController.iconColor], so any Material icon honors the
/// palette without the caller passing a color.
///
/// The vertical padding matches the reference layout; because the fixed Now
/// Bar surface height clamps it, the content is effectively centered.
class NotificationWidget extends StatelessWidget {
  /// Creates a [NotificationWidget] with a leading [icon] and two text lines.
  const NotificationWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    this.colorController = const NotificationColorController(),
  });

  /// Leading glyph, tinted with [NotificationColorController.iconColor] and
  /// laid out inside a 40 by 40 box.
  final Widget icon;

  /// Bold first line of the notification.
  final String title;

  /// Regular-weight body of the notification, ellipsized when it overflows.
  final String content;

  /// Palette applied to the background, icon, and text.
  final NotificationColorController colorController;

  @override
  Widget build(BuildContext context) {
    final Gradient? gradient = colorController.backgroundColorGradient;

    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient == null ? colorController.backgroundColor : null,
          gradient: gradient,
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: <Widget>[
                  IconTheme(
                    data: IconThemeData(
                      color: colorController.iconColor,
                      size: 40,
                    ),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(child: icon),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: NowBarTypography.fontFamily,
                            fontSize: 13,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            color: colorController.titleColor,
                          ),
                        ),
                        Text(
                          content,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: NowBarTypography.fontFamily,
                            fontSize: 13,
                            height: 1,
                            fontWeight: FontWeight.w400,
                            color: colorController.contentColor,
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
      ),
    );
  }
}
