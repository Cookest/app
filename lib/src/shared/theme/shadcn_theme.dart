// Re-exports the Cookest design system. All new code should import
// package:cookest_ui/cookest_ui.dart directly.
export 'package:cookest_ui/cookest_ui.dart';

import 'package:flutter/material.dart';
import 'package:cookest_ui/cookest_ui.dart';

/// Backward-compat aliases. Prefer CookestTokens / CookestTheme directly.
class AppTheme {
  static const Color sage = CookestTokens.colorPrimaryDEFAULT;
  static const Color destructive = CookestTokens.colorStatusError;

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) => _isDark(context)
      ? CookestTokens.colorBackgroundDark
      : CookestTokens.colorBackgroundLight;

  static Color surface(BuildContext context) => _isDark(context)
      ? CookestTokens.colorSurfaceDark
      : CookestTokens.colorSurfaceLight;

  static Color darkGreen(BuildContext context) => _isDark(context)
      ? CookestTokens.colorHeadingDark
      : CookestTokens.colorHeadingLight;

  static Color textMuted(BuildContext context) => _isDark(context)
      ? CookestTokens.colorMutedDark
      : CookestTokens.colorMutedLight;

  static Color textCaption(BuildContext context) => textMuted(context);

  static Color border(BuildContext context) => _isDark(context)
      ? CookestTokens.colorBorderDark
      : CookestTokens.colorBorderLight;

  static Color divider(BuildContext context) => border(context);

  static ThemeData get lightTheme => CookestTheme.light;
  static ThemeData get darkTheme => CookestTheme.dark;
}
