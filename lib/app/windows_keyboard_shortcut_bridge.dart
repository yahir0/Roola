import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/command_dispatcher.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/ui/settings/key_chord_recorder_dialog.dart';

/// Windows 専用: HardwareKeyboard ハンドラでアプリショートカットをディスパッチする。
///
/// macOS では PlatformMenuBar が OSレベルのキー等価判定（ADR-0052）で
/// ショートカットを発火させる。Windows では PlatformMenuBar が no-op のため、
/// HardwareKeyboard.addHandler() で同等処理を実装する。
///
/// このハンドラはフォーカスツリーより先に発火するため、WebView2 ターミナルに
/// フォーカスがある場合を除き（WebView2 はネイティブウィンドウとして OS レベルで
/// キーを受け取るため Flutter の HardwareKeyboard に届かない）、すべての Flutter
/// フォーカス状態でショートカットが機能する。
///
/// EditableText（テキストフィールド）にフォーカスがあるときはスキップして
/// テキスト編集ショートカットと競合しない。
class WindowsKeyboardShortcutBridge extends HookConsumerWidget {
  const WindowsKeyboardShortcutBridge({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Platform.isWindows) return child;

    final effective = ref.watch(effectiveKeybindingsProvider);
    final recording = ref.watch(keybindingRecordingProvider);

    useEffect(() {
      bool handler(KeyEvent event) {
        if (event is! KeyDownEvent) return false;
        // キーレコーダが開いている間はすべてのショートカットを無効化する。
        if (recording) return false;
        // テキストフィールドにフォーカスがある場合はスキップする。
        if (_isEditableTextFocused()) return false;

        for (final entry in effective.entries) {
          final activator = toSingleActivator(entry.value);
          if (activator.accepts(event, HardwareKeyboard.instance)) {
            dispatchCommand(entry.key, ref);
            return true;
          }
        }
        return false;
      }

      HardwareKeyboard.instance.addHandler(handler);
      return () => HardwareKeyboard.instance.removeHandler(handler);
    }, [effective, recording]);

    return child;
  }
}

/// フォーカスが EditableText の中にあるかを確認する。
bool _isEditableTextFocused() {
  final focus = FocusManager.instance.primaryFocus;
  if (focus == null) return false;
  final ctx = focus.context;
  if (ctx == null) return false;
  if (ctx.widget is EditableText) return true;
  return ctx.findAncestorStateOfType<EditableTextState>() != null;
}
