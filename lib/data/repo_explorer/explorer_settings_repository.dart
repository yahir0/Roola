import 'package:claude_skills_launcher/data/repo_explorer/explorer_settings.dart';

/// エクスプローラ画面の永続化対象状態の抽象。
abstract interface class ExplorerSettingsRepository {
  /// 保存済みの設定を返す。未保存なら既定値（`rootPath` = null）を返す。
  Future<ExplorerSettings> load();

  /// 設定を上書き保存する。
  Future<void> save(ExplorerSettings settings);
}
