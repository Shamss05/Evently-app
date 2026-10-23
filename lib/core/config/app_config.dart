import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppConfig extends ChangeNotifier {
  ThemeData get lightAppTheme => AppTheme(LightAppColors()).theme;
  ThemeData get darkAppTheme => AppTheme(DarkAppColors()).theme;
  ThemeMode themeMode;
  String locale;
  bool hasSeenOnboarding;

  AppConfig(this.locale, this.themeMode, {this.hasSeenOnboarding = false});

  bool isEn() => locale == "en";
  bool isDark() => themeMode == ThemeMode.dark;

  Future<void> changeTheme(ThemeMode theme) async {
    themeMode = theme;
    notifyListeners();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("theme", theme == ThemeMode.light);
  }

  Future<void> changeLocale(String lang) async {
    locale = lang;
    notifyListeners();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("locale", lang);
  }

  Future<void> completeOnboarding() async {
    hasSeenOnboarding = true;
    notifyListeners();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool("hasSeenOnboarding", true);
  }
}
