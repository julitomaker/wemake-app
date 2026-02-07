import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// WEMAKE Design System
/// Filosofia: Clara, firme, sobria, inteligente
/// No es: motivacional toxica, espiritual sin datos, condescendiente, ruidosa
class AppTheme {
  AppTheme._();

  // ===================
  // COLORS
  // ===================

  // Primary - Deep confident blue
  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color primaryLight = Color(0xFF16213E);
  static const Color primaryDark = Color(0xFF0F0F1A);

  // Accent - Electric energy
  static const Color accentColor = Color(0xFF00D9FF);
  static const Color accentLight = Color(0xFF5EEAD4);
  static const Color accentDark = Color(0xFF0891B2);

  // Success - Achievement green
  static const Color successColor = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  // Warning - Attention amber
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  // Error - Alert red
  static const Color errorColor = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  // Streak Fire colors
  static const Color streakFireLight = Color(0xFFFF9500);
  static const Color streakFirePerfect = Color(0xFFFF3B30);

  // Neutrals
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // Background
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF0A0A0F);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1A1A2E);

  // ===================
  // GRADIENTS
  // ===================

  static const LinearGradient brandGlow = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient wellnessGlow = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient trainingGlow = LinearGradient(
    colors: [Color(0xFFB8FF00), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassSurface = LinearGradient(
    colors: [
      Color(0x1FFFFFFF),
      Color(0x08FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const SweepGradient scoreRingGradient = SweepGradient(
    colors: [
      Color(0xFF22D3EE),
      Color(0xFF10B981),
      Color(0xFF14F0C6),
    ],
  );

  // ===================
  // GLASS UI
  // ===================

  static const double glassBlur = 18;
  static const Color glassBorder = Color(0x14FFFFFF);
  static const Color glassFill = Color(0x0FFFFFFF);

  static BoxDecoration glassBoxDecoration({double radius = radiusXl}) {
    return BoxDecoration(
      gradient: glassSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: glassBorder),
    );
  }

  // ===================
  // TYPOGRAPHY
  // ===================

  static const String fontFamily = 'Inter';
  static const String numberFontFamily = 'SpaceGrotesk';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.22,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.33,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  static TextStyle get numberDisplayLarge => GoogleFonts.spaceGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.05,
      );

  static TextStyle get numberDisplayMedium => GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.1,
      );

  static TextStyle get numberDisplaySmall => GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.1,
      );

  // ===================
  // SPACING
  // ===================

  static const double spacingXxs = 4;
  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // ===================
  // BORDER RADIUS
  // ===================

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;

  // ===================
  // SHADOWS
  // ===================

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // ===================
  // LIGHT THEME
  // ===================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,

      // Colors
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        onSecondary: primaryColor,
        surface: surfaceLight,
        onSurface: neutral900,
        error: errorColor,
        onError: Colors.white,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: backgroundLight,
        foregroundColor: neutral900,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: neutral900,
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        elevation: 0,
        color: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: neutral200),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neutral100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        hintStyle: bodyMedium.copyWith(color: neutral400),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: neutral400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: neutral200,
        thickness: 1,
        space: 1,
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return successColor;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return neutral400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return successColor;
          }
          return neutral200;
        }),
      ),
    );
  }

  // ===================
  // DARK THEME
  // ===================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,

      // Colors
      primaryColor: accentColor,
      scaffoldBackgroundColor: backgroundDark,

      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        onPrimary: primaryDark,
        secondary: accentLight,
        onSecondary: primaryDark,
        surface: surfaceDark,
        onSurface: neutral100,
        error: errorLight,
        onError: primaryDark,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: backgroundDark,
        foregroundColor: neutral100,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: neutral100,
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        elevation: 0,
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: neutral700),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: accentColor,
          foregroundColor: primaryDark,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neutral800,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        hintStyle: bodyMedium.copyWith(color: neutral500),
      ),

      // Text Theme (with light colors)
      textTheme: TextTheme(
        displayLarge: displayLarge.copyWith(color: neutral100),
        displayMedium: displayMedium.copyWith(color: neutral100),
        displaySmall: displaySmall.copyWith(color: neutral100),
        headlineLarge: headlineLarge.copyWith(color: neutral100),
        headlineMedium: headlineMedium.copyWith(color: neutral100),
        headlineSmall: headlineSmall.copyWith(color: neutral100),
        titleLarge: titleLarge.copyWith(color: neutral100),
        titleMedium: titleMedium.copyWith(color: neutral100),
        titleSmall: titleSmall.copyWith(color: neutral100),
        bodyLarge: bodyLarge.copyWith(color: neutral200),
        bodyMedium: bodyMedium.copyWith(color: neutral200),
        bodySmall: bodySmall.copyWith(color: neutral300),
        labelLarge: labelLarge.copyWith(color: neutral100),
        labelMedium: labelMedium.copyWith(color: neutral200),
        labelSmall: labelSmall.copyWith(color: neutral300),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentColor,
        unselectedItemColor: neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: neutral700,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
