# ADR-0066: タスク通知を通知エスケープシーケンス（OSC）方式へ移行する

- **Status**: Accepted
- **Date**: 2026-06-11

> **Supersedes**: ADR-0057（Stop フック + ローカル HTTP 受信口）。
> 検討の全経緯は `docs/notes/2026-06-11-ai-era-concept-review.md` と Issue #85 を参照。

## Context

ADR-0057 のタスク完了通知は「Stop フック → jq + curl → 127.0.0.1 の HTTP 受信口 →
トークン + タブ照合 → OS 通知」という経路で動いている。この複雑さの大半は、
**帯域外（out-of-band）で届く信号の出所確認**に由来する: どのセッションからの
通知かを照合するために、環境変数注入・ランダムトークン・ローカル HTTP サーバ・
ポート競合処理が必要になっている。さらに次の不便が指摘された（Issue #85）:

- フックで取れるのは Stop（完了）だけで、許可待ち等の検知に広げるには
  フック種別を増やす必要があり、ユーザーの `~/.claude/settings.json` への
  登録面積が増える（Claude Code 設定の汚染）
- ユーザーが手動でフックを登録しない限り通知が一切動かない

テスターから、ターミナル標準の**通知エスケープシーケンス**（OSC 9 / 777 / 99）を
使う方式が提案された。プログラムが PTY 出力に見えない制御列を印字し、ターミナル
エミュレータがそれを OS 通知に中継する、iTerm2 / kitty / WezTerm / Windows Terminal
が実装済みの枯れたプロトコルである。

スパイク検証（2026-06-11、詳細は notes 参照）で以下を確認した:

- **送信側**: claude 2.1.173 は `preferredNotifChannel`（既定 `auto`）が
  `TERM_PROGRAM` を判別し、`iTerm.app` なら **OSC 9 をネイティブに出力する**。
  PTY に `TERM_PROGRAM=iTerm.app` を注入しただけの実機キャプチャで
  `ESC ] 9 ; Claude needs your permission BEL` を確認（ユーザー設定ゼロ・フックゼロ）。
  kitty / ghostty チャネルも存在する。
- **受信側 macOS**: SwiftTerm は OSC 777（`notify;title;body`）を**組み込みで解釈**し
  `TerminalDelegate.notify(source:title:body:)` を呼ぶ。OSC 9 / 133 は公開 API
  `registerOscHandler(code:handler:)` で追加でき、登録ハンドラは組み込みより優先される。
- **受信側 Windows**: 同梱の xterm.js（ADR-0058 D1）に公開 API `registerOscHandler` がある。
- claude はフォーカストラッキング（CSI ?1004h / FocusIn・FocusOut）で
  「フォーカス中は通知を抑制」する。検証でも FocusOut 注入時のみ OSC 9 が発火した。

## Decision

1. **タスク通知の経路を OSC（in-band）方式に置き換える。** 受信したペイン =
   送信元セッションであり、照合レイヤーは持たない。
2. Roola は自分が起動する PTY に `TERM_PROGRAM=iTerm.app`（実機検証済みの値）を
   注入し、Claude Code のネイティブ通知チャネル（OSC 9）を有効化する。
   フックの登録・案内は行わない。
3. 受信側は **OSC 9 と OSC 777 の両方**を解釈する。
   - macOS: SwiftTerm の `notify` デリゲート実装（777）+ `registerOscHandler(9)` 追加
   - Windows: xterm.js の `registerOscHandler(9)` / `registerOscHandler(777)`
4. **ペインのフォーカス状態を PTY へ転送する**（フォーカス取得で CSI I、喪失で CSI O）。
   claude の「フォーカス中は通知しない」挙動を正しく機能させるため。
5. 通知発射は現行どおりネイティブ通知（macOS: `UNUserNotificationCenter` /
   Windows: `local_notifier`）。通知クリックで該当ペインへフォーカスを戻す経路を
   両 OS で実装する（ADR-0055 のフォーカス復元と接続）。
6. **スコープ原則: Roola が管理対象とするのは Roola 内で起動したセッションのみ。**
   アプリ外で起動されたセッションの観測（フック / JSONL 監視）は行わない。
   「これ一つで AI をコントロールする」の観測境界はアプリ境界とする。
