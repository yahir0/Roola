import 'package:claude_skills_launcher/app/router.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ホーム画面のプレースホルダー実装。
///
/// Section 4 で `HomeViewModel` を介した登録エントリ一覧描画に置き換える。
/// 現時点では遷移導線のみ確認できる状態で配置する。
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claude Skills Launcher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: () => const SettingsRoute().go(context),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps, size: 64),
            SizedBox(height: 16),
            Text('登録されたランチャーがまだありません'),
            SizedBox(height: 8),
            Text('右上の設定からエントリを追加してください'),
          ],
        ),
      ),
    );
  }
}
