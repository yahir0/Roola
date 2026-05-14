import 'package:flutter/material.dart';

/// 本アプリの ThemeData。Win10/11 風のフラット実用 UI を目指す（ADR-0020）。
///
/// 設計方針:
/// - 角は 2px の浅い丸めに統一（[_radius]）。完全な 0px だとドットパターンの
///   交差や描画エッジでジャギーが出るため、Win11 のコントロール類と同じ
///   ごく浅い丸めを採用。
/// - elevation / drop shadow は使わない。コンテナの区切りは 1px の
///   `outlineVariant` ボーダーまたは背景色トーン差で表現。
/// - InkWell の ripple は [NoSplash.splashFactory] で抑制し、Win10 風の
///   静的なホバー反応（背景色 1 段差）にする。
/// - [VisualDensity.compact] でデスクトップ密度に揃える。
/// - Light テーマは Win11 ニュートラルグレー（#F3F3F3 系）。Dark テーマは
///   ロゴ由来の gunmetal を維持。アクセントブルー（[_logoBlue]）だけは
///   両テーマ共通でブランド色として残す。
///
/// ロゴ固有のグラデーション・アクセントは [LogoTheme] ThemeExtension 経由で
/// 参照する（透過ウィンドウ背景の暗幕などで使う）。
class AppTheme {
  const AppTheme._();

  /// コントロール類の共通角丸（px）。Win11 のボタン・カードと同じく浅め。
  static const double _radius = 2.0;

  // ロゴ由来のパレット（アクセント + Dark テーマ surface）。
  static const Color _logoBlue = Color(0xFF5080C0);
  static const Color _logoBlueLight = Color(0xFF90C0F0);
  static const Color _logoBackgroundTop = Color(0xFF4B525C);
  static const Color _logoBackgroundBottom = Color(0xFF1E232A);
  static const Color _logoSurface = Color(0xFF2F353D);
  static const Color _logoSurfaceContainer = Color(0xFF3A4148);
  static const Color _logoOnSurface = Color(0xFFFFFFFF);
  static const Color _logoOnSurfaceVariant = Color(0xFFA8B0BC);

  // Light テーマの Win11 ニュートラルグレー。Mica/Acrylic は再現せず
  // 静的フラット塗りで近づける。
  static const Color _lightBackground = Color(0xFFF3F3F3);
  static const Color _lightSurface = Color(0xFFFAFAFA);
  static const Color _lightSurfaceContainerLow = Color(0xFFF0F0F0);
  static const Color _lightSurfaceContainer = Color(0xFFEAEAEA);
  static const Color _lightSurfaceContainerHigh = Color(0xFFE2E2E2);
  static const Color _lightSurfaceContainerHighest = Color(0xFFDADADA);
  static const Color _lightOutline = Color(0xFFBFBFBF);
  static const Color _lightOutlineVariant = Color(0xFFD8D8D8);
  static const Color _lightOnSurface = Color(0xFF1F1F1F);
  static const Color _lightOnSurfaceVariant = Color(0xFF5C5C5C);

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
        : base.copyWith(
            // Light は seed の薄ブルー寄りを捨てて、Win11 ニュートラル
            // グレーに置換する。アクセントブルー（primary）は維持。
            primary: _logoBlue,
            secondary: _logoBlue,
            surface: _lightSurface,
            surfaceContainerLowest: _lightSurface,
            surfaceContainerLow: _lightSurfaceContainerLow,
            surfaceContainer: _lightSurfaceContainer,
            surfaceContainerHigh: _lightSurfaceContainerHigh,
            surfaceContainerHighest: _lightSurfaceContainerHighest,
            onSurface: _lightOnSurface,
            onSurfaceVariant: _lightOnSurfaceVariant,
            outline: _lightOutline,
            outlineVariant: _lightOutlineVariant,
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: isDark ? Colors.transparent : _lightBackground,
      // canvasColor は MaterialApp 配下の Material widget の既定背景色。
      // Dark は AppearanceMode.transparent 用に透明、Light は通常の背景。
      canvasColor: isDark ? Colors.transparent : _lightBackground,
      visualDensity: VisualDensity.compact,
      // Win10/11 では ripple アニメーションが無いので、Flutter デフォルトの
      // ink ripple を全廃する。クリック反応は背景色変化のみ。
      splashFactory: NoSplash.splashFactory,
      // hover 時の overlay は Material widget の `hoverColor` に従う。
      // outlineVariant 寄りの薄いトーンでホバーを示す。
      hoverColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: shape,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          elevation: const WidgetStatePropertyAll(0),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
          shape: WidgetStatePropertyAll(shape),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 0,
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          shape: WidgetStatePropertyAll(shape),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
      // 各種ボタンを 2px 角に統一。
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: shape),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: shape, elevation: 0),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: shape),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: shape),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(shape: shape),
      ),
      chipTheme: ChipThemeData(shape: shape, side: BorderSide.none),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
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
