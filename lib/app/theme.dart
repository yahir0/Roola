import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roola/data/appearance/polaris_accent.dart';

/// Polaris デザインシステムのテーマ実装（ADR-0038）。
///
/// 思想は機能主義 — 装飾を排し、機能・精密さ・情報密度で形を決める。
/// 全デザイン値は [PolarisTokens]（`ThemeExtension`）に集約し、UI コンポーネント
/// はそこを経由して参照する。色・角丸・余白をコンポーネント側にハードコード
/// しない。
///
/// 視覚ルール（ADR-0038 の D1〜D13）:
/// - ダーク専用。ライトテーマは持たない（D2）。
/// - 地はグラファイト 2 トーン階層 — `well`（沈んだ計器ディスプレイ）/ `bg`
///   （筐体の枠）。影は使わず、トーン差と 1px ラインのみで面を分ける（D3）。
/// - アクセントは暖色ゴールド 1 色（`accent`）。選択・現在地・フォルダに限定（D4）。
/// - 角は機械加工 R=4px（[PolarisTokens.radius]）。全寸法 4px グリッド（D6）。
/// - アニメーション 0ms — ink splash 抑制、ボタンの遷移を即時化、ページ遷移を
///   即時化、スクロールの慣性/グローを排除（D7）。
class AppTheme {
  const AppTheme._();

  /// Polaris のデザイントークン。`ThemeData.extensions` 経由で参照する。
  static const PolarisTokens tokens = PolarisTokens(
    // --- グラファイト 3 トーン階層（D3 改訂）-----------------------------
    // machine は bg 寄りにリフトしたクールグラファイト。well と同じ「クールの
    // 系統」を維持しつつ、深さだけを bg 直下まで持ち上げる。実機材の操作面
    // （コンソール）はシャシ表面と同じ高さで、計器類だけが沈み込むのが自然。
    // 暖色シフトは試したが、Roola 全体が cool 統一の中で 1 か所だけ warm に
    // すると「素材が違う面」として独立して見える（実機で「浮く」と判定された
    // ため撤回）。深さでなくリフト幅だけで差別化し、純黒の空洞には落とさない
    // （D3 の純黒回避原則）。
    machine: Color(0xFF101115), // 機材本体（ターミナル）。bg 寄りのクール
    well: Color(0xFF0A0B0D), // 沈んだ計器ディスプレイ（ファイル一覧）
    bg: Color(0xFF121317), // 筐体の枠（トップバー/サイドバー/ステータスバー）
    topEdge: Color(0xFF2C3037), // 筐体上端が光を受ける 1px ハイライト
    surface: Color(0xFF1B1D22), // ホバー行（machine/well/bg より持ち上がる）
    surfaceHi: Color(0xFF232730), // 選択行（控えめな塗り）
    line: Color(0xFF2A2D33), // パネルの継ぎ目（1px）。装飾線は引かない
    // --- テキスト（暗い地で痩せないよう副トーンの幅を広く取る）---------
    text: Color(0xFFECEFF2), // 主テキスト（高コントラスト）
    textDim: Color(0xFF929AA3), // 副テキスト
    textFaint: Color(0xFF686F78), // ラベル・メタ情報の最弱トーン
    // --- アクセント（D4）-----------------------------------------------
    accent: Color(0xFFD0A341), // 削り出しの真鍮・ゴールド（暖色・1 色のみ）
    onAccent: Color(0xFF0A0B0D), // アクセント上に乗せるテキスト/アイコン
    // --- Git 状態の信号色（D5）-----------------------------------------
    // 新規=green / 変更=steel blue / コンフリクト=red。意味専用。
    // 「変更」は当初 amber だったが、アクセントのゴールド（暖色）と色相が
    // 近く混同するため、寒色のスチールブルーへ振り直した（ADR-0038 D5）。
    signalNew: Color(0xFF46C46E),
    signalModified: Color(0xFF4F9DD4),
    signalConflict: Color(0xFFE5544B),
    // --- 寸法 -----------------------------------------------------------
    radius: 4, // 機械加工 R（D6）。2px は大パネルで直角に見えたため 4px へ
    gridUnit: 4, // 全寸法を乗せる 4px グリッド（D6）
  );

  /// [PolarisAccent] に対応するアクセント色を返す（ADR-0038 D4）。
  /// アクセントは常に 1 色だが、その 1 色をユーザーが選べる。
  static Color accentColor(PolarisAccent accent) => switch (accent) {
    PolarisAccent.gold => const Color(0xFFD0A341), // 削り出しの真鍮・ゴールド
    PolarisAccent.iceBlue => const Color(0xFF48C9DE), // アイスシアン
  };

