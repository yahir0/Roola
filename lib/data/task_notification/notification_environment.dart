/// Claude Code がターミナル判別（`preferredNotifChannel: auto`）に使う値。
/// `iTerm.app` を名乗ると OSC 9 通知をネイティブに出力する（ADR-0066・
/// 実機検証済みの組み合わせ）。
const oscTermProgram = 'iTerm.app';

/// `TERM_PROGRAM_VERSION`。claude は `/^[0-2]\./` を旧版とみなすため 3.x を名乗る。
const oscTermProgramVersion = '3.5.0';

/// PTY 起動時に追加注入する、タスク通知用の環境変数を返す。
///
/// 全アクション共通で `TERM_PROGRAM` / `TERM_PROGRAM_VERSION` を注入し、
/// CLI ツールのネイティブ通知チャネル（OSC 9 等）を有効化する（ADR-0066）。
/// claude 以外のツールも OSC を吐けるため、アクション種別では限定しない。
Map<String, String> notificationEnvironment() {
  return {
    'TERM_PROGRAM': oscTermProgram,
    'TERM_PROGRAM_VERSION': oscTermProgramVersion,
  };
}
