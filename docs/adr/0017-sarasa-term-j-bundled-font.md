# ADR-0017: ターミナル描画フォントに Sarasa Term J を同梱する

- **Status**: Accepted
- **Date**: 2026-05-14

## Context

セッションビューの `TerminalView` (xterm 4.0.0) は、`textStyle` を指定しない場合 xterm のデフォルト
`fontFamily: 'monospace'` で描画される。macOS では `fontFamilyFallback` の先頭にある **Menlo** が選ばれる。

Menlo は丸みの強いグリフ・広めの字幅で「やわらかい」見た目になり、ターミナルとしての視認性（i / l / 1 / I の判別、
細い縦ストロークによるシャープさ）が出にくい。ユーザーから「Arch Linux の素のターミナルのような、はっきりして
細いフォントにしたい」というフィードバックが入った。

要件:

- ストロークが細くシャープ
- グリフ幅が狭く、画面に多くの文字が収まる
- 紛らわしい文字（i / l / 1 / I, 0 / O など）が判別しやすい
- ligature を持たない（Claude Code 出力の `->`, `=>`, `!=` 等が意図しない結合で潰れない）
- **日本語も同じテイスト**（ASCII だけ Iosevka でフォールバックで Hiragino になると、丸さが混ざってちぐはぐ）

## Decision

**Sarasa Term J Regular / Bold をリポジトリに同梱し、`TerminalView.textStyle` で明示的に指定する。**

Sarasa Term J は [Iosevka Term](https://typeof.net/Iosevka/) と [Source Han Sans JP](https://github.com/adobe-fonts/source-han-sans)
を合成したフォント。ASCII グリフは Iosevka Term と同一、日本語はそれに合わせた細めのシャープなゴシック体。

- 配置: `assets/fonts/SarasaTermJ-Regular.ttf` / `SarasaTermJ-Bold.ttf`（各 ~25MB / 計 ~50MB）
- ライセンス: `assets/fonts/LICENSE-SarasaTermJ.md` に SIL OFL 1.1 を同梱
- 登録: `pubspec.yaml` の `flutter.fonts` に `family: SarasaTermJ` で登録、Bold は `weight: 700`
- 適用: `lib/ui/explorer/session_view.dart` の `_terminalStyle` で
  `TerminalStyle(fontFamily: 'SarasaTermJ', ...)` を `TerminalView` に渡す
- `fontFamilyFallback` は絵文字と最終フォールバックのみ。CJK / 記号は Sarasa Term J 内で完結させて、グリフ単位で
  フォントが切り替わることによる「ちぐはぐ感」を避ける

## Why

「Arch Linux の素のターミナル風」「細い」「はっきり」を最も素直に満たすのが Iosevka 系。Iosevka 単体は
ASCII / 拡張ラテンに特化していて CJK は持たないため、日本語は OS フォント（macOS では Hiragino）にフォールバック
することになる。これだと:

- 英数字: Iosevka 由来の細くシャープなセリフレス
- 日本語: Hiragino の丸みのあるゴシック

…の混在になり、ターミナル全体としての見た目の一貫性が崩れる。

**Sarasa Term J** はまさにこの問題を解決するために作られたフォント:

- Latin 側は Iosevka Term そのものを使用（terminal 特化・ligature 無効）
- CJK 側は Source Han Sans JP を Iosevka と字幅・字高が合うように調整して合成
- 結果として、ASCII と日本語が同じトーン（細さ・シャープさ・字幅）で並ぶ

リポジトリ単体で完結する自己完結方針（ADR-0005）と整合する。OS インストール済みフォントに頼ると環境差で
見た目が変わってしまうため、再現性を取るには bundle するのが最も確実。

### 代替案 1: macOS 既存フォント（Monaco / SF Mono / Courier New）+ Hiragino

- ファイル同梱不要で binary size が増えない
- だが Monaco / SF Mono / Courier New いずれもユーザーの「ArchLinux 風で細い」要件には届かない
- 日本語は Hiragino にフォールバックされ、ASCII との一貫性が崩れる
- 却下: 要件未達

### 代替案 2: Iosevka Term のみ同梱 + 日本語は OS フォントにフォールバック

- 当初採用した案（このリポジトリの最初の実装）
- ASCII は完璧だが、日本語が Hiragino にフォールバックされてトーンが揃わない
- ユーザーから「日本語も同じ感じにしたい」とフィードバック
- 却下: 日本語の一貫性が出ない

### 代替案 3: Iosevka Term + Sarasa Term J を併用（Iosevka をプライマリ、Sarasa をフォールバック）

- 理論上は ASCII を Iosevka Term、日本語を Sarasa Term J が拾う
- だが Sarasa Term J の ASCII は Iosevka Term と同一なので、Iosevka Term を別途同梱する意味がない
- ファイルサイズも 70MB と無駄に肥大する
- 却下: Sarasa Term J 単体で同じ結果が得られる

### 代替案 4: HackGen / PlemolJP / UDEV Gothic など他の日本語コーディングフォント

- いずれも英数字側のベースが Hack / IBM Plex / JetBrains Mono など
- 「細い・狭い・シャープ」という意味で Iosevka より広めの字幅・太めのストローク
- 却下: Iosevka と同じテイストにしたいという要件と合わない

### 代替案 5: Noto Sans Mono CJK JP（Google 配布の CJK モノスペース）

- 無料で CJK 全部入り
- だがストロークが太めで「細い」要件には合わない
- 却下: 要件未達

## Trade-offs

- **バイナリサイズ増**: Regular + Bold で約 **50MB** 増加（各 ~25MB）。CJK 全文字をカバーするため 1 ファイルが
  大きい。Roola の DMG が 24MB → ~74MB 程度になる見込み。最初に試した Iosevka Term 単体（20MB）から +30MB。
- **ライセンス義務**: Sarasa Gothic は [SIL Open Font License 1.1](https://github.com/be5invis/Sarasa-Gothic/blob/main/LICENSE)。
  Iosevka と Source Han Sans の派生物として、両方の copyright を含む LICENSE を同梱する必要がある
  → `assets/fonts/LICENSE-SarasaTermJ.md` に配置済み。
- **CJK 言語のターゲット**: 「J」variant は日本語優先（漢字の字形が日本字形）。中国語や韓国語のテキストを
  表示すると、共有 CJK コードポイント部分が日本字形で出る。Roola は日本語環境前提なので問題ない。
- **将来的なフォント切替 UI は未対応**: 現状はコードベタ書き。ユーザー設定でフォントを切り替えたくなったら別
  change で対応する。
- **絵文字フォールバック**: 絵文字は Sarasa にも含まれないので Apple Color Emoji / Noto Color Emoji に
  フォールバック。これは別フォントなのでトーンが微妙にずれるが、絵文字はカラー描画なので意図的に
  「別物として扱う」のが妥当。

## References

- [Sarasa Gothic](https://github.com/be5invis/Sarasa-Gothic)
- [Sarasa Gothic v1.0.37 release](https://github.com/be5invis/Sarasa-Gothic/releases/tag/v1.0.37)
- [Iosevka](https://typeof.net/Iosevka/)
- [Source Han Sans](https://github.com/adobe-fonts/source-han-sans)
- xterm.dart の `TerminalStyle` 実装: `~/.pub-cache/hosted/pub.dev/xterm-4.0.0/lib/src/ui/terminal_text_style.dart`