  /// ダーク専用の Polaris [ThemeData]。[accent] でアクセント色を選ぶ。
  static ThemeData polaris({PolarisAccent accent = PolarisAccent.gold}) {
    final t = tokens.copyWith(accent: accentColor(accent));
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: t.accent,
      onPrimary: t.onAccent,
      secondary: t.accent,
      onSecondary: t.onAccent,
      error: t.signalConflict,
      onError: t.text,
      surface: t.bg,
      onSurface: t.text,
      onSurfaceVariant: t.textDim,
      surfaceContainerLowest: t.well,
      surfaceContainerLow: t.bg,
      surfaceContainer: t.surface,
      surfaceContainerHigh: t.surfaceHi,
      surfaceContainerHighest: t.surfaceHi,
      outline: t.line,
      outlineVariant: t.line,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.radius),
    );
    final borderedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.radius),
      side: BorderSide(color: t.line),
    );

    // コントロール（ボタン / 入力欄）の標準高さ。計器 UI 寄りに 32px へ
    // 詰めていたが、操作のしやすさを優先して一段上げ、トップバーと同じ
    // 40px（10 グリッド）に統一する（ADR-0038 D6）。横方向は詰める。
    const buttonMinSize = Size(0, 40);
    const buttonPadding = EdgeInsets.symmetric(
      horizontal: PolarisTokens.space3,
    );

    // 全プラットフォームでページ遷移アニメーションを即時化する（D7）。
    const transitions = PageTransitionsTheme(
      builders: {
        TargetPlatform.macOS: _InstantPageTransitionsBuilder(),
        TargetPlatform.windows: _InstantPageTransitionsBuilder(),
        TargetPlatform.linux: _InstantPageTransitionsBuilder(),
        TargetPlatform.android: _InstantPageTransitionsBuilder(),
        TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
        TargetPlatform.fuchsia: _InstantPageTransitionsBuilder(),
      },
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // 透過 / 画像 / グラデーションの背景モード（`_AppearanceLayer`）を
      // 活かすため、scaffold / canvas は透明にし、各画面が自前で `bg` の
      // グラファイトを塗る。
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      visualDensity: VisualDensity.compact,
      // ink ripple を全廃。クリック反応は背景色の瞬間切替のみ（D7）。
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: t.surface,
      pageTransitionsTheme: transitions,
      fontFamilyFallback: Platform.isWindows
          ? const ['Yu Gothic UI', 'Meiryo']
          : const ['Hiragino Sans'],
      textTheme: _textTheme(t),
      iconTheme: IconThemeData(
        color: t.textDim,
        size: PolarisIconSize.standard,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.bg,
        foregroundColor: t.text,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(color: t.line, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        elevation: 0,
        color: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: borderedShape,
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: t.bg,
        surfaceTintColor: Colors.transparent,
        shape: borderedShape,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          elevation: const WidgetStatePropertyAll(0),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          backgroundColor: WidgetStatePropertyAll(t.surface),
          shape: WidgetStatePropertyAll(borderedShape),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 0,
        color: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: borderedShape,
        textStyle: t.body.copyWith(color: t.text),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(t.surface),
          shape: WidgetStatePropertyAll(borderedShape),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.surfaceHi,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(t.radius),
        ),
        textStyle: t.meta.copyWith(color: t.text),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ).copyWith(animationDuration: Duration.zero),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: shape,
          elevation: 0,
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ).copyWith(animationDuration: Duration.zero),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          side: BorderSide(color: t.line),
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ).copyWith(animationDuration: Duration.zero),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: shape,
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ).copyWith(animationDuration: Duration.zero),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: shape,
        ).copyWith(animationDuration: Duration.zero),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(shape: shape),
      ),
      chipTheme: ChipThemeData(
        shape: shape,
        side: BorderSide(color: t.line),
        backgroundColor: t.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        // 入力欄もボタンと同じ操作高さ（≒40px）に揃える。isDense のうえで
        // 上下パディングを広めに取り、ボタンの標準高さに体感を合わせる。
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PolarisTokens.space3,
          vertical: PolarisTokens.space3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.radius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.radius),
          borderSide: BorderSide(color: t.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.radius),
          borderSide: BorderSide(color: t.accent),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(t.surfaceHi),
        radius: Radius.circular(t.radius),
      ),
      // スライダーは細いトラック＋矩形のフェーダキャップ（計器のフェーダ）。
      // 丸ツマミは Material 然として温度が合わないため、機械加工の R=4px・
      // 1px ボーダーを持つ縦長キャップに差し替える（ADR-0038 D6）。
      sliderTheme: SliderThemeData(
        trackHeight: 2,
        activeTrackColor: t.accent,
        inactiveTrackColor: t.line,
        thumbColor: t.accent,
        overlayColor: t.accent.withValues(alpha: 0.12),
        thumbShape: _FaderThumbShape(
          fill: t.accent,
          border: t.onAccent,
          radius: t.radius,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        showValueIndicator: ShowValueIndicator.never,
      ),
      // スイッチの配色をトークン化（ON=アクセント、OFF=無彩のグラファイト）。
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? t.onAccent : t.textDim,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? t.accent : t.surface,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? t.accent : t.line,
        ),
      ),
      // SnackBar も影を使わず 1px ボーダー＋ R=2px の計器パネル調にする。
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.surfaceHi,
        contentTextStyle: t.body.copyWith(color: t.text),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: borderedShape,
        actionTextColor: t.accent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.accent,
        linearTrackColor: t.surface,
        circularTrackColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: t.textDim,
        textColor: t.text,
        selectedColor: t.accent,
      ),
      extensions: [t],
    );
  }

  /// Polaris の 4 段タイプスケール（label 11 / meta 13 / body 14 / title 16）を
  /// Material の `TextTheme` スロットへ割り当てる。スロット名の粒度に関わらず
  /// 同じ役割には同じサイズが出るよう、4 段以外のサイズは設けない（ADR-0038 D9）。
  static TextTheme _textTheme(PolarisTokens t) {
    final title = t.title.copyWith(color: t.text);
    final body = t.body.copyWith(color: t.text);
    final meta = t.meta.copyWith(color: t.textDim);
    final label = t.label.copyWith(color: t.textFaint);
    return TextTheme(
      titleLarge: title,
      titleMedium: title,
      titleSmall: body,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: meta,
      labelLarge: body,
      labelMedium: meta,
      labelSmall: label,
    );
  }
}

