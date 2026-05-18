import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';

/// ウィンドウ close 操作を捕まえ、アクティブセッションがあれば確認ダイアログを
/// 表示する常駐 Widget。
///
/// `window_manager.setPreventClose(true)` を `main` 側で有効化した前提で、
/// `WindowListener.onWindowClose` から `windowManager.destroy()` を能動的に
/// 呼ぶことで実際の終了タイミングを制御する。
class WindowCloseGuard extends HookConsumerWidget {
  const WindowCloseGuard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      final listener = _Listener(onClose: () => _handleClose(ref));
      windowManager.addListener(listener);
      return () => windowManager.removeListener(listener);
    }, const []);

    return child;
  }

  /// 終了確認ダイアログは root Navigator の context 上で出す必要がある
  /// （`MaterialApp.router` の `builder` 内の context は Navigator の外側で、
  /// `showDialog` が空回りするため）。
  Future<void> _handleClose(WidgetRef ref) async {
    final sessions = ref.read(activeSessionsProvider);
    if (sessions.isEmpty) {
      await windowManager.destroy();
      return;
    }

    final dialogContext = rootNavigatorKey.currentContext;
    if (dialogContext == null) {
      // Navigator がまだ用意されていない異常系。確認なしで閉じると PTY を
      // 取りこぼすので、フォールバックとして閉じないでおく。
      return;
    }
    final confirmed = await showSessionCloseConfirmation(
      dialogContext,
      sessions.length,
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(activeSessionsProvider.notifier).cancelAll();
    await windowManager.destroy();
  }
}

/// セッション残存時に終了確認ダイアログを出す。`true` で「終了する」、
/// それ以外（false / バリア外タップで null）で継続。
///
/// `WindowCloseGuard` から呼ばれるほか、テストで挙動を確認するために
/// 関数として独立して公開する。
Future<bool?> showSessionCloseConfirmation(
  BuildContext context,
  int sessionCount,
) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext);
      return AlertDialog(
        title: Text(l10n.windowCloseConfirmTitle),
        content: Text(l10n.windowCloseConfirmMessage(sessionCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.windowCloseConfirmButton),
          ),
        ],
      );
    },
  );
}

/// `WindowListener` 全メソッドをデフォルト実装しつつ `onWindowClose` だけを
/// 差し替えるためのアダプタ。匿名 mixin の代わりに具象クラスで保持し、
/// `addListener` / `removeListener` の identity を安定させる。
class _Listener extends WindowListener {
  _Listener({required this.onClose});

  final Future<void> Function() onClose;

  @override
  void onWindowClose() {
    onClose();
  }
}
