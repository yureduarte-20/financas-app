import 'package:flutter/material.dart';
import '../constants/color_tokens.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: ColorTokens.primary,
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: ColorTokens.background,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: ColorTokens.primary,
      useMaterial3: true,
      fontFamily: 'Inter',
    );
  }
}