/// 全プラットフォームでページ遷移を即時化する [PageTransitionsBuilder]（D7）。
/// フェード・スライドを排し、次フレームで遷移後の画面を表示する。
class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}

/// オーバースクロールのグロー・慣性・バウンスを排除する [ScrollBehavior]（D7）。
/// `MaterialApp.scrollBehavior` へ適用する。
class PolarisScrollBehavior extends MaterialScrollBehavior {
  const PolarisScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

/// スライダーのツマミを「矩形のフェーダキャップ」として描く [SliderComponentShape]
/// （Polaris / ADR-0038 D6）。Material 既定の丸ツマミを避け、機械加工 R の縦長
/// キャップ（塗り + 1px ボーダー + 中央のグリップ線）にする。
class _FaderThumbShape extends SliderComponentShape {
  const _FaderThumbShape({
    required this.fill,
    required this.border,
    required this.radius,
  });

  /// キャップの塗り色（アクセント）。
  final Color fill;

  /// ボーダーと中央グリップ線の色（アクセント上のテキスト色）。
  final Color border;

  /// 機械加工 R（px）。
  final double radius;

  static const Size _size = Size(8, 18);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => _size;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = Rect.fromCenter(
      center: center,
      width: _size.width,
      height: _size.height,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas
      ..drawRRect(rrect, Paint()..color = fill)
      ..drawRRect(
        rrect,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      )
      // 中央のグリップ線（フェーダの刻み）。
      ..drawLine(
        Offset(center.dx - 2, center.dy),
        Offset(center.dx + 2, center.dy),
        Paint()
          ..color = border
          ..strokeWidth = 1,
      );
  }
}

/// Polaris のアイコンサイズスケール（ADR-0038 D10）。
///
/// アイコンも色・角丸・タイポと同じくスケールで統制し、`size:` に場当たりの
/// 数値を直接書かない。標準は 2 段（[standard] / [small]）で、空状態の
/// ヒーロー表示に限り [hero] を使う。
abstract final class PolarisIconSize {
  /// 標準アイコン（px）。ツールバー・一覧・サイドバー・メニュー・主要操作。
  static const double standard = 18;

  /// 小アイコン（px）。行内バッジ・タブ・補助的な従属アイコン。
  static const double small = 16;