7. ADR-0057 の実装（HTTP 受信口・トークン・フックインストーラ・設定画面のフック節）は
   OSC 版の安定を確認するまで並走させ、その後**撤去する**。並走期間中、
   両経路は通知するイベントが異なる（フック = 完了の瞬間 / OSC = 許可待ち・
   入力待ち 60 秒アイドル）ため互いに抑止せず独立して発射する。
   - 検討の経緯: 「完了の瞬間」の通知は claude ネイティブに存在しないため、
     一度はフック経路を即時完了通知のオプションとして存続させる案を採ったが、
     **Ghostty 等の既存ターミナルも同じ意味論（完了通知 = 60 秒アイドル）で
     運用されている**ことを確認し、独自にフックを維持する理由はないと判断して
     撤去方針に戻した（2026-06-11）。

## Why

- **照合がタダになる**: in-band 信号は受信ペインが送信元そのもの。ADR-0057 が
  払っていたコスト（HTTP サーバ / ポート競合 / トークン / 環境変数照合 /
  settings.json 書換え）は全て「out-of-band 信号の出所確認」のためであり、丸ごと消える。
- **ユーザー設定ゼロ**: スパイクで実証済み。インストール直後から通知が動く。
  Claude Code の設定には一切触れない。
- **ベンダー中立**: OSC はターミナル標準であり Claude の仕様ではない。codex でも
  自作スクリプトでも `printf` 一発で同じ通知経路に乗る。ADR-0016 / ADR-0022 の
  汎用化方針と整合する。
- **拡張の足場になる**: 同じパース基盤で OSC 133（semantic prompt）まで拾えば、
  ペイン単位の「実行中 / 入力待ち」状態検知に到達できる（将来の別 ADR）。
- **Windows と対称**: 両 OS とも「ターミナルレンダラに OSC ハンドラを足す」という
  同型の実装になる。ADR-0057 方式は通知経路が OS ごとに非対称だった。

## Trade-offs

- **「完了の瞬間」の通知は出ない**: claude ネイティブの通知意味論は
  「許可待ち（即時）」と「入力待ち 60 秒アイドル」であり、Stop フックの
  「完了した瞬間」とは異なる。完了から約 60 秒後の
  「Claude is waiting for your input」が完了通知の代替になる。
  これは Ghostty / iTerm2 等でネイティブ通知を使う場合と同一の挙動であり、
  許容する。60 秒を縮めたいユーザーは claude の標準設定
  `messageIdleNotifThresholdMs` で調整できる（Roola 側の実装は不要）。
- **エスケープシーケンス注入**: in-band ゆえ、OSC 9 のバイト列を含むファイルを
  `cat` しただけでも通知が飛びうる。iTerm2 等の既存ターミナルと同じ前提であり、
  dev ツールとして許容する。通知はあくまで注意喚起であり、通知文字列を権限付与等の
  入力として扱わないこと。
- **`TERM_PROGRAM` の偽装**: Roola は iTerm2 ではないのに `iTerm.app` を名乗る。
  CLI ツールが iTerm2 固有機能（OSC 1337 等）を送ってくる可能性があるが、
  SwiftTerm は OSC 1337 を解釈でき、未知シーケンスは無視されるため実害は限定的。
  将来 Claude Code が Roola を直接認識する値を持てば差し替える。
- **アプリ外セッションは見えない**: スコープ原則（Decision 6）として意図的に採用。
  外で始めた作業の取り込みは「過去セッション一覧 + `claude --resume`」のような
  オンランプ（読み取り専用）で別途検討する。
- **ネイティブ作業が増える**: Dart 完結だった ADR-0057 と違い、SwiftTerm / xterm.js の
  両統合に手を入れる。ただしスパイクで両側とも公開 API の存在を確認済みで、
  パーサの自作は不要。

## References

- Issue #85（提案と不確実性の整理）/ 検討経緯: `docs/notes/2026-06-11-ai-era-concept-review.md`
- ADR-0057（Supersede 対象）/ ADR-0031（SwiftTerm 統合）/ ADR-0055（フォーカス復元）/
  ADR-0058（Windows 対応・xterm.js レンダラ）
- スパイク実機ログ: claude 2.1.173 + `TERM_PROGRAM=iTerm.app` で
  `ESC ] 9 ; Claude needs your permission BEL` を確認（2026-06-11）
