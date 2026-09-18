import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowbar_flutter/nowbar_flutter.dart';

/// Maps every style of a text theme to its style name for diagnostics.
Map<String, TextStyle?> _stylesByName(TextTheme theme) {
  return <String, TextStyle?>{
    'displayLarge': theme.displayLarge,
    'displayMedium': theme.displayMedium,
    'displaySmall': theme.displaySmall,
    'headlineLarge': theme.headlineLarge,
    'headlineMedium': theme.headlineMedium,
    'headlineSmall': theme.headlineSmall,
    'titleLarge': theme.titleLarge,
    'titleMedium': theme.titleMedium,
    'titleSmall': theme.titleSmall,
    'labelLarge': theme.labelLarge,
    'labelMedium': theme.labelMedium,
    'labelSmall': theme.labelSmall,
    'bodyLarge': theme.bodyLarge,
    'bodyMedium': theme.bodyMedium,
    'bodySmall': theme.bodySmall,
  };
}

void main() {
  group('NowBarColors', () {
    test('exposes the reference color seeds verbatim', () {
      expect(NowBarColors.purple80, const Color(0xFFD0BCFF));
      expect(NowBarColors.purpleGrey80, const Color(0xFFCCC2DC));
      expect(NowBarColors.pink80, const Color(0xFFEFB8C8));
      expect(NowBarColors.purple40, const Color(0xFF6650A4));
      expect(NowBarColors.purpleGrey40, const Color(0xFF625B71));
      expect(NowBarColors.pink40, const Color(0xFF7D5260));
    });

    test('assigns the reference seeds to the light and dark roles', () {
      final ColorScheme light = NowBarColors.lightColorScheme;
      expect(light.brightness, Brightness.light);
      expect(light.primary, NowBarColors.purple40);
      expect(light.secondary, NowBarColors.purpleGrey40);
      expect(light.tertiary, NowBarColors.pink40);

      final ColorScheme dark = NowBarColors.darkColorScheme;
      expect(dark.brightness, Brightness.dark);
      expect(dark.primary, NowBarColors.purple80);
      expect(dark.secondary, NowBarColors.purpleGrey80);
      expect(dark.tertiary, NowBarColors.pink80);
    });
  });

  group('NowBarTypography', () {
    test('maps bodyLarge exactly', () {
      const TextStyle style = NowBarTypography.bodyLarge;
      expect(style.fontFamily, 'Inter');
      expect(style.fontSize, 16);
      expect(style.fontWeight, FontWeight.w400);
      expect(style.height, 24 / 16);
      expect(style.letterSpacing, 0.5);
    });

    test('maps titleLarge exactly', () {
      const TextStyle style = NowBarTypography.titleLarge;
      expect(style.fontFamily, 'Inter');
      expect(style.fontSize, 22);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.height, 28 / 22);
      expect(style.letterSpacing, 0);
    });

    test('maps labelSmall exactly', () {
      const TextStyle style = NowBarTypography.labelSmall;
      expect(style.fontFamily, 'Inter');
      expect(style.fontSize, 11);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.height, 16 / 11);
      expect(style.letterSpacing, 0.5);
    });

    test('resolves the Inter family for every text style', () {
      final Map<String, TextStyle?> styles = _stylesByName(
        NowBarTypography.textTheme,
      );
      styles.forEach((String name, TextStyle? style) {
        expect(style, isNotNull, reason: '$name is missing');
        expect(
          style?.fontFamily,
          'Inter',
          reason: '$name must resolve to the Inter family',
        );
      });
    });
  });

  group('NowBarTheme', () {
    test('builds the light theme from the reference palette', () {
      final ThemeData theme = NowBarTheme.buildThemeData();
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, NowBarColors.purple40);
      expect(theme.colorScheme.secondary, NowBarColors.purpleGrey40);
      expect(theme.colorScheme.tertiary, NowBarColors.pink40);
      expect(theme.textTheme.bodyLarge?.fontFamily, 'Inter');
      expect(theme.textTheme.bodyLarge?.color, theme.colorScheme.onSurface);
    });

    test('builds the dark theme from the reference palette', () {
      final ThemeData theme = NowBarTheme.buildThemeData(dark: true);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, NowBarColors.purple80);
      expect(theme.colorScheme.secondary, NowBarColors.purpleGrey80);
      expect(theme.colorScheme.tertiary, NowBarColors.pink80);
      expect(theme.textTheme.bodyLarge?.fontFamily, 'Inter');
      expect(theme.textTheme.bodyLarge?.color, theme.colorScheme.onSurface);
    });

    test('honors a custom seed color for both brightnesses', () {
      final ThemeData light = NowBarTheme.buildThemeData(
        seedColor: Colors.teal,
      );
      expect(light.brightness, Brightness.light);
      expect(light.colorScheme.primary, isNot(NowBarColors.purple40));

      final ThemeData dark = NowBarTheme.buildThemeData(
        dark: true,
        seedColor: Colors.teal,
      );
      expect(dark.brightness, Brightness.dark);
      expect(dark.colorScheme.primary, isNot(NowBarColors.purple80));
    });

    testWidgets('applies the light and dark themes to descendants', (
      WidgetTester tester,
    ) async {
      ThemeData? captured;

      await tester.pumpWidget(
        NowBarTheme(
          child: Builder(
            builder: (BuildContext context) {
              captured = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured?.brightness, Brightness.light);
      expect(captured?.colorScheme.primary, NowBarColors.purple40);

      await tester.pumpWidget(
        NowBarTheme.dark(
          child: Builder(
            builder: (BuildContext context) {
              captured = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured?.brightness, Brightness.dark);
      expect(captured?.colorScheme.primary, NowBarColors.purple80);
      expect(captured?.textTheme.bodyLarge?.fontFamily, 'Inter');
    });
  });

  group('NowBarIcons', () {
    test('maps the neutral glyph catalog to Material icons', () {
      expect(NowBarIcons.play, Icons.play_arrow);
      expect(NowBarIcons.pause, Icons.pause);
      expect(NowBarIcons.skipNext, Icons.skip_next);
      expect(NowBarIcons.skipPrevious, Icons.skip_previous);
      expect(NowBarIcons.restart, Icons.replay);
      expect(NowBarIcons.timer, Icons.timer);
      expect(NowBarIcons.check, Icons.check);
      expect(NowBarIcons.share, Icons.share);
    });
  });
}
