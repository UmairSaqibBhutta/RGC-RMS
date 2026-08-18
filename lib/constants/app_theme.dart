import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/constants/constants.dart';

const Color textPrimaryColor = Color(0xFF111827);
const Color textSecondaryColor = Color(0xFF374151);
const Color textMutedColor = Color(0xFF6B7280);
const Color borderColor = Color(0xFFE5E7EB);
const Color dividerColor = Color(0xFFE9EAEC);
const Color surfaceMutedColor = Color(0xFFF7F8FA);

const Color secondaryColor = Color(0xFF475569);
const Color tertiaryColor = Color(0xFFD97706);
const Color errorColor = Color(0xFFDC2626);

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: appColor,
    brightness: Brightness.light,
  ).copyWith(
    primary: appColor,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFDCF5E7),
    onPrimaryContainer: const Color(0xFF00583A),
    secondary: secondaryColor,
    onSecondary: Colors.white,
    tertiary: tertiaryColor,
    onTertiary: Colors.white,
    error: errorColor,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: textPrimaryColor,
  );

  // Lato is bundled locally under assets/fonts/Lato (see pubspec.yaml) so it
  // never needs to be fetched over the network at runtime, unlike
  // GoogleFonts.latoTextTheme()/GoogleFonts.lato().
  final baseTextTheme =
      ThemeData(useMaterial3: true).textTheme.apply(fontFamily: 'Lato');
  final textTheme = baseTextTheme.copyWith(
    headlineSmall: baseTextTheme.headlineSmall?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: textPrimaryColor,
    ),
    titleLarge: baseTextTheme.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: textPrimaryColor,
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: textPrimaryColor,
    ),
    titleSmall: baseTextTheme.titleSmall?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textPrimaryColor,
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textPrimaryColor,
    ),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textSecondaryColor,
    ),
    bodySmall: baseTextTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textMutedColor,
    ),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.2,
    ),
    labelMedium: baseTextTheme.labelMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: textSecondaryColor,
    ),
    labelSmall: baseTextTheme.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textMutedColor,
    ),
  );

  final roundedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );

  return ThemeData(
    useMaterial3: true,
    primaryColor: appColor,
    scaffoldBackgroundColor: surfaceMutedColor,
    fontFamily: 'Lato',
    textTheme: textTheme,
    colorScheme: colorScheme,
    splashFactory: InkRipple.splashFactory,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: appColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: dividerColor),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: appColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontWeight: FontWeight.w400,
      ),
    ),
    appBarTheme: AppBarTheme(
      iconTheme: const IconThemeData(color: textPrimaryColor),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: appColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: appColor.withValues(alpha: 0.4),
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size.fromHeight(50),
        shape: roundedShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: appColor,
        side: const BorderSide(color: appColor, width: 1.5),
        minimumSize: const Size.fromHeight(50),
        shape: roundedShape,
        textStyle: textTheme.labelLarge?.copyWith(color: appColor),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: appColor,
        textStyle: textTheme.labelMedium?.copyWith(
          color: appColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
