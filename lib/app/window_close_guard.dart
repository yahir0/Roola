import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
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
      final listener = _Listener(onClose: () => _handleClose(context, ref));
      windowManager.addListener(listener);
      return () => windowManager.removeListener(listener);
    }, const []);

    return child;
  }

  Future<void> _handleClose(BuildContext context, WidgetRef ref) async {
    final sessions = ref.read(activeSessionsProvider);
    if (sessions.isEmpty) {
      await windowManager.destroy();
      return;
    }

    if (!context.mounted) {
      return;
    }
    final confirmed = await showSessionCloseConfirmation(
      context,
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
    builder: (dialogContext) => AlertDialog(
      title: const Text('終了の確認'),
      content: Text(
        '$sessionCount 件のセッションが残っています。\n'
        '終了するとすべての PTY が終了され、出力履歴も失われます。',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('終了する'),
        ),
      ],
    ),
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
