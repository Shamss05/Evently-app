import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppColors appColors;

  AppTheme(this.appColors);

  ThemeData get theme => ThemeData(
    colorScheme: ColorScheme(
      brightness: appColors.brightness,
      primary: appColors.mainColor,
      onPrimary: appColors.inputColor,
      secondary: appColors.mainTextColor,
      onSecondary: appColors.inputColor,
      error: appColors.errorColor,
      onError: appColors.inputColor,
      surface: appColors.backgroundColor,
      onSurface: appColors.mainColor,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: appColors.backgroundColor,
      foregroundColor: appColors.mainTextColor,
      centerTitle: true,
      shadowColor: Colors.transparent,
      elevation: 0,
    ),
    scaffoldBackgroundColor: appColors.backgroundColor,
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: appColors.inputColor,
      contentPadding: EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      prefixIconColor: appColors.mainTextColor,
      suffixIconColor: appColors.mainTextColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(width: 1, color: appColors.strokeColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(width: 1, color: appColors.strokeColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(width: 1, color: appColors.strokeColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(width: 1, color: appColors.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(width: 1, color: appColors.errorColor),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: EdgeInsets.all(16),
        minimumSize: Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TextStyle(fontSize: 16, fontWeight: .bold),
        foregroundColor: Colors.white
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16),
          minimumSize: Size(double.infinity, 56),
          backgroundColor: appColors.mainColor.withAlpha(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: TextStyle(fontSize: 16, fontWeight: .bold),
          foregroundColor: appColors.mainColor
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: appColors.mainTextColor),
      displayMedium: TextStyle(color: appColors.mainTextColor),
      displaySmall: TextStyle(color: appColors.mainTextColor),
      headlineLarge: TextStyle(color: appColors.mainTextColor),
      headlineMedium: TextStyle(color: appColors.mainTextColor),
      headlineSmall: TextStyle(color: appColors.mainTextColor),
      titleLarge: TextStyle(color: appColors.mainTextColor),
      titleMedium: TextStyle(color: appColors.mainTextColor),
      titleSmall: TextStyle(color: appColors.mainTextColor),
      bodyLarge: TextStyle(color: appColors.mainTextColor),
      bodyMedium: TextStyle(color: appColors.mainTextColor),
      bodySmall: TextStyle(color: appColors.mainTextColor),
      labelLarge: TextStyle(color: appColors.mainTextColor),
      labelMedium: TextStyle(color: appColors.mainTextColor),
      labelSmall: TextStyle(color: appColors.mainTextColor),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: appColors.mainColor,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),
  );
}
