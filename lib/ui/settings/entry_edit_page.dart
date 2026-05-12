import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// エントリ追加・編集画面のプレースホルダー実装。
///
/// Section 3 で表示名・リポジトリパス・Skill 名・アイコン入力を実装する。
/// `entryId == null` の場合は新規作成、それ以外は編集。
class EntryEditPage extends HookConsumerWidget {
  const EntryEditPage({required this.entryId, super.key});

  final String? entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNew = entryId == null;
    return Scaffold(
      appBar: AppBar(title: Text(isNew ? 'エントリ追加' : 'エントリ編集')),
      body: Center(
        child: Text(isNew ? '新規エントリ（実装予定）' : 'エントリ $entryId（実装予定）'),
      ),
    );
  }
}
