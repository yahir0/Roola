import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/command_registry.dart';
import 'package:roola/data/keybindings/key_chord.dart';
import 'package:roola/data/keybindings/keybindings_repository_impl.dart';

/// 実効バインディング（ADR-0033）。
///
/// `CommandRegistry` の既定キーコンビと、`keybindingsProvider` のユーザー
/// 上書きをマージし、全コマンドの「現在有効なキーコンビ」を同期的に返す。
/// メニューバー・コンテキストメニュー・設定画面はこれを watch する。
///
/// 全コマンドは常に何らかのキーコンビを持つ（未割り当て状態はない）。
final effectiveKeybindingsProvider = Provider<Map<CommandId, KeyChord>>((ref) {
  final overrides =
      ref.watch(keybindingsProvider).value?.overrides ??
      const <CommandId, KeyChord>{};
  return {
    for (final id in CommandId.values)
      id: overrides[id] ?? CommandRegistry.metadataFor(id).platformDefaultChord,
  };
});
