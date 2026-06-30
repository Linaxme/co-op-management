import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Consistent spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;

  // Consistent font sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeTitle = 24.0;

  // Consistent border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  static TextStyle? _paint(TextStyle? style, Color color) =>
      style?.copyWith(color: color);

  static TextTheme _buildTextTheme({
    required TextTheme base,
    required Color bodyColor,
    required Color mutedColor,
    required Color displayColor,
    bool bengali = false,
  }) {
    final sized = base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: fontSizeTitle),
      displayMedium: base.displayMedium?.copyWith(fontSize: fontSizeXXL),
      displaySmall: base.displaySmall?.copyWith(fontSize: fontSizeXL),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: fontSizeXL),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: fontSizeL,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(fontSize: fontSizeL),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: fontSizeM),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: fontSizeM),
      bodySmall: base.bodySmall?.copyWith(fontSize: fontSizeS),
      labelLarge: base.labelLarge?.copyWith(fontSize: fontSizeM),
    );

    final themed =
        bengali ? GoogleFonts.notoSansBengaliTextTheme(sized) : sized;

    // Google Fonts can bake in dark colors — set explicitly for dark mode.
    return themed.copyWith(
      displayLarge: _paint(themed.displayLarge, displayColor),
      displayMedium: _paint(themed.displayMedium, displayColor),
      displaySmall: _paint(themed.displaySmall, displayColor),
      headlineLarge: _paint(themed.headlineLarge, displayColor),
      headlineMedium: _paint(themed.headlineMedium, displayColor),
      headlineSmall: _paint(themed.headlineSmall, displayColor),
      titleLarge: _paint(themed.titleLarge, bodyColor),
      titleMedium: _paint(themed.titleMedium, bodyColor),
      titleSmall: _paint(themed.titleSmall, bodyColor),
      bodyLarge: _paint(themed.bodyLarge, bodyColor),
      bodyMedium: _paint(themed.bodyMedium, bodyColor),
      bodySmall: _paint(themed.bodySmall, mutedColor),
      labelLarge: _paint(themed.labelLarge, bodyColor),
      labelMedium: _paint(themed.labelMedium, mutedColor),
      labelSmall: _paint(themed.labelSmall, mutedColor),
    );
  }

  static ThemeData light({bool bengali = false}) {
    const primary = Color(0xFF4CAF50);
    const bg = Color(0xFFF1F8E9);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: Colors.white,
      error: const Color(0xFFE53935),
    );

    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _buildTextTheme(
      base: base.textTheme,
      bodyColor: colorScheme.onSurface,
      mutedColor: colorScheme.onSurfaceVariant,
      displayColor: colorScheme.onSurface,
      bengali: bengali,
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: colorScheme,
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      primaryIconTheme: IconThemeData(color: colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: fontSizeXXL,
          fontWeight: FontWeight.bold,
          fontFamily: bengali ? GoogleFonts.notoSansBengali().fontFamily : null,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: paddingL,
          vertical: paddingS,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
        ),
        floatingLabelStyle: TextStyle(color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFFC8E6C9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFFC8E6C9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingL,
          vertical: paddingM,
        ),
        errorStyle: TextStyle(
          fontSize: fontSizeS,
          color: colorScheme.error,
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurfaceVariant,
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
      expansionTileTheme: ExpansionTileThemeData(
        textColor: colorScheme.onSurface,
        collapsedTextColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurfaceVariant,
        collapsedIconColor: colorScheme.onSurfaceVariant,
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: fontSizeS,
            color: states.contains(WidgetState.selected)
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: fontSizeXL,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: fontSizeM,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: colorScheme.onSurface, fontSize: fontSizeM),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        textStyle: TextStyle(color: colorScheme.onSurface, fontSize: fontSizeM),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: colorScheme.onSurface, fontSize: fontSizeS),
        secondaryLabelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: fontSizeS,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(radiusS),
        ),
        textStyle: TextStyle(color: colorScheme.onInverseSurface, fontSize: fontSizeS),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusM)),
        ),
        contentTextStyle: TextStyle(
          fontSize: fontSizeM,
          color: colorScheme.onInverseSurface,
        ),
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
    );
  }

  static ThemeData dark({bool bengali = false}) {
    const primary = Color(0xFF66BB6A);
    const bg = Color(0xFF121212);
    const surface = Color(0xFF1E1E1E);
    const onSurface = Color(0xFFE8E8E8);
    const onSurfaceVariant = Color(0xFFB8B8B8);

    final colorScheme = const ColorScheme.dark(
      primary: primary,
      onPrimary: Color(0xFF003910),
      primaryContainer: Color(0xFF1B5E20),
      onPrimaryContainer: Color(0xFFC8E6C9),
      secondary: Color(0xFF81C784),
      onSecondary: Color(0xFF003910),
      error: Color(0xFFEF5350),
      onError: Colors.black,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: Color(0xFF757575),
      outlineVariant: Color(0xFF424242),
      surfaceContainerHighest: Color(0xFF2C2C2C),
      inverseSurface: Color(0xFFE8E8E8),
      onInverseSurface: Color(0xFF1E1E1E),
    );

    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = _buildTextTheme(
      base: base.textTheme,
      bodyColor: onSurface,
      mutedColor: onSurfaceVariant,
      displayColor: onSurface,
      bengali: bengali,
    );

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: colorScheme,
      iconTheme: const IconThemeData(color: onSurfaceVariant),
      primaryIconTheme: const IconThemeData(color: onSurface),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: onSurface,
        iconTheme: const IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: fontSizeXXL,
          fontWeight: FontWeight.bold,
          fontFamily: bengali ? GoogleFonts.notoSansBengali().fontFamily : null,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: paddingL,
          vertical: paddingS,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: const TextStyle(color: onSurfaceVariant),
        hintStyle: TextStyle(
          color: onSurfaceVariant.withValues(alpha: 0.9),
        ),
        floatingLabelStyle: const TextStyle(color: primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingL,
          vertical: paddingM,
        ),
        errorStyle: const TextStyle(
          fontSize: fontSizeS,
          color: Color(0xFFEF5350),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: onSurface,
        iconColor: onSurfaceVariant,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF424242)),
      expansionTileTheme: const ExpansionTileThemeData(
        textColor: onSurface,
        collapsedTextColor: onSurface,
        iconColor: onSurfaceVariant,
        collapsedIconColor: onSurfaceVariant,
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: fontSizeS,
            color: states.contains(WidgetState.selected)
                ? onSurface
                : onSurfaceVariant,
          );
        }),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: onSurface,
        unselectedLabelColor: onSurfaceVariant,
        indicatorColor: primary,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        titleTextStyle: const TextStyle(
          color: onSurface,
          fontSize: fontSizeXL,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: onSurfaceVariant,
          fontSize: fontSizeM,
        ),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: onSurface, fontSize: fontSizeM),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: surface,
        textStyle: TextStyle(color: onSurface, fontSize: fontSizeM),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFF2C2C2C),
        labelStyle: TextStyle(color: onSurface, fontSize: fontSizeS),
        secondaryLabelStyle: TextStyle(
          color: onSurfaceVariant,
          fontSize: fontSizeS,
        ),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: Color(0xFFE8E8E8),
          borderRadius: BorderRadius.all(Radius.circular(radiusS)),
        ),
        textStyle: TextStyle(color: Color(0xFF1E1E1E), fontSize: fontSizeS),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusM)),
        ),
        contentTextStyle: TextStyle(fontSize: fontSizeM, color: onSurface),
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
    );
  }
}
