import 'package:roola/data/launcher_entry/launcher_action.dart';

/// PTY 起動時に追加注入する、タスク完了通知（ADR-0057）用の環境変数を返す。
///
/// 完了通知の対象は Claude Code セッションのみ。`ClaudeSkillAction` のときだけ
/// `ROOLA_TAB_ID`（当該タブを一意に指す）と `ROOLA_NOTIFY_TOKEN`（アプリ起動
/// ごとのトークン）を返し、それ以外のアクションでは `null`（注入なし）。
Map<String, String>? notificationEnvironment({
  required LauncherAction action,
  required String tabId,
  required String token,
}) {
  if (action is! ClaudeSkillAction) {
    return null;
  }
  return {'ROOLA_TAB_ID': tabId, 'ROOLA_NOTIFY_TOKEN': token};
}
