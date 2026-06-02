import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

/// settings.json へのフック設定のインストール状態。
enum HookInstallStatus {
  /// Roola のフックが検出された。
  installed,

  /// Roola のフックが見つからない（未インストール or ファイル未作成）。
  notInstalled,

  /// ファイルの読み取り・JSON パースに失敗した。
  fileError,
}

/// Roola フックを一意に識別するマーカー文字列。
const _roolaMarker = 'ROOLA_NOTIFY_TOKEN';

/// インストール状態を監視する Provider。
/// install / uninstall 後に [ref.invalidate] で再取得する。
final hookInstallStatusProvider = FutureProvider<HookInstallStatus>(
  (ref) => HookInstaller.status(),
);

/// `~/.claude/settings.json` への Roola フック設定の読み書きを担う。
///
/// - [status]    現在のインストール状態を確認する。
/// - [backup]    書き換え前にバックアップを作成する。
/// - [install]   フックを追加（既存の Roola フックは置き換え）。
/// - [uninstall] Roola のフックを削除する。
abstract final class HookInstaller {
  static File get _file {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE'] ?? ''
        : Platform.environment['HOME'] ?? '';
    return File('$home/.claude/settings.json');
  }

  static Future<HookInstallStatus> status() async {
    try {
      final file = _file;
      if (!await file.exists()) return HookInstallStatus.notInstalled;
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return _containsRoolaHook(json)
          ? HookInstallStatus.installed
          : HookInstallStatus.notInstalled;
    } catch (_) {
      return HookInstallStatus.fileError;
    }
  }

  /// バックアップファイル（`.bak`）を作成し、そのパスを返す。
  /// settings.json が存在しない場合は null を返す。
  static Future<String?> backup() async {
    final file = _file;
    if (!await file.exists()) return null;
    final path = '${file.path}.bak';
    await file.copy(path);
    return path;
  }

  /// [command] を `hooks.Stop` に追加する。
  /// 既存の Roola フックがあれば置き換える（重複防止）。
  static Future<void> install(String command) async {
    final file = _file;
    await file.parent.create(recursive: true);

    Map<String, dynamic> json = {};
    if (await file.exists()) {
      try {
        json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      } catch (_) {
        // 破損 JSON → 空オブジェクトから再構築
      }
    }

    final hooks = Map<String, dynamic>.from(
      (json['hooks'] as Map<String, dynamic>?) ?? {},
    );
    final stop = _stopList(hooks)
      ..removeWhere(_isRoolaEntry)
      ..add({
        'hooks': [
          {'type': 'command', 'command': command},
        ],
      });
    hooks['Stop'] = stop;
    json['hooks'] = hooks;
    await _write(file, json);
  }

  /// `hooks.Stop` から Roola のフックを削除する。
  /// Stop 配列が空になった場合は `Stop` キーを、
  /// hooks オブジェクトが空になった場合は `hooks` キーを除去する。
  static Future<void> uninstall() async {
    final file = _file;
    if (!await file.exists()) return;

    Map<String, dynamic> json;
    try {
      json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final hooks = json['hooks'] as Map<String, dynamic>?;
    if (hooks == null) return;

    final stop = _stopList(hooks)..removeWhere(_isRoolaEntry);
    if (stop.isEmpty) {
      hooks.remove('Stop');
    } else {
      hooks['Stop'] = stop;
    }
    if (hooks.isEmpty) {
      json.remove('hooks');
    } else {
      json['hooks'] = hooks;
    }
    await _write(file, json);
  }

  // ---- internal helpers --------------------------------------------------

  static bool _containsRoolaHook(Map<String, dynamic> json) =>
      _stopList((json['hooks'] as Map<String, dynamic>?) ?? {})
          .any(_isRoolaEntry);

  static List<Map<String, dynamic>> _stopList(Map<String, dynamic> hooks) =>
      ((hooks['Stop'] as List<dynamic>?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

  static bool _isRoolaEntry(Map<String, dynamic> entry) {
    final innerHooks = (entry['hooks'] as List<dynamic>?) ?? [];
    return innerHooks.any((h) {
      final cmd = (h as Map<String, dynamic>)['command'] as String?;
      return cmd?.contains(_roolaMarker) ?? false;
    });
  }

  static Future<void> _write(File file, Map<String, dynamic> json) =>
      file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
}
