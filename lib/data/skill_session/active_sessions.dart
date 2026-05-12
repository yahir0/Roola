import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_sessions.g.dart';

/// 実行中・終了済みのスキルセッションを `entryId` 単位で一元管理するレジストリ。
///
/// ライフサイクルは `RunViewModel.build()` での `register` から
/// 明示的な `unregister`（「閉じる」操作）まで。state 変化は `updateState`
/// で都度反映する。ホーム画面の chip 列とエントリアイコンのバッジは
/// この Notifier を購読することで状態変化を受け取る。
@Riverpod(keepAlive: true)
class ActiveSessions extends _$ActiveSessions {
  /// `cancelAll` で呼ぶための、entry ごとの PTY 終了ハンドル。state には
  /// 載せず内部 Map に保持することで、UI 購読側の比較コストを下げる。
  final Map<String, Future<void> Function()> _cancelHandlers = {};

  @override
  Map<String, SkillRunState> build() => const {};

  /// セッション開始時に呼ぶ。`cancel` は PTY を SIGTERM するクロージャで、
  /// アプリ終了時の一括終了に使われる。
  void register({
    required String entryId,
    required SkillRunState initialState,
    required Future<void> Function() cancel,
  }) {
    _cancelHandlers[entryId] = cancel;
    state = {...state, entryId: initialState};
  }

  /// 状態遷移を反映する。未登録の id は無視する（race 回避）。
  void updateState(String entryId, SkillRunState next) {
    if (!state.containsKey(entryId)) {
      return;
    }
    state = {...state, entryId: next};
  }

  /// セッションをレジストリから除去する。PTY の終了は呼び出し側が行う。
  void unregister(String entryId) {
    _cancelHandlers.remove(entryId);
    if (!state.containsKey(entryId)) {
      return;
    }
    final next = Map<String, SkillRunState>.from(state)..remove(entryId);
    state = next;
  }

  /// 登録中の全セッションを PTY ごと終了する。アプリ終了時にまとめて呼ぶ。
  Future<void> cancelAll() async {
    final handlers = List<Future<void> Function()>.from(_cancelHandlers.values);
    await Future.wait(handlers.map((h) => h()));
  }
}
