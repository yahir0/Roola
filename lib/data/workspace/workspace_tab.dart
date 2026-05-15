import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/skill_session/adhoc_run_args.dart';

part 'workspace_tab.freezed.dart';

/// ワークスペースのペインに置かれるタブ 1 件。
///
/// タブは種別固定で、エクスプローラ（[ExplorerTab]）かターミナル
/// （[TerminalTab]）のいずれか。生成後に種別は変化しない（ADR-0026）。
///
/// `id` はワークスペース内で一意。`ExplorerViewModel` / `AdhocRunViewModel`
/// など per-tab 状態の family キーに使われ、タブをペイン間で DnD 移動しても
/// この id が変わらないため履歴 / PTY は無損失で引き継がれる（ADR-0027）。
@freezed
sealed class WorkspaceTab with _$WorkspaceTab {
  /// エクスプローラタブ。[currentPath] は現在表示中の絶対パス。
  /// `workspace.json` への永続化・起動時のパス復元に使う（ADR-0028）。
  const factory WorkspaceTab.explorer({
    required String id,
    required String currentPath,
  }) = ExplorerTab;

  /// ターミナルタブ。PTY セッションは [args] をキーに
  /// `adhocRunViewModelProvider` 側で keep-alive 保持される。永続エントリ
  /// 由来のセッションも ad-hoc に正規化して扱う（ADR-0026 design Decision 5）。
  const factory WorkspaceTab.terminal({
    required String id,
    required AdhocRunArgs args,
  }) = TerminalTab;
}
