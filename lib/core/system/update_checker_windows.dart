import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:roola/app/router.dart';
import 'package:roola/core/system/update_checker.dart';

/// Windows 実装: GitHub Releases API を参照してバージョンを比較し、
/// 結果ダイアログを表示する。自動ダウンロードは行わない。
class UpdateCheckerWindows implements UpdateChecker {
  static const _releasesUrl =
      'https://api.github.com/repos/yahiro0/Roola/releases/latest';

  @override
  Future<void> checkForUpdates() async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    await _check(context);
  }

  Future<void> _check(BuildContext context) async {
    String latestVersion;
    try {
      final resp = await Dio().get<Map<String, dynamic>>(
        _releasesUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ),
      );
      final tag = (resp.data?['tag_name'] as String?) ?? '';
      latestVersion = tag.startsWith('v') ? tag.substring(1) : tag;
    } catch (_) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('アップデートの確認'),
          content: Text(
            'バージョン情報を取得できませんでした。\nネットワーク接続を確認してください。',
          ),
        ),
      );
      return;
    }

    final info = await PackageInfo.fromPlatform();
    final current = info.version;

    if (!context.mounted) return;
    if (latestVersion == current || latestVersion.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('アップデートの確認'),
          content: Text('最新バージョン（$current）を使用しています。'),
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('アップデートの確認'),
          content: Text(
            '新しいバージョン $latestVersion が利用可能です（現在: $current）。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
    }
  }
}
