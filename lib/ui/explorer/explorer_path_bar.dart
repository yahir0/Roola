import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/system/file_opener.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';

/// エクスプローラタブ上部の編集可能なパスバー。
///
/// 表示中のパスをテキストフィールドに常時同期し、ユーザーが直接編集して
/// Enter（または右側の矢印ボタン）で確定するとそのパスに移動する。
/// 入力されたパスがディレクトリならそこに移動し、ファイルなら OS の
/// デフォルトアプリで開く（ファイル一覧クリック時と同じ挙動）。
/// パス自体が存在しない場合は SnackBar で通知して入力をリセット。
///
/// [tabId] は所属するエクスプローラタブの id。`explorerViewModelProvider`
/// の family キーに使う（ADR-0027）。
class ExplorerPathBar extends HookConsumerWidget {
  const ExplorerPathBar({
    required this.tabId,
    required this.currentPath,
    super.key,
  });

  final String tabId;
  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(text: currentPath);
    final focusNode = useFocusNode();

    // 外部からのナビゲート（タイルクリック / お気に入り / Back）で
    // currentPath が変わったらフィールドも追従する。ただしフィールドが
    // フォーカス中（ユーザーが編集中）は上書きしない。
    useEffect(() {
      if (!focusNode.hasFocus && controller.text != currentPath) {
        controller.text = currentPath;
      }
      return null;
    }, [currentPath]);

    Future<void> submit() async {
      final input = controller.text.trim();
      if (input.isEmpty) {
        controller.text = currentPath;
        return;
      }
      if (Directory(input).existsSync()) {
        ref.read(explorerViewModelProvider(tabId).notifier).navigateTo(input);
        focusNode.unfocus();
        return;
      }
      if (File(input).existsSync()) {
        await ref.read(fileOpenerProvider).open(input);
        // パスバーはカレントディレクトリ表記に戻す（ファイルを開いた後も
        // 表示中ディレクトリは変わらない）。
        controller.text = currentPath;
        focusNode.unfocus();
        return;
      }
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('パスが存在しません: $input')));
      controller.text = currentPath;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onSubmitted: (_) => submit(),
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: const Icon(Icons.folder_outlined, size: 20),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.subdirectory_arrow_left, size: 18),
            tooltip: 'このパスに移動',
            onPressed: submit,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
