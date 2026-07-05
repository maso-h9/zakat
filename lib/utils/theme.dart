import 'package:flutter/material.dart';

class ZakatTheme {
  // ==============================
  // الألوان الرئيسية
  // ==============================

  static const Color deepGreen = Color(0xFF0D4A2F);
  static const Color midGreen = Color(0xFF1A6B44);
  static const Color lightGreen = Color(0xFF2E8B57);
  static const Color gold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFE8C84A);
  static const Color paleGold = Color(0xFFF5E6A3);
  static const Color cream = Color(0xFFFAF6EE);
  static const Color warmWhite = Color(0xFFFFFDF7);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color medText = Color(0xFF4A4A6A);
  static const Color lightText = Color(0xFF8A8AAA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF0EBE0);
  static const Color error = Color(0xFFB83232);
  static const Color success = Color(0xFF2E8B57);
  static const Color primaryGreen = deepGreen;
  static const Color goldColor = gold;

  // Dark Mode Colors
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2A2A2A);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);

  // ==============================
  // تدرجات
  // ==============================
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepGreen, midGreen, lightGreen],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB8860B), gold, lightGold],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFDF7), Color(0xFFF5EDD8)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A3020), deepGreen],
  );

  static const LinearGradient darkModeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A2A1A), Color(0xFF1A4A2F)],
  );

  // ==============================
  // ThemeData الرئيسي (Light)
  // ==============================
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Scheherazade',
        colorScheme: ColorScheme.light(
          primary: deepGreen,
          secondary: gold,
          surface: warmWhite,
          background: cream,
          onPrimary: Colors.white,
          onSecondary: darkText,
          onSurface: darkText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: deepGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: cream,
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 4,
          shadowColor: deepGreen.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: deepGreen,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: deepGreen.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: warmWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDD5C0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: deepGreen, width: 2),
          ),
          labelStyle: const TextStyle(
            fontFamily: 'Scheherazade',
            color: medText,
            fontSize: 16,
          ),
          hintStyle: const TextStyle(
            fontFamily: 'Scheherazade',
            color: lightText,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 18,
            color: darkText,
            height: 1.8,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 16,
            color: medText,
            height: 1.7,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 14,
            color: lightText,
          ),
        ),
      );

  // ==============================
  // ThemeData الداكن (Dark Mode)
  // ==============================
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Scheherazade',
        colorScheme: const ColorScheme.dark(
          primary: lightGreen,
          secondary: gold,
          surface: darkSurface,
          background: darkBg,
          onPrimary: Colors.white,
          onSecondary: darkText,
          onSurface: darkTextPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A2A1A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: darkBg,
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: midGreen,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: midGreen.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lightGreen, width: 2),
          ),
          labelStyle: const TextStyle(
            fontFamily: 'Scheherazade',
            color: darkTextSecondary,
            fontSize: 16,
          ),
          hintStyle: const TextStyle(
            fontFamily: 'Scheherazade',
            color: darkTextSecondary,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: darkTextPrimary,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: darkTextPrimary,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkTextPrimary,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkTextPrimary,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: darkTextPrimary,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 18,
            color: darkTextPrimary,
            height: 1.8,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 16,
            color: darkTextSecondary,
            height: 1.7,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 14,
            color: darkTextSecondary,
          ),
        ),
        dividerColor: darkBorder,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: darkSurface,
          selectedItemColor: gold,
          unselectedItemColor: darkTextSecondary,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith(
              (s) => s.contains(MaterialState.selected) ? gold : Colors.grey),
          trackColor: MaterialStateProperty.resolveWith((s) =>
              s.contains(MaterialState.selected)
                  ? gold.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.3)),
        ),
      );

  // ==============================
  // ظل مخصص
  // ==============================
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: deepGreen.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get darkCardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get goldShadow => [
        BoxShadow(
          color: gold.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // Helper: card bg adaptive
  static Color cardBgAdaptive(bool isDark) => isDark ? darkCard : cardBg;

  static Color scaffoldBgAdaptive(bool isDark) => isDark ? darkBg : cream;

  static List<BoxShadow> cardShadowAdaptive(bool isDark) =>
      isDark ? darkCardShadow : cardShadow;
}
