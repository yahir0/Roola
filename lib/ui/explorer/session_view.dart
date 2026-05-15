import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';
import 'package:roola/ui/common/session_state_icon.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';
import 'package:xterm/xterm.dart';

/// ターミナル描画フォント。pubspec.yaml に登録した Sarasa Term J を主に使う。
///
/// Sarasa Term J は Iosevka Term（ASCII）と Source Han Sans JP（CJK）を
/// 合成した CJK 対応モノスペース。ASCII グリフは Iosevka Term と同一で
/// 細くシャープ、日本語も同じテイストのゴシック体で描画される。
/// 「Arch Linux の素のターミナル」寄りの見た目を狙う（ADR-0017）。
///
/// `fontFamilyFallback` は絵文字と最終フォールバックのみ残す。Sarasa Term J
/// が CJK・記号類をほぼカバーするので、Menlo 等のフォールバックは挟まない
/// 方が見た目の一貫性が出る。
const TerminalStyle _terminalStyle = TerminalStyle(
  fontFamily: 'SarasaTermJ',
  fontFamilyFallback: [
    'Apple Color Emoji',
    'Noto Color Emoji',
    'monospace',
    'sans-serif',
  ],
);

const TerminalTheme _terminalTheme = TerminalTheme(
  cursor: Color(0xFF90C0F0),
  selection: Color(0x665080C0),
  foreground: Color(0xFFE0E0E0),
  background: Color(0xFF1E232A),
  black: Color(0xFF000000),
  red: Color(0xFFCD3131),
  green: Color(0xFF0DBC79),
  yellow: Color(0xFFE5E510),
  blue: Color(0xFF2472C8),
  magenta: Color(0xFFBC3FBC),
  cyan: Color(0xFF11A8CD),
  white: Color(0xFFE5E5E5),
  brightBlack: Color(0xFF666666),
  brightRed: Color(0xFFF14C4C),
  brightGreen: Color(0xFF23D18B),
  brightYellow: Color(0xFFF5F543),
  brightBlue: Color(0xFF3B8EEA),
  brightMagenta: Color(0xFFD670D6),
  brightCyan: Color(0xFF29B8DB),
  brightWhite: Color(0xFFFFFFFF),
  searchHitBackground: Color(0xFFFFFF2B),
  searchHitBackgroundCurrent: Color(0xFF31FF26),
  searchHitForeground: Color(0xFF000000),
);

/// ターミナルセッション 1 件分のビュー（ターミナルタブの body）。
///
/// ヘッダ行（状態 chip + キャンセル / 再実行）と、その下の `TerminalView`
/// の縦並び。タブを閉じる操作はタブストリップの × が担うため、ここには
/// 閉じるボタンを置かない（ADR-0026）。
///
/// PTY は `adhocRunViewModelProvider` 側で keep-alive 保持されるので、この
/// widget が dispose されても出力は失われない。
class SessionView extends ConsumerWidget {
  const SessionView(this.args, {super.key});

  final AdhocRunArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(adhocRunViewModelProvider(args));
    final notifier = ref.read(adhocRunViewModelProvider(args).notifier);

    return Column(
      children: [
        _SessionHeader(
          title: pageState.entry.displayName,
          state: pageState.runState,
          onCancel: notifier.cancelRun,
          onRestart: notifier.restart,
        ),
        const Divider(height: 1),
        Expanded(
          child: TerminalView(
            pageState.runner.terminal,
            theme: _terminalTheme,
            textStyle: _terminalStyle,
            // 内部 Container を完全透過にし、`_AppearanceLayer` の暗幕を
            // そのまま見せる。
            backgroundOpacity: 0,
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }
}

/// セッションビューの上端に置くヘッダ。表示名・状態 chip・操作ボタンを
/// 横一列に並べる。
class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.title,
    required this.state,
    required this.onCancel,
    required this.onRestart,
  });

  final String title;
  final SkillRunState state;
  final Future<void> Function() onCancel;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final isRunning =
        state is SkillRunStarting ||
        state is SkillRunRunning ||
        state is SkillRunWaitingInput;
    final isTerminated =
        state is SkillRunCompleted ||
        state is SkillRunFailed ||
        state is SkillRunCancelled;
    final label = switch (state) {
      SkillRunIdle() => '待機中',
      SkillRunStarting() => '起動中…',
      SkillRunRunning() => '実行中',
      SkillRunWaitingInput() => '入力待ち',
      SkillRunCompleted(:final exitCode) =>
        exitCode == 0 ? '完了 (0)' : '終了 ($exitCode)',
      SkillRunFailed() => '失敗',
      SkillRunCancelled() => 'キャンセル',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Chip(
            avatar: sessionStateAvatar(state),
            label: Text(label),
            visualDensity: VisualDensity.compact,
          ),
          if (isRunning)
            IconButton(
              icon: const Icon(Icons.stop),
              tooltip: 'キャンセル (PTY を終了。出力履歴は残る)',
              onPressed: onCancel,
            ),
          if (isTerminated)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '再実行',
              onPressed: onRestart,
            ),
          if (state is SkillRunFailed) ...[
            const SizedBox(width: 4),
            Tooltip(
              message: (state as SkillRunFailed).message,
              child: const Icon(Icons.info_outline),
            ),
          ],
        ],
      ),
    );
  }
}