  /// 空状態のヒーローアイコン（px）。プレースホルダ表示専用。
  static const double hero = 48;
}

/// Polaris のデザイントークン（ADR-0038）。
///
/// 色・トーン階層・角丸・グリッド単位・タイポグラフィを単一の `ThemeExtension`
/// に集約する。UI コンポーネントは [PolarisTokens.of] でこれを取得し、リテラルの
/// `Color(0x...)` やマジックナンバーをハードコードしない。
@immutable
class PolarisTokens extends ThemeExtension<PolarisTokens> {
  const PolarisTokens({
    required this.machine,
    required this.well,
    required this.bg,
    required this.topEdge,
    required this.surface,
    required this.surfaceHi,
    required this.line,
    required this.text,
    required this.textDim,
    required this.textFaint,
    required this.accent,
    required this.onAccent,
    required this.signalNew,
    required this.signalModified,
    required this.signalConflict,
    required this.radius,
    required this.gridUnit,
  });

  /// 機材本体の地（ターミナル）。`bg` 直下まで持ち上げたクールグラファイト。
  /// `well`（計器・沈み込み）と同じクール系を維持しつつ、深さは bg 寄りに
  /// リフトする。実機材の操作面（コンソール）はシャシ表面とほぼ同じ高さで、
  /// 計器だけが沈み込むのが自然。クール統一で「ターミナルだけ浮く」を避け、
  /// リフトで「広い暗面の重さ」を抑える（ADR-0038 D3 改訂）。
  final Color machine;

  /// 沈んだ計器ディスプレイ（ファイル一覧の地）。クールグラファイト。
  final Color well;

  /// 筐体の枠（トップバー/サイドバー/ステータスバー）。`well` より一段明るい。
  final Color bg;

  /// 筐体上端が光を受ける 1px ハイライト。
  final Color topEdge;

  /// ホバー行の塗り。`well` / `bg` より僅かに持ち上がる。
  final Color surface;

  /// 選択行の控えめな塗り。
  final Color surfaceHi;

  /// パネルの継ぎ目（1px ライン）。装飾線は引かない。
  final Color line;

  /// 主テキスト（高コントラスト）。
  final Color text;

  /// 副テキスト。
  final Color textDim;

  /// ラベル・メタ情報の最弱トーン。
  final Color textFaint;

  /// 限定使用のアクセント（暖色ゴールド・1 色）。選択・現在地・フォルダ。
  final Color accent;

  /// アクセント上に乗せるテキスト/アイコンの色。
  final Color onAccent;

  /// Git 信号色 — 新規（green）。
  final Color signalNew;

  /// Git 信号色 — 変更（steel blue）。アクセントのゴールドと区別する。
  final Color signalModified;

  /// Git 信号色 — コンフリクト（red）。
  final Color signalConflict;

  /// 機械加工 R（角丸 px）。
  final double radius;

  /// レイアウトの全寸法を乗せるグリッド単位（px）。
  final double gridUnit;

  // --- 余白スケール（ADR-0038 D6: 全寸法を 4px グリッドに乗せる）-----------
  // padding / gap / margin はこの定数を使い、リテラルを書かない。値はすべて
  // グリッド単位（4px）の整数倍。色トークンと違い余白はテーマで変わらないため
  // instance フィールドではなく `static const` で持つ。これにより
  // `const EdgeInsets` の中でもそのまま使え、const 構築を壊さない。

  /// 4px（1 グリッド）。最小の余白。
  static const double space1 = 4;

  /// 8px（2 グリッド）。標準の小余白・行内の細ギャップ。
  static const double space2 = 8;

  /// 12px（3 グリッド）。アイコン↔ラベル間隔・中余白。
  static const double space3 = 12;

  /// 16px（4 グリッド）。行・パネルの標準インセット。
  static const double space4 = 16;

  /// 20px（5 グリッド）。
  static const double space5 = 20;

  /// 24px（6 グリッド）。セクション間の大余白。
  static const double space6 = 24;

  /// 28px（7 グリッド）。サイドバー等のリスト行の高さ。
  static const double space7 = 28;

  /// 32px（8 グリッド）。画面・大ブロックの区切り。
  static const double space8 = 32;

  /// タイプスケール最小段＝クローム用ラベル（全大文字・トラッキング）。11px。
  /// プロポーショナル。ウェイトは w500 — w600 は字面が太く丸く見えたため
  /// 引き下げた（ADR-0038 D9）。
  TextStyle get label => TextStyle(
    fontSize: 11,
    fontWeight: Platform.isWindows
        ? FontWeight.w400
        : FontWeight.w500,
    letterSpacing: 1.4,
    height: 1,
  );

