import 'package:flutter/material.dart';

/// 本アプリの ThemeData。
///
/// ロゴ（`macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png`）
/// からサンプリングした gunmetal + sky-blue のパレットを基盤とする。
/// 透過ウィンドウとカスタム背景を前提とするため `scaffoldBackgroundColor`
/// は透明のまま。ロゴ固有のグラデーション・アクセントは [LogoTheme]
/// ThemeExtension 経由で参照する。
class AppTheme {
  const AppTheme._();

  // ロゴ由来のパレット。
  static const Color _logoBlue = Color(0xFF5080C0);
  static const Color _logoBlueLight = Color(0xFF90C0F0);
  static const Color _logoBackgroundTop = Color(0xFF4B525C);
  static const Color _logoBackgroundBottom = Color(0xFF1E232A);
  static const Color _logoSurface = Color(0xFF2F353D);
  static const Color _logoSurfaceContainer = Color(0xFF3A4148);
  static const Color _logoOnSurface = Color(0xFFFFFFFF);
  static const Color _logoOnSurfaceVariant = Color(0xFFA8B0BC);

  /// 透過モード時の暗幕に使う無彩色グレー。ロゴの deep gunmetal
  /// (`_logoBackgroundBottom`) は青に寄っているため、透過設定下では
  /// 色味が強く出すぎる。`#1D1D1D` は R = G = B の完全無彩色で、
  /// デスクトップ側の壁紙にもっとも干渉しないトーン。
  static const Color transparentBackdrop = Color(0xFF1D1D1D);

  /// ロゴパレットを参照するための ThemeExtension のシングルトン。
  static const LogoTheme logoTheme = LogoTheme(
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_logoBackgroundTop, _logoBackgroundBottom],
    ),
    accentBlue: _logoBlue,
    accentBlueLight: _logoBlueLight,
    deepBackground: _logoBackgroundBottom,
    surface: _logoSurface,
  );

  static ThemeData light() => _build(brightness: Brightness.light);

  static ThemeData dark() => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: _logoBlue,
      brightness: brightness,
    );
    // dark はロゴそのものの配色に直接寄せる。light は seed 由来のまま。
    final colorScheme = isDark
        ? base.copyWith(
            primary: _logoBlue,
            secondary: _logoBlueLight,
            surface: _logoSurface,
            surfaceContainerLowest: _logoBackgroundBottom,
            surfaceContainerLow: _logoSurface,
            surfaceContainer: _logoSurfaceContainer,
            surfaceContainerHigh: _logoSurfaceContainer,
            surfaceContainerHighest: _logoSurfaceContainer,
            onSurface: _logoOnSurface,
            onSurfaceVariant: _logoOnSurfaceVariant,
          )
        : base;
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      // canvasColor は MaterialApp 配下の Material widget の既定背景色。
      // 既定では `colorScheme.surface`（不透明 gunmetal）になり、ルート
      // route の Material が画面全体を塗ってしまうため、AppearanceMode.
      // transparent でも背景が見えなくなる。ここで透明に倒し、表示が
      // 必要な要素（Card / Dialog / Menu 等）は個別に surface 系を
      // 明示している widget に任せる。
      canvasColor: Colors.transparent,
      // AppBar は背景を完全透過にする。半透明の塗りを当てると
      // AppearanceMode.transparent でも透過しなくなるため、見た目の
      // 区切りは個別の widget（AppTabBar の gradient accent line 等）に
      // 任せる。
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      // フラット基調。Card / Dialog の elevation を 0 にして影を排し、
      // 区切りはアウトラインまたは背景色の差で表現する。
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          elevation: const WidgetStatePropertyAll(0),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 0,
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      extensions: const [logoTheme],
    );
  }
}

/// ロゴ由来のブランドトークン。Material の [ColorScheme] では表現しきれない
/// 「ロゴ背景のグラデーション」「アクセントブルー」を扱うために用意する。
@immutable
class LogoTheme extends ThemeExtension<LogoTheme> {
  const LogoTheme({
    required this.backgroundGradient,
    required this.accentBlue,
    required this.accentBlueLight,
    required this.deepBackground,
    required this.surface,
  });

  /// ロゴ背景に合わせた左上→右下の gunmetal グラデーション。
  final LinearGradient backgroundGradient;

  /// ロゴのアクセント（中域）ブルー。
  final Color accentBlue;

  /// ロゴのアクセント（ハイライト）ブルー。
  final Color accentBlueLight;

  /// グラデーション末端の深い gunmetal。フラット塗りつぶしの基調色。
  final Color deepBackground;

  /// スクワークル内側相当の surface。カードやチップの基準色に使う。
  final Color surface;

  @override
  LogoTheme copyWith({
    LinearGradient? backgroundGradient,
    Color? accentBlue,
    Color? accentBlueLight,
    Color? deepBackground,
    Color? surface,
  }) => LogoTheme(
    backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    accentBlue: accentBlue ?? this.accentBlue,
    accentBlueLight: accentBlueLight ?? this.accentBlueLight,
    deepBackground: deepBackground ?? this.deepBackground,
    surface: surface ?? this.surface,
  );

  @override
  LogoTheme lerp(ThemeExtension<LogoTheme>? other, double t) {
    if (other is! LogoTheme) {
      return this;
    }
    return LogoTheme(
      backgroundGradient: LinearGradient.lerp(
        backgroundGradient,
        other.backgroundGradient,
        t,
      )!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentBlueLight: Color.lerp(accentBlueLight, other.accentBlueLight, t)!,
      deepBackground: Color.lerp(deepBackground, other.deepBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
    );
  }
}
