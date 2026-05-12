# Claude Skills Launcher — 開発タスクの薄いラッパー。
#
# FVM を使う場合は `make FLUTTER="fvm flutter" DART="fvm dart" run` のように
# 上書きしてください。
#
# 一覧: `make help`（または引数なしの `make`）。

FLUTTER ?= flutter
DART    ?= dart
DEFINES ?= --dart-define-from-file=dart_defines/prod.json
DEVICE  ?= macos

.DEFAULT_GOAL := help

.PHONY: help setup get gen watch run format analyze test check clean reset

help: ## このヘルプを表示
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-10s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: get gen ## 初回セットアップ（依存取得 + コード生成）

get: ## 依存パッケージを取得
	$(FLUTTER) pub get

gen: ## build_runner で 1 回コード生成
	$(DART) run build_runner build --delete-conflicting-outputs

watch: ## build_runner を watch モードで起動
	$(DART) run build_runner watch --delete-conflicting-outputs

run: ## アプリを起動（DEVICE=macos / DEFINES=...）
	$(FLUTTER) run -d $(DEVICE) $(DEFINES)

format: ## dart format で整形
	$(DART) format lib test

analyze: ## 静的解析
	$(FLUTTER) analyze

test: ## ユニット / ウィジェットテスト
	$(FLUTTER) test

check: format analyze test ## format → analyze → test を順次実行

clean: ## ビルド成果物と pub キャッシュ参照をクリア
	$(FLUTTER) clean
	$(FLUTTER) pub get

reset: ## 永続化されたエントリ・設定を削除
	rm -rf "$$HOME/Library/Application Support/io.github.yahir0.claude_skills_launcher"
