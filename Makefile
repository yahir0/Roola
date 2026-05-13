# Roola — 開発タスクの薄いラッパー。
#
# FVM を使う場合は `make FLUTTER="fvm flutter" DART="fvm dart" run` のように
# 上書きしてください。
#
# 一覧: `make help`（または引数なしの `make`）。

FLUTTER ?= flutter
DART    ?= dart
DEFINES ?= --dart-define-from-file=dart_defines/prod.json
DEVICE  ?= macos

# Release ビルド成果物と DMG の出力先。
APP_BUNDLE := build/macos/Build/Products/Release/Roola.app
DMG_PATH   := build/Roola.dmg
DMG_VOLUME := Roola

.DEFAULT_GOAL := help

.PHONY: help setup get gen watch run format analyze test check build dmg clean reset

help: ## このヘルプを表示
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-10s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: get gen ## 初回セットアップ（依存取得 + コード生成）

get: ## 依存パッケージを取得
	$(FLUTTER) pub get

gen: ## build_runner で 1 回コード生成
	$(DART) run build_runner build --delete-conflicting-outputs

watch: ## build_runner を watch モードで起動
	$(DART) run build_runner watch --delete-conflicting-outputs

run: ## アプリを起動（Debug ビルド、bundle ID は dev.tech.yahiro.Roola）
	$(FLUTTER) run -d $(DEVICE) $(DEFINES)

format: ## dart format で整形
	$(DART) format lib test

analyze: ## 静的解析
	$(FLUTTER) analyze

test: ## ユニット / ウィジェットテスト
	$(FLUTTER) test

check: format analyze test ## format → analyze → test を順次実行

build: ## Release ビルド（$(APP_BUNDLE) に出力）
	$(FLUTTER) build macos --release $(DEFINES)

dmg: build ## Release ビルド + DMG 作成（$(DMG_PATH) に出力）
	@rm -rf build/dmg-staging $(DMG_PATH)
	@mkdir -p build/dmg-staging
	@cp -R $(APP_BUNDLE) build/dmg-staging/
	@ln -s /Applications build/dmg-staging/Applications
	@hdiutil create -volname "$(DMG_VOLUME)" -srcfolder build/dmg-staging -ov -format UDZO $(DMG_PATH)
	@rm -rf build/dmg-staging
	@echo "DMG: $(DMG_PATH)"

clean: ## ビルド成果物と pub キャッシュ参照をクリア
	$(FLUTTER) clean
	$(FLUTTER) pub get

reset: ## 永続化エントリ・設定を削除（prod / dev 両方）
	rm -rf "$$HOME/Library/Application Support/tech.yahiro.Roola"
	rm -rf "$$HOME/Library/Application Support/dev.tech.yahiro.Roola"
