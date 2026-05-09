// Re-exports the Cookest design system. All new code should import
// package:cookest_ui/cookest_ui.dart directly.
export 'package:cookest_ui/cookest_ui.dart';

import 'package:flutter/material.dart';
import 'package:cookest_ui/cookest_ui.dart';

/// Backward-compat aliases. Prefer CookestTokens / CookestTheme directly.
class AppTheme {
  static const Color sage = CookestTokens.colorPrimaryDEFAULT;
  static const Color background = CookestTokens.colorBackgroundLight;
  static const Color surface = CookestTokens.colorSurfaceLight;
  static const Color darkGreen = CookestTokens.colorHeadingLight;
  static const Color textMuted = CookestTokens.colorMutedLight;
  static const Color textCaption = CookestTokens.colorMutedLight;
  static const Color border = CookestTokens.colorBorderLight;
  static const Color divider = CookestTokens.colorBorderLight;
  static const Color destructive = CookestTokens.colorStatusError;

  static ThemeData get lightTheme => CookestTheme.light;
  static ThemeData get darkTheme => CookestTheme.dark;
}
