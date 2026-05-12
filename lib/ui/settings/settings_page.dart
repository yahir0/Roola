import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 設定画面のプレースホルダー実装。
///
/// Section 3 で `SettingsViewModel` 経由のエントリ一覧 CRUD と
/// Section 6 で外観設定セクションを足す。
class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: const Center(
        child: Text('設定画面（実装予定）'),
      ),
    );
  }
}
