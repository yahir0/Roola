import 'dart:io';

import 'package:claude_skills_launcher/app/router.dart';
import 'package:claude_skills_launcher/app/theme.dart';
import 'package:claude_skills_launcher/app/window_close_guard.dart';
import 'package:claude_skills_launcher/data/appearance/appearance_settings.dart';
import 'package:claude_skills_launcher/data/appearance/appearance_settings_repository_impl.dart';
import 'package:claude_skills_launcher/ui/common/mouse_navigation_listener.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// アプリ最上位の Widget。
///
/// `ProviderScope` の内側に置く前提で、`MaterialApp.router` を組み立てる。
/// 背景は `appearanceSettingsProvider` の値に応じて 透過 / 単色 / 画像 /
/// ロゴグラデーション を切り替える。テーマはロゴが dark トーン基調のため
/// `ThemeMode.dark` に固定する。
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appearance =
        ref.watch(appearanceSettingsProvider).value ??
        AppearanceSettings.defaults();
    return MaterialApp.router(
      title: 'Claude Skills Launcher',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => WindowCloseGuard(
        child: _AppearanceLayer(
          appearance: appearance,
          child: MouseNavigationListener(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _AppearanceLayer extends StatelessWidget {
  const _AppearanceLayer({required this.appearance, required this.child});

  final AppearanceSettings appearance;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return switch (appearance.mode) {
      // 完全透過だとウィンドウ枠が背景と同化してしまうため、中性
      // スレート（`transparentBackdrop`）を `transparencyOpacity` の濃さで
      // 薄く敷く。ロゴ deep background だと青味が強く出すぎるため、
      // 透過時専用のニュートラルカラーを使う。opacity = 0 のときは
      // 背景色を描かず純粋な透過にする。
      // `transparentCenterImagePath` が指定されていれば、暗幕と UI の
      // 間に挟む形で中央に重ね描きする（日本国旗の赤円のイメージ）。
      // 画像は `ClipOval` で円形にくり抜き、サイズは短辺の 60%。
      // 透過率スライダーは暗幕と画像の両方に同じ値で連動させるが、
      // 画像エリアは「画像 + 下の暗幕」が重ね合わさることでデスクトップの
      // 見通しが二重に削れる。素直に同じ alpha を当てると画像が窓より
      // 不透明に見えてしまうため、画像側だけ `opacity * opacity` と
      // 二乗で減衰させて視覚的な透け感を窓側に寄せている。
      // クリック入力は IgnorePointer で素通りさせる。
      AppearanceMode.transparent => _TransparentLayer(
        opacity: appearance.transparencyOpacity,
        centerImagePath: appearance.transparentCenterImagePath,
        centerImageMtime: appearance.transparentCenterImageMtime,
        child: child,
      ),
      AppearanceMode.solid => ColoredBox(
        color: appearance.solidColor != null
            ? Color(appearance.solidColor!)
            : Colors.transparent,
        child: child,
      ),
      AppearanceMode.image => Stack(
        fit: StackFit.expand,
        children: [
          if (appearance.imagePath != null &&
              File(appearance.imagePath!).existsSync())
            Image.file(File(appearance.imagePath!), fit: BoxFit.cover),
          child,
        ],
      ),
      AppearanceMode.gradient => DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.logoTheme.backgroundGradient,
        ),
        child: child,
      ),
    };
  }
}

/// 透過モード用のレイヤー。暗幕 → 中央画像 → UI の順に重ねる。
/// 中央画像が無いケースでは ColoredBox 1 枚で済むよう、Stack を作らずに
/// 軽量側のツリーを返す。
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
    if (!hasCenterImage) {
      return opacity <= 0
          ? child
          : ColoredBox(
              color: AppTheme.transparentBackdrop.withValues(alpha: opacity),
              child: child,
            );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        if (opacity > 0)
          ColoredBox(
            color: AppTheme.transparentBackdrop.withValues(alpha: opacity),
          ),
        Center(
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity * opacity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size =
                      constraints.biggest.shortestSide * _centerSizeRatio;
                  // 同じパスに上書き保存した直後は `FileImage` の equality
                  // が一致するため `Image` widget が再リゾルブせず古い画像
                  // のまま。state 側で渡される更新時刻を ValueKey に乗せ
                  // て widget を強制 remount し、新しいバイト列を読み直す。
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
        ),
        child,
      ],
    );
  }
}
