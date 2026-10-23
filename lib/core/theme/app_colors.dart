import 'package:flutter/material.dart';

abstract class AppColors {
  Brightness get brightness;

  Color get mainColor;

  Color get mainTextColor;

  Color get backgroundColor;

  Color get inputColor;

  Color get disableColor;

  Color get strokeColor;

  Color get secondaryTextColor;

  Color get errorColor;
}

class LightAppColors extends AppColors {
  @override
  Color get mainColor => const Color(0xFF0E3A99);

  @override
  Color get mainTextColor => const Color(0xFF1C1C1C);

  @override
  Color get secondaryTextColor => const Color(0xFF686868);

  @override
  Color get backgroundColor => const Color(0xFFF4F7FF);

  @override
  Color get inputColor => const Color(0xFFFFFFFF);

  @override
  Color get disableColor => const Color(0xFFB9B9B9);

  @override
  Color get strokeColor => const Color(0xFFF0F0F0);

  @override
  Color get errorColor => const Color(0xFFFF3232);

  @override
  Brightness get brightness => Brightness.light;
}

class DarkAppColors extends AppColors {
  @override
  Brightness get brightness => Brightness.dark;

  @override
  Color get mainColor => const Color(0xFF457AED);

  @override
  Color get mainTextColor => const Color(0xFFFFFFFF);

  @override
  Color get secondaryTextColor => const Color(0xFFD6D6D6);

  @override
  Color get backgroundColor => const Color(0xFF000F30);

  @override
  Color get inputColor => const Color(0xFF001440);

  @override
  Color get disableColor => const Color(0xFFB9B9B9);

  @override
  Color get strokeColor => const Color(0xFF002D8F);

  @override
  Color get errorColor => const Color(0xFFFF3232);
}
