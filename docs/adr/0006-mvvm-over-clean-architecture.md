# ADR-0006: Flutter 公式 MVVM を採用（Clean Architecture を採らない）

- **Status**: Accepted
- **Date**: 2026-05-11

## Context

Flutter アプリのアーキテクチャ選択肢として代表的なのは以下:

1. **Flutter 公式 MVVM**（[App architecture guide](https://docs.flutter.dev/app-architecture)）— `ui` / `data` / オプションの `domain` の 3 層、View ↔ ViewModel ↔ Repository
2. **Clean Architecture（4 層）** — presentation / application / domain / infrastructure、Entity / Repository interface / Use Case / DataSource を厳密に分離

本アプリの特性:

- API 通信なし（PTY 制御 + ローカル JSON 永続化のみ）
- MVP で 5 画面程度、後続機能を足しても 8〜10 画面の見込み
- スコープが小さく、複数開発者を前提とした厳密な責務分割は過剰
- 公開 OSS リポジトリとして運用予定
- 長期に単独で保守可能であることが求められる

## Decision

Flutter 公式 architecture guide の MVVM パターンを採用する。`ui` / `data` / `core`（+ 起動系 `app`）の 3 グループ構成。

ただし以下の調整を入れる:

- Use Case 層は作らない（公式ガイドでも optional とされている）
- Repository pattern は **差し替え可能性が必要な箇所のみ** interface + impl の二段構え
- DTO ⇄ モデル分離は **永続化を伴うフィーチャーのみ** 実施
- ViewModel は Riverpod の `Notifier` / `AsyncNotifier`（公式は ChangeNotifier 例示だが、`docs/adr/0003-riverpod-hooks-state-management.md` の判断に従う）

## Why

### 代替案: Clean Architecture（4 層）

却下。理由:

- 本アプリは API 通信を持たないため、Clean Architecture の最大の強み（通信層の厳密分離）が空振りする
- 4 層のファイル増（1 フィーチャーあたり 5〜7 ファイル）に見合うほどのドメイン複雑度が無い
- 公開 OSS リポジトリとして、外部協力者に説明する際に「Clean Architecture の独自変種」を解説するコストが発生する
- 規範文書として参照できるのが書籍・個人記事中心になり、公式ドキュメントの永続性に劣る

### 採用理由（公式 MVVM）

- **規範文書が Flutter 公式 docs に常設** されており、長期参照に耐える
- 1 フィーチャーあたり 3〜4 ファイルで済み、MVP 規模に対して過剰設計にならない
- Riverpod の `Notifier` が ViewModel に 1:1 で対応する
- Flutter コミュニティに「公式 architecture guide 準拠」と説明できれば外部協力者の理解が速い
- 将来規模が大きくなった場合、Use Case 層を後付けで足す経路が公式に示されている

## ハイブリッド要素

純粋な公式 MVVM ではなく、以下を残す:

- **Repository interface の限定採用**: `SkillRunner` interface → `PtySkillRunner` 実装、`LauncherEntryRepository` interface → ローカル JSON 実装。将来差し替えの可能性がある箇所のみ
- **DTO ⇄ モデル分離の限定採用**: 永続化フィーチャーのみ

これらは公式 MVVM でも禁止されておらず、必要に応じて取り入れることが推奨されている。

## Trade-offs

- 規模が将来大きく膨らんだ場合（数十フィーチャー級）、Use Case 層を後付けで足す再構成コストが発生する。本アプリではその規模に達する見込みが薄いため許容
- Clean Architecture の経験者が見ると層構造が「軽い」と感じる可能性があるが、規模との見合いを優先する

## References

- Flutter App architecture guide: https://docs.flutter.dev/app-architecture
- Flutter App architecture case study: https://docs.flutter.dev/app-architecture/case-study
- The Clean Architecture（参考）: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
