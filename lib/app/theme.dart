import 'package:flutter/material.dart';

/// 本アプリの ThemeData。
///
/// 透過ウィンドウとカスタム背景を前提とするため、`Scaffold` の
/// 既定背景は透明にする。色は Material 3 の ColorScheme.fromSeed で
/// 生成し、後から ThemeExtension で拡張できるようにしておく。
class AppTheme {
  const AppTheme._();

  static const Color _seedColor = Color(0xFF6750A4);

  static ThemeData light() => _build(brightness: Brightness.light);

  static ThemeData dark() => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.6),
        scrolledUnderElevation: 0,
      ),
    );
  }
}
