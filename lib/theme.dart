import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFEEF2F6);
  static const surface = Colors.white;
  static const ink = Color(0xFF1D2B36);
  static const muted = Color(0xFF5E7184);
  static const line = Color(0xFFDCE3EA);
  static const green = Color(0xFF4FAE2A);
  static const greenDark = Color(0xFF3A8F1C);
  static const greenLight = Color(0xFFE5F4DC);
  static const blue = Color(0xFF1F7AE0);
  static const blueLight = Color(0xFFE2EDFB);
  static const skyTop = Color(0xFF5C8ED6);
  static const skyBottom = Color(0xFFB2CCEE);
  static const danger = Color(0xFFE5533D);

  static const cardShadow = [
    BoxShadow(color: Color(0x101D2B36), blurRadius: 18, offset: Offset(0, 6)),
  ];
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      secondary: AppColors.blue,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  final text = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );

  return base.copyWith(
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: text.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.line,
        disabledForegroundColor: AppColors.muted,
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        side: const BorderSide(color: AppColors.line, width: 1.5),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: AppColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.green, width: 2),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: AppColors.greenLight,
      side: const BorderSide(color: AppColors.line),
      shape: const StadiumBorder(),
      labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
      checkmarkColor: AppColors.greenDark,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.greenLight,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.ink,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.green,
      dividerColor: Colors.transparent,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
