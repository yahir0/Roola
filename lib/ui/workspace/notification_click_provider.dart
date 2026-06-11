import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:roola/data/task_notification/task_notification_repository.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/workspace/window_activation_provider.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';

part 'notification_click_provider.g.dart';

/// 通知クリック → 該当ペインへのフォーカス復帰（ADR-0066）。
///
/// [TaskNotificationRepository.onNotificationClick] に復帰ハンドラを登録し、
/// クリックされた通知の `sessionId`（ad-hoc セッション id）からターミナル
/// タブを特定してアクティブ化する。ウィンドウの前面化は OS（通知クリックに
/// よるアプリ activate）に任せ、ペイン内のフォーカス復帰は ADR-0055 の
/// 復帰経路（`windowActivationProvider`）を `bump` で再利用する。
///
/// 通知元タブが既に閉じられている場合は何もしない（エラーも出さない）。
/// keepAlive: 起動時に `App` から watch して常駐させる。
@Riverpod(keepAlive: true)
class NotificationClick extends _$NotificationClick {
  @override
  void build() {
    final repository = ref.read(taskNotificationRepositoryProvider);
    repository.onNotificationClick = _focusSession;
    ref.onDispose(() => repository.onNotificationClick = null);
  }

  void _focusSession(String sessionId) {
    final layout = ref.read(workspaceProvider);
    for (final slotId in PaneSlotId.values) {
      for (final tab in layout.slot(slotId).tabs) {
        if (tab is TerminalTab && tab.args.adhocId == sessionId) {
          ref.read(workspaceProvider.notifier).activateTab(tab.id);
          // アクティブ化で生成された TerminalSurface がマウントを終えた後に
          // 復帰シグナルを流す（マウント前だと ref.listen が未登録で届かない）。
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(windowActivationProvider.notifier).bump();
          });
          return;
        }
      }
    }
  }
}
