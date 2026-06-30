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

  static TextTheme _textTheme(TextTheme base, {bool bengali = false}) {
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
    if (!bengali) return sized;
    return GoogleFonts.notoSansBengaliTextTheme(sized);
  }

  static ThemeData light({bool bengali = false}) {
    const primary = Color(0xFF4CAF50);
    const bg = Color(0xFFF1F8E9);

    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: const Color(0xFF66BB6A),
        error: const Color(0xFFE53935),
        surface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
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
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingL,
          vertical: paddingM,
        ),
        errorStyle: const TextStyle(
          fontSize: fontSizeS,
          color: Color(0xFFE53935),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusM)),
        ),
        contentTextStyle: TextStyle(fontSize: fontSizeM),
      ),
      textTheme: _textTheme(base.textTheme, bengali: bengali),
    );
  }

  static ThemeData dark({bool bengali = false}) {
    const primary = Color(0xFF66BB6A);
    const bg = Color(0xFF121212);

    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: const Color(0xFF81C784),
        error: const Color(0xFFEF5350),
        surface: const Color(0xFF1E1E1E),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSizeXXL,
          fontWeight: FontWeight.bold,
          fontFamily: bengali ? GoogleFonts.notoSansBengali().fontFamily : null,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E1E1E),
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
        fillColor: const Color(0xFF1E1E1E),
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
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusM)),
        ),
        contentTextStyle: TextStyle(fontSize: fontSizeM, color: Colors.white),
      ),
      textTheme: _textTheme(base.textTheme, bengali: bengali),
    );
  }
}
