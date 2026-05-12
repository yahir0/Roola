import 'package:claude_skills_launcher/app/router.dart';
import 'package:claude_skills_launcher/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// アプリ最上位の Widget。
///
/// `ProviderScope` の内側に置く前提で、`MaterialApp.router` を組み立てる。
/// 背景は `theme.dart` 側で `Colors.transparent` を指定しており、
/// `MainFlutterWindow.swift` の透過設定と組み合わせて、ウィンドウ背景の
/// 制御は `appearance` フィーチャー（Section 6 で実装）に委ねる。
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Claude Skills Launcher',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
