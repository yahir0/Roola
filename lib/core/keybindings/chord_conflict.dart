import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/key_chord.dart';

/// キーコンビの衝突検出（ADR-0033）。同一キーコンビを複数コマンドに割り当て
/// させないため、設定画面の保存前チェックに使う純粋関数。

/// [effective]（実効バインディング）の中で、[candidate] を [target] 以外の
/// コマンドが既に使っていれば、その最初のコマンドを返す。なければ null。
CommandId? conflictingCommand({
  required Map<CommandId, KeyChord> effective,
  required CommandId target,
  required KeyChord candidate,
}) {
  for (final entry in effective.entries) {
    if (entry.key == target) {
      continue;
    }
    if (entry.value == candidate) {
      return entry.key;
    }
  }
  return null;
}

/// [effective] 全体で、同一キーコンビに 2 つ以上のコマンドが割り当たって
/// いる組を返す。キーコンビ → そのコマンド群。
Map<KeyChord, List<CommandId>> findConflicts(
  Map<CommandId, KeyChord> effective,
) {
  final byChord = <KeyChord, List<CommandId>>{};
  for (final entry in effective.entries) {
    byChord.putIfAbsent(entry.value, () => <CommandId>[]).add(entry.key);
  }
  byChord.removeWhere((_, ids) => ids.length < 2);
  return byChord;
}
