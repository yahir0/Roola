import 'package:roola/data/keybindings/keybindings.dart';

/// キーボードショートカットのユーザー上書きの永続化抽象（ADR-0033）。
abstract interface class KeybindingsRepository {
  /// 保存済みの上書きを返す。未保存なら空（`Keybindings.empty()`）。
  Future<Keybindings> load();

  /// 上書きを保存する。
  Future<void> save(Keybindings keybindings);
}
