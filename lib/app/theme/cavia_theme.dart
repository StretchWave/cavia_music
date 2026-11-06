import 'package:flutter/material.dart';
import 'cavia_colors.dart';

class CaviaTheme {
  CaviaTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CaviaColors.background,
      primaryColor: CaviaColors.vermilion,
      canvasColor: CaviaColors.backgroundElevated,
      cardColor: CaviaColors.glassSurface,
      splashFactory: InkRipple.splashFactory,
      colorScheme: const ColorScheme.dark(
        primary: CaviaColors.vermilion,
        secondary: CaviaColors.vermilionBright,
        surface: CaviaColors.surfaceDark,
        onPrimary: Colors.white,
        onSurface: CaviaColors.textIvory,
      ),
      fontFamily: null, // Uses system font with clear typographic weights
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      iconTheme: const IconThemeData(
        color: CaviaColors.textIvory,
        size: 22,
      ),
    );
  }
}

