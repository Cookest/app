import 'package:cookest_ui/cookest_ui.dart';
import 'package:flutter/material.dart';

extension AppColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get appBackground =>
      isDarkMode ? CookestTokens.colorBackgroundDark : CookestTokens.colorBackgroundLight;

  Color get appSurface =>
      isDarkMode ? CookestTokens.colorSurfaceDark : CookestTokens.colorSurfaceLight;

  Color get appHeading =>
      isDarkMode ? CookestTokens.colorHeadingDark : CookestTokens.colorHeadingLight;

  Color get appMuted =>
      isDarkMode ? CookestTokens.colorMutedDark : CookestTokens.colorMutedLight;

  Color get appBorder =>
      isDarkMode ? CookestTokens.colorBorderDark : CookestTokens.colorBorderLight;
}