  /// タイプスケール第 2 段＝副次・メタ情報（件数・パス末尾・補助ラベル等）。
  /// 13px・プロポーショナル・w500。`body` と色（`textDim`）で主従を分ける。
  TextStyle get meta => TextStyle(
    fontSize: 13,
    fontWeight: Platform.isWindows
        ? FontWeight.w400
        : FontWeight.w500,
    letterSpacing: 0, // textTheme 合成での Material 既定混入を防ぐ（body 参照）
    fontFamilyFallback: Platform.isWindows
        ? const ['Yu Gothic UI', 'Meiryo']
        : const ['Hiragino Sans'],
  );

  /// タイプスケール第 3 段＝主要 UI テキスト（本文・ファイル名・行ラベル・
  /// タブ名・入力欄）。14px・プロポーショナル・w500 基準。計器 UI でも視認性を
  /// 犠牲にしないため、暗い地で痩せて見えない下限として 14px を採る（ADR-0038 D9）。
  TextStyle get body => TextStyle(
    fontSize: 14,
    fontWeight: Platform.isWindows
        ? FontWeight.w400
        : FontWeight.w500,
    // 明示必須。省略すると ThemeData の textTheme 合成で Material 既定の
    // letterSpacing(0.25) が紛れ込み、`textTheme.bodyMedium` 経由の文字だけ
    // 字間が広がって素の `body` トークン直参照とズレる（meta / title も同様）。
    letterSpacing: 0,
    fontFamilyFallback: Platform.isWindows
        ? const ['Yu Gothic UI', 'Meiryo']
        : const ['Hiragino Sans'],
  );

  /// タイプスケール最上段＝見出し（セクション見出し・ダイアログ/画面タイトル）。
  /// 16px。`body` より 2px 大きくし、ウェイト w600 と併せて階層を持たせる
  /// （ADR-0038 D9）。
  TextStyle get title => TextStyle(
    fontSize: 16,
    fontWeight: Platform.isWindows
        ? FontWeight.w500
        : FontWeight.w600,
    letterSpacing: 0, // textTheme 合成での Material 既定混入を防ぐ（body 参照）
    fontFamilyFallback: Platform.isWindows
        ? const ['Yu Gothic UI', 'Meiryo']
        : const ['Hiragino Sans'],
  );

  /// データ列（perm / size / 日時 / パス）。等幅・13px。
  TextStyle get mono => TextStyle(
    fontFamily: Platform.isWindows
        ? 'Cascadia Code'
        : 'SF Mono',
    fontFamilyFallback: Platform.isWindows
        ? const ['Consolas', 'Courier New']
        : const ['Menlo'],
    fontSize: 13,
    fontWeight: Platform.isWindows
        ? FontWeight.w400
        : FontWeight.w500,
    height: 1,
  );

  /// 現在の [BuildContext] から [PolarisTokens] を取得する。
  ///
  /// テーマに拡張が無い文脈（テストハーネスなど）でも落ちないよう、欠落時は
  /// 既定の [AppTheme.tokens] にフォールバックする。
  static PolarisTokens of(BuildContext context) =>
      Theme.of(context).extension<PolarisTokens>() ?? AppTheme.tokens;

  @override
  PolarisTokens copyWith({
    Color? machine,
    Color? well,
    Color? bg,
    Color? topEdge,
    Color? surface,
    Color? surfaceHi,
    Color? line,
    Color? text,
    Color? textDim,
    Color? textFaint,
    Color? accent,
    Color? onAccent,
    Color? signalNew,
    Color? signalModified,
    Color? signalConflict,
    double? radius,
    double? gridUnit,
  }) => PolarisTokens(
    machine: machine ?? this.machine,
    well: well ?? this.well,
    bg: bg ?? this.bg,
    topEdge: topEdge ?? this.topEdge,
    surface: surface ?? this.surface,
    surfaceHi: surfaceHi ?? this.surfaceHi,
    line: line ?? this.line,
    text: text ?? this.text,
    textDim: textDim ?? this.textDim,
    textFaint: textFaint ?? this.textFaint,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    signalNew: signalNew ?? this.signalNew,
    signalModified: signalModified ?? this.signalModified,
    signalConflict: signalConflict ?? this.signalConflict,
    radius: radius ?? this.radius,
    gridUnit: gridUnit ?? this.gridUnit,
  );

  @override
  PolarisTokens lerp(ThemeExtension<PolarisTokens>? other, double t) {
    // Polaris はダーク専用の単一テーマでテーマ間の遷移が発生しないため、
    // 補間はせず段階的に切り替える。
    if (other is! PolarisTokens) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}
