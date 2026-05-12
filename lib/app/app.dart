import 'dart:io';

import 'package:claude_skills_launcher/app/router.dart';
import 'package:claude_skills_launcher/app/theme.dart';
import 'package:claude_skills_launcher/app/window_close_guard.dart';
import 'package:claude_skills_launcher/data/appearance/appearance_settings.dart';
import 'package:claude_skills_launcher/data/appearance/appearance_settings_repository_impl.dart';
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
          child: child ?? const SizedBox.shrink(),
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
      AppearanceMode.transparent =>
        appearance.transparencyOpacity <= 0
            ? child
            : ColoredBox(
                color: AppTheme.transparentBackdrop.withValues(
                  alpha: appearance.transparencyOpacity,
                ),
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
