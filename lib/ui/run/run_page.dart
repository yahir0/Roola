import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 実行画面のプレースホルダー実装。
///
/// Section 5 で `RunViewModel` + `xterm` の `TerminalView` に置き換える。
class RunPage extends HookConsumerWidget {
  const RunPage({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('実行: $entryId')),
      body: const Center(
        child: Text('実行画面（実装予定）'),
      ),
    );
  }
}
