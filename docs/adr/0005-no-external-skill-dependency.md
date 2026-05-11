# ADR-0005: 外部 Skill / プラグインに依存しない自己完結方針

- **Status**: Accepted
- **Date**: 2026-05-11

## Context

本リポジトリは公開 OSS リポジトリとして運用し、長期に渡って単独で保守できる状態を維持することを目指す。AI ツール（Claude Code / Cursor 等）に依存して開発する場合でも、リポジトリ自体は **AI ツールの特定 Skill / プラグインに依存しない** ことが求められる。

理由:

- 公開リポジトリの外部協力者は、開発者個人のローカルにインストールされた Skill / プラグインを利用できない
- AI ツール側の Skill / プラグインは将来変更・廃止される可能性があり、それに依存する規約はドリフトを起こす
- リポジトリの規約・設計判断は **リポジトリ自体に文書化** され、リポジトリだけ読めば理解・保守できる状態であるべき

## Decision

- 本リポジトリの規約・設計判断はすべて `CLAUDE.md` / `docs/architecture.md` / `docs/coding-standards.md` / `docs/adr/` に集約する
- 外部 Skill / プラグインを開発時に利用してもよいが、その内容を **本リポジトリのドキュメントに転記・依存させない**
- AI ツールがリポジトリで作業する際は、本リポジトリの `CLAUDE.md` と `docs/` のみを規範とする
- 個人開発環境では `.claude/settings.local.json`（gitignored）で外部 Skill の auto-load を抑制し、混入リスクを下げる

## Why

### 代替案 1: 外部 Skill / プラグインを規範として利用する

却下。理由:

- 公開リポジトリ化した瞬間、外部協力者はその Skill にアクセスできず、規約理解の障壁になる
- Skill の更新があった場合、リポジトリの暗黙の前提が変わる
- リポジトリ単体での保守性が損なわれる

### 採用理由（自己完結）

- リポジトリのみで規約・設計判断が完結する
- 外部依存が無いため、AI ツール側の変更に影響を受けない
- 外部協力者と開発者個人で見ているドキュメントが一致する
- 公開ドキュメント（Flutter 公式・Riverpod 公式・Effective Dart 等）を出典としているため、リンク切れ・廃版リスクが少ない

## Trade-offs

- すべての規約・判断を自前で文書化するコストが発生する（CLAUDE.md / docs/ の初期整備）
- 外部 Skill が更新されても自動追従しない（手動で取り込み判断する）
- 開発時の個人向け効率化（Skill による補完）と、リポジトリ規範（自己完結ドキュメント）を意図的に分離する必要がある

## Implementation Notes

- 個人開発環境では `.claude/settings.local.json`（gitignored）に以下のような設定で外部 Skill の auto-load を抑制する:

  ```json
  {
    "skillOverrides": {
      "<plugin-namespace>:<skill-name>": "off"
    }
  }
  ```

- 設定は Claude Code の公式ドキュメントに従う: https://code.claude.com/docs/en/skills.md#override-skill-visibility-from-settings

## References

- Flutter 公式 architecture guide: https://docs.flutter.dev/app-architecture
- Effective Dart: https://dart.dev/effective-dart
- Riverpod 公式: https://riverpod.dev
