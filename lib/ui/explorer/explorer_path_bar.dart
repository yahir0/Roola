import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/system/file_opener.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_glyphs.dart';
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
    final l10n = AppLocalizations.of(context);
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
      ).showSnackBar(SnackBar(content: Text(l10n.explorerPathNotFound(input))));
      controller.text = currentPath;
    }

    final tokens = PolarisTokens.of(context);
    // 計器パネルにインセットした「沈んだ読み取り表示」。太枠のフォーム感を
    // 排し、well 地＋1px ヘアライン枠＋等幅でパスを表示する（ADR-0038 D9）。
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onSubmitted: (_) => submit(),
      style: tokens.mono.copyWith(color: tokens.text),
      decoration: InputDecoration(
        filled: true,
        fillColor: tokens.well,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: PolarisTokens.space3,
            right: PolarisTokens.space2,
          ),
          child: PolarisTypeIcon(isDir: true, color: tokens.textDim),
        ),
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.subdirectory_arrow_left,
            size: PolarisIconSize.small,
          ),
          tooltip: l10n.explorerNavigateToPathTooltip,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 24, height: 24),
          onPressed: submit,
        ),
        // suffixIcon スロットは未指定だと Material 既定の 48px 角を最小確保し、
        // 入力欄全体をその高さまで押し広げる。空の制約でスロットを実アイコン
        // （24px）に合わせ、入力欄を isDense 本来の高さ（≒32px）に収める。
        suffixIconConstraints: const BoxConstraints(),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radius),
          borderSide: BorderSide(color: tokens.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radius),
          borderSide: BorderSide(color: tokens.accent),
        ),
      ),
    );
  }
}
