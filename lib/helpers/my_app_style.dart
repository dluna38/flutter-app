
import 'package:flutter/material.dart';

class MyAppStyle {
  // Colores para el modo oscuro
  static const Color primaryGreenDark = Color(0xFF5A8E4C);
  static const Color darkBackground = Color(0xFF121212);
  static const Color surfaceColorDark = Color(0xFF1E1E1E); //background deprecated
  static const Color lightTextColorDark = Color(0xFFE0E0E0);
  static const Color darkTextColorDark = Color(0xFF8A8A8A);

// Colores para el modo claro
  static const Color primaryGreenLight = Color(0xFF6B9B5C);
  static const Color lightBackground = Color(0xFFF0F0F0);
  static const Color surfaceColorLight = Color(0xFFFFFFFF);
  static const Color darkTextColorLight = Color(0xFF333333);
  static const Color lightTextColorLight = Color(0xFF6A6A6A);

// Tema para el modo oscuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreenDark,
    scaffoldBackgroundColor: darkBackground,
    cardColor: surfaceColorDark,

    colorScheme: const ColorScheme.dark(
      primary: primaryGreenDark,
      surface: surfaceColorDark,
      onSurface: lightTextColorDark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightTextColorDark),
      bodyMedium: TextStyle(color: lightTextColorDark),
      // Puedes definir más estilos de texto aquí
    ),
  );

// Tema para el modo claro
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreenLight,
    scaffoldBackgroundColor: lightBackground,
    cardColor: surfaceColorLight,
    colorScheme: const ColorScheme.light(
      primary: primaryGreenLight,
      surface: surfaceColorLight,
      onSurface: darkTextColorLight,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextColorLight),
      bodyMedium: TextStyle(color: darkTextColorLight),
      // Puedes definir más estilos de texto aquí
    ),
  );
}
