import 'package:flutter/material.dart';

/// Material color + typography theme helper.
///
/// This file is based on `/assets/theme.dart` and placed under `lib/` so it can
/// be imported by app code.
///
/// Note: adjusted `scaffoldBackgroundColor` to use `colorScheme.surface` to
/// avoid deprecated `ColorScheme.background`.
class MaterialTheme {
  /// The base `TextTheme` used when building the final `ThemeData`.
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff505b92),
      surfaceTint: Color(0xff505b92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffdde1ff),
      onPrimaryContainer: Color(0xff384379),
      secondary: Color(0xff5a5d72),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffdfe1f9),
      onSecondaryContainer: Color(0xff434659),
      tertiary: Color(0xff76546e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffd7f3),
      onTertiaryContainer: Color(0xff5c3c55),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffbf8ff),
      onSurface: Color(0xff1b1b21),
      onSurfaceVariant: Color(0xff45464f),
      outline: Color(0xff767680),
      outlineVariant: Color(0xffc6c5d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303036),
      inversePrimary: Color(0xffb9c3ff),
      primaryFixed: Color(0xffdde1ff),
      onPrimaryFixed: Color(0xff08164b),
      primaryFixedDim: Color(0xffb9c3ff),
      onPrimaryFixedVariant: Color(0xff384379),
      secondaryFixed: Color(0xffdfe1f9),
      onSecondaryFixed: Color(0xff171b2c),
      secondaryFixedDim: Color(0xffc3c5dd),
      onSecondaryFixedVariant: Color(0xff434659),
      tertiaryFixed: Color(0xffffd7f3),
      onTertiaryFixed: Color(0xff2d1228),
      tertiaryFixedDim: Color(0xffe5bad8),
      onTertiaryFixedVariant: Color(0xff5c3c55),
      surfaceDim: Color(0xffdbd9e0),
      surfaceBright: Color(0xfffbf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff5f2fa),
      surfaceContainer: Color(0xffefedf4),
      surfaceContainerHigh: Color(0xffe9e7ef),
      surfaceContainerHighest: Color(0xffe3e1e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff273267),
      surfaceTint: Color(0xff505b92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff5f6aa2),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff323548),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff696c81),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4a2c44),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff86627d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffbf8ff),
      onSurface: Color(0xff101116),
      onSurfaceVariant: Color(0xff35363e),
      outline: Color(0xff51525b),
      outlineVariant: Color(0xff6c6c76),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303036),
      inversePrimary: Color(0xffb9c3ff),
      primaryFixed: Color(0xff5f6aa2),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff465188),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff696c81),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff515468),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff86627d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff6c4a64),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc7c5cd),
      surfaceBright: Color(0xfffbf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff5f2fa),
      surfaceContainer: Color(0xffe9e7ef),
      surfaceContainerHigh: Color(0xffdedce3),
      surfaceContainerHighest: Color(0xffd2d1d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1c285c),
      surfaceTint: Color(0xff505b92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff3a467b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff282b3d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff45485c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3f223a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff5f3f58),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffbf8ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2b2c34),
      outlineVariant: Color(0xff484851),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303036),
      inversePrimary: Color(0xffb9c3ff),
      primaryFixed: Color(0xff3a467b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff232f63),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff45485c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff2e3244),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff5f3f58),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff462941),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb9b8bf),
      surfaceBright: Color(0xfffbf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f0f7),
      surfaceContainer: Color(0xffe3e1e9),
      surfaceContainerHigh: Color(0xffd5d3db),
      surfaceContainerHighest: Color(0xffc7c5cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb9c3ff),
      surfaceTint: Color(0xffb9c3ff),
      onPrimary: Color(0xff212c61),
      primaryContainer: Color(0xff384379),
      onPrimaryContainer: Color(0xffdde1ff),
      secondary: Color(0xffc3c5dd),
      onSecondary: Color(0xff2c2f42),
      secondaryContainer: Color(0xff434659),
      onSecondaryContainer: Color(0xffdfe1f9),
      tertiary: Color(0xffe5bad8),
      onTertiary: Color(0xff44263e),
      tertiaryContainer: Color(0xff5c3c55),
      onTertiaryContainer: Color(0xffffd7f3),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff121318),
      onSurface: Color(0xffe3e1e9),
      onSurfaceVariant: Color(0xffc6c5d0),
      outline: Color(0xff90909a),
      outlineVariant: Color(0xff45464f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e1e9),
      inversePrimary: Color(0xff505b92),
      primaryFixed: Color(0xffdde1ff),
      onPrimaryFixed: Color(0xff08164b),
      primaryFixedDim: Color(0xffb9c3ff),
      onPrimaryFixedVariant: Color(0xff384379),
      secondaryFixed: Color(0xffdfe1f9),
      onSecondaryFixed: Color(0xff171b2c),
      secondaryFixedDim: Color(0xffc3c5dd),
      onSecondaryFixedVariant: Color(0xff434659),
      tertiaryFixed: Color(0xffffd7f3),
      onTertiaryFixed: Color(0xff2d1228),
      tertiaryFixedDim: Color(0xffe5bad8),
      onTertiaryFixedVariant: Color(0xff5c3c55),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff38393f),
      surfaceContainerLowest: Color(0xff0d0e13),
      surfaceContainerLow: Color(0xff1b1b21),
      surfaceContainer: Color(0xff1f1f25),
      surfaceContainerHigh: Color(0xff292a2f),
      surfaceContainerHighest: Color(0xff34343a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd5daff),
      surfaceTint: Color(0xffb9c3ff),
      onPrimary: Color(0xff152155),
      primaryContainer: Color(0xff828dc8),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffd9dbf3),
      onSecondary: Color(0xff212537),
      secondaryContainer: Color(0xff8d8fa6),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffccfef),
      onTertiary: Color(0xff381c33),
      tertiaryContainer: Color(0xffac85a1),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff121318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdcdbe6),
      outline: Color(0xffb1b1bb),
      outlineVariant: Color(0xff908f99),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e1e9),
      inversePrimary: Color(0xff39447a),
      primaryFixed: Color(0xffdde1ff),
      onPrimaryFixed: Color(0xff000a3e),
      primaryFixedDim: Color(0xffb9c3ff),
      onPrimaryFixedVariant: Color(0xff273267),
      secondaryFixed: Color(0xffdfe1f9),
      onSecondaryFixed: Color(0xff0d1021),
      secondaryFixedDim: Color(0xffc3c5dd),
      onSecondaryFixedVariant: Color(0xff323548),
      tertiaryFixed: Color(0xffffd7f3),
      onTertiaryFixed: Color(0xff21071d),
      tertiaryFixedDim: Color(0xffe5bad8),
      onTertiaryFixedVariant: Color(0xff4a2c44),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff44444a),
      surfaceContainerLowest: Color(0xff06070c),
      surfaceContainerLow: Color(0xff1d1d23),
      surfaceContainer: Color(0xff27272d),
      surfaceContainerHigh: Color(0xff323238),
      surfaceContainerHighest: Color(0xff3d3d43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffefefff),
      surfaceTint: Color(0xffb9c3ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffb4bffd),
      onPrimaryContainer: Color(0xff00062f),
      secondary: Color(0xffefefff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffbfc1d9),
      onSecondaryContainer: Color(0xff070a1b),
      tertiary: Color(0xffffeaf6),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffe1b6d4),
      onTertiaryContainer: Color(0xff1a0317),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff121318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff0effa),
      outlineVariant: Color(0xffc2c1cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e1e9),
      inversePrimary: Color(0xff39447a),
      primaryFixed: Color(0xffdde1ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffb9c3ff),
      onPrimaryFixedVariant: Color(0xff000a3e),
      secondaryFixed: Color(0xffdfe1f9),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc3c5dd),
      onSecondaryFixedVariant: Color(0xff0d1021),
      tertiaryFixed: Color(0xffffd7f3),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffe5bad8),
      onTertiaryFixedVariant: Color(0xff21071d),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff4f4f56),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1f1f25),
      surfaceContainer: Color(0xff303036),
      surfaceContainerHigh: Color(0xff3b3b41),
      surfaceContainerHighest: Color(0xff46464c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
