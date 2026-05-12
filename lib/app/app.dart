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
/// 背景は `appearanceSettingsProvider` の値に応じて単色 / 画像 / 透過を
/// 切り替える。
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
      AppearanceMode.transparent => child,
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
    };
  }
}
