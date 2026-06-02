import 'package:roola/data/terminal_settings/terminal_settings.dart';

/// ターミナル設定の永続化インタフェース。
abstract interface class TerminalSettingsRepository {
  Future<TerminalSettings> load();
  Future<void> save(TerminalSettings settings);
}
