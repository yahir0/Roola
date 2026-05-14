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

# 配布用署名・公証の設定。
# - SIGN_IDENTITY: codesign に渡す Developer ID Application 証明書の識別子。
# - NOTARY_PROFILE: xcrun notarytool store-credentials で Keychain に保存した
#   プロファイル名。
# - ENTITLEMENTS: メインアプリ署名時に焼き付ける entitlements。
SIGN_IDENTITY  ?= Developer ID Application: YAHIRO SUGIYAMA (5NDCZDZ75J)
NOTARY_PROFILE ?= roola-notary
ENTITLEMENTS   := macos/Runner/Release.entitlements

.DEFAULT_GOAL := help

.PHONY: help setup get gen watch run format analyze test check build sign dmg notarize staple dist clean reset

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

sign: build ## Developer ID で .app を Hardened Runtime 付きで再帰署名
	@echo "Signing inner contents under $(APP_BUNDLE) ..."
	@find "$(APP_BUNDLE)/Contents/Frameworks" -type f \( -name "*.dylib" -o -name "*.so" \) \
		-exec codesign --force --options runtime --timestamp \
			--sign "$(SIGN_IDENTITY)" {} \;
	@find "$(APP_BUNDLE)/Contents/Frameworks" -type d -name "*.framework" \
		-exec codesign --force --options runtime --timestamp \
			--sign "$(SIGN_IDENTITY)" {} \;
	@echo "Signing main app bundle ..."
	@codesign --force --options runtime --timestamp \
		--entitlements "$(ENTITLEMENTS)" \
		--sign "$(SIGN_IDENTITY)" "$(APP_BUNDLE)"
	@codesign --verify --deep --strict --verbose=2 "$(APP_BUNDLE)"

dmg: sign ## Release ビルド + 署名 + DMG 作成（$(DMG_PATH) に出力）
	@rm -rf build/dmg-staging $(DMG_PATH)
	@mkdir -p build/dmg-staging
	@cp -R $(APP_BUNDLE) build/dmg-staging/
	@ln -s /Applications build/dmg-staging/Applications
	@hdiutil create -volname "$(DMG_VOLUME)" -srcfolder build/dmg-staging -ov -format UDZO $(DMG_PATH)
	@rm -rf build/dmg-staging
	@echo "DMG: $(DMG_PATH)"

notarize: ## DMG を Apple に提出し、公証の完了まで待つ（要: make dmg 済み）
	@xcrun notarytool submit "$(DMG_PATH)" \
		--keychain-profile "$(NOTARY_PROFILE)" --wait

staple: ## 公証チケットを DMG にステープリング（要: notarize 済み）
	@xcrun stapler staple "$(DMG_PATH)"
	@xcrun stapler validate "$(DMG_PATH)"

dist: dmg notarize staple ## 配布用 DMG をビルド・署名・公証・ステープルまで一気通貫
	@echo "Distribution DMG ready: $(DMG_PATH)"

clean: ## ビルド成果物と pub キャッシュ参照をクリア
	$(FLUTTER) clean
	$(FLUTTER) pub get

reset: ## 永続化エントリ・設定を削除（prod / dev 両方）
	rm -rf "$$HOME/Library/Application Support/tech.yahiro.Roola"
	rm -rf "$$HOME/Library/Application Support/dev.tech.yahiro.Roola"
