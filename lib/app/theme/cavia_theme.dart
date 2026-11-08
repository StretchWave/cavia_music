import 'package:flutter/material.dart';
import 'cavia_colors.dart';
import 'cavia_typography.dart';
import 'cavia_glass.dart';

class CaviaTheme {
  CaviaTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CaviaColors.background,
      primaryColor: CaviaColors.vermilion,
      canvasColor: CaviaColors.backgroundElevated,
      cardColor: CaviaColors.surfaceCard,
      splashFactory: InkRipple.splashFactory,
      colorScheme: const ColorScheme.dark(
        primary: CaviaColors.vermilion,
        secondary: CaviaColors.vermilionBright,
        surface: CaviaColors.surfaceDark,
        surfaceContainerHighest: CaviaColors.surfaceCard,
        onPrimary: CaviaColors.textIvory,
        onSurface: CaviaColors.textIvory,
        error: CaviaColors.errorRed,
        outline: CaviaColors.glassBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: CaviaColors.textIvory, size: 22),
      ),
      iconTheme: const IconThemeData(
        color: CaviaColors.textIvory,
        size: 22,
      ),
      textTheme: const TextTheme(
        displayLarge: CaviaTypography.displayLarge,
        displayMedium: CaviaTypography.displayMedium,
        displaySmall: CaviaTypography.displaySmall,
        titleLarge: CaviaTypography.titleLarge,
        titleMedium: CaviaTypography.titleMedium,
        titleSmall: CaviaTypography.titleSmall,
        bodyLarge: CaviaTypography.bodyMedium,
        bodyMedium: CaviaTypography.bodyMedium,
        bodySmall: CaviaTypography.bodySmall,
        labelLarge: CaviaTypography.labelLarge,
        labelMedium: CaviaTypography.labelMedium,
        labelSmall: CaviaTypography.labelSmall,
      ),
      dividerTheme: const DividerThemeData(
        color: CaviaColors.cardBorder,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CaviaColors.overlaySheet,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CaviaGlass.radiusCard),
          side: const BorderSide(color: CaviaColors.glassBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CaviaColors.overlaySheet,
        modalBackgroundColor: CaviaColors.overlaySheet,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: CaviaTypography.labelLarge,
      ),
    );
  }
}
