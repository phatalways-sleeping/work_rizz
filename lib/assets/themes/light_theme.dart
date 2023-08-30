import 'package:flutter/material.dart';
import 'package:task_managing_application/assets/fonts/text_theme_builder.dart';

mixin LightTheme {
  static const Color primaryColor = Color(0xFF5CD669); // 5CD669
  static const Color secondaryColor = Color(0xFF9C9AFF); // 9C9AFF
  static const Color tertiaryColor = Color(0xFFEAB0FC); // 9C9AFF
  static const Color shadowColor = Color(0xFFDDDDDD); // 9C9AFF
  static const Color backgroundColor = Colors.white; // DDDDDD
  static const Color buttonColor = Color(0xFFF6BB54); // F6BB54
  static const Color errorColor = Color(0xFFFFAFAF);

  static final ThemeData theme = ThemeData(
    textTheme: TextThemeBuilder.robotoTextTheme,
    buttonTheme: const ButtonThemeData(
      buttonColor: buttonColor,
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: const ColorScheme(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: Colors.white,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onErrorContainer: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.white,
      onError: Colors.black,
      brightness: Brightness.light,
    ),
  );
}
