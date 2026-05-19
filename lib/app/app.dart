import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/app_menu_bar.dart';
import 'package:roola/app/router.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/app/window_close_guard.dart';
import 'package:roola/data/appearance/appearance_settings.dart';
import 'package:roola/data/appearance/appearance_settings_repository_impl.dart';
import 'package:roola/data/locale/locale_settings_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/mouse_navigation_listener.dart';

/// アプリ最上位の Widget。
///
/// `ProviderScope` の内側に置く前提で、`MaterialApp.router` を組み立てる。
/// 背景は `appearanceSettingsProvider` の値に応じて 透過 / 単色 / 画像 /
/// グラデーション を切り替える。テーマは Polaris のダーク専用テーマ
/// （ADR-0038）に固定する。
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appearance =
        ref.watch(appearanceSettingsProvider).value ??
        AppearanceSettings.defaults();
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp.router(
      title: 'Roola',
      // Polaris はダーク専用（ADR-0038 D2）。ライト/ダークの切替は持たない。
      // アクセント色はユーザー設定（既定ゴールド / ADR-0038 D4）。
      theme: AppTheme.polaris(accent: appearance.accent),
      // スクロールの慣性・バウンス・オーバースクロールグローを排除（D7）。
      scrollBehavior: const PolarisScrollBehavior(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // 表示言語（ADR-0034）。設定値由来の locale を渡し、
      // localizationsDelegates / supportedLocales は gen-l10n の生成物。
      locale: locale.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // ネイティブメニューバー（ADR-0033）。ショートカットの発火を
      // PlatformMenuBar に一本化するため、最上位に配置する。
      builder: (context, child) => AppMenuBar(
        child: WindowCloseGuard(
          child: _AppearanceLayer(
            appearance: appearance,
            child: MouseNavigationListener(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

/// 外観モードに応じてアプリ全体の見え方を切り替えるレイヤー（ADR-0038）。
///
/// 透過ウィンドウ（macOS 側 `MainFlutterWindow` の `isOpaque = false`）の
/// 上で、`opaque` は不透明グラファイトの基底層を全面に敷いて Polaris の
/// 筐体を描く。`transparent` はその基底層ごと UI 全体を
/// [AppearanceSettings.transparencyOpacity] の濃さで半透明合成し、背後の
/// デスクトップを透かす。
///
/// 基底層（[AppTheme] の `bg` グラファイト）を必ず敷くのが要点。Polaris の
/// 各画面は自前で背景を塗るとは限らず（ターミナルのネイティブビュー周りや
/// 設定画面は塗らない）、基底層が無いと透過ウィンドウの素通し＝透明な穴に
/// なってしまう。
class _AppearanceLayer extends StatelessWidget {
  const _AppearanceLayer({required this.appearance, required this.child});

  final AppearanceSettings appearance;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return switch (appearance.mode) {
      AppearanceMode.opaque => ColoredBox(
        color: AppTheme.tokens.bg,
        child: child,
      ),
      AppearanceMode.transparent => _TransparentLayer(
        opacity: appearance.transparencyOpacity,
        centerImagePath: appearance.transparentCenterImagePath,
        centerImageMtime: appearance.transparentCenterImageMtime,
        child: child,
      ),
    };
  }
}

/// 透過モードのレイヤー。
///
/// 不透明グラファイトの基底層 → （中央画像）→ UI の順に重ねた全体を、1 枚の
/// [Opacity] で半透明合成する。個々のサーフェスを半透明化するとトーン階層
/// （`well` / `bg`）が重なる箇所でアルファが二重掛けされ濁るが、[Opacity] は
/// 子ツリーを一旦合成してから 1 度だけアルファを掛けるため、トーン階層を
/// 保ったまま均一に透ける。基底層があることで、UI が背景を塗らない領域も
/// 同じ濃さの半透明グラファイトになる。`opacity` が 1.0 のとき [Opacity] は
/// no-op。
///
/// `centerImagePath` が指定されていれば、基底層と UI の間に円形画像を挟む
/// （日本国旗の赤円のイメージ）。UI が半透明なので画像は透けて見え、クリック
/// 入力は [IgnorePointer] で UI 側へ素通りさせる。
class _TransparentLayer extends StatelessWidget {
  const _TransparentLayer({
    required this.opacity,
    required this.centerImagePath,
    required this.centerImageMtime,
    required this.child,
  });

  final double opacity;
  final String? centerImagePath;

  /// 中央画像の更新時刻。Image widget の ValueKey に乗せて、同じパスに
  /// 上書き保存された場合でも widget remount を強制する。
  final int? centerImageMtime;
  final Widget child;

  /// 中央画像のサイズ。短辺の 60% — 日本国旗の赤円の比率。
  static const double _centerSizeRatio = 0.6;

  @override
  Widget build(BuildContext context) {
    final hasCenterImage =
        centerImagePath != null && File(centerImagePath!).existsSync();
    final Widget content;
    if (!hasCenterImage) {
      content = ColoredBox(color: AppTheme.tokens.bg, child: child);
    } else {
      content = Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: AppTheme.tokens.bg),
          Center(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size =
                      constraints.biggest.shortestSide * _centerSizeRatio;
                  // 同じパスに上書き保存した直後は `FileImage` の equality が
                  // 一致するため `Image` widget が再リゾルブせず古い画像のまま。
                  // state 側で渡される更新時刻を ValueKey に乗せて widget を
                  // 強制 remount し、新しいバイト列を読み直す。
                  return ClipOval(
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: Image.file(
                        File(centerImagePath!),
                        key: ValueKey(centerImageMtime),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          child,
        ],
      );
    }
    return Opacity(opacity: opacity, child: content);
  }
}
