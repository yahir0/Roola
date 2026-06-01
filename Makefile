# Roola — 開発タスクの薄いラッパー。
#
# FVM を使う場合は `make FLUTTER="fvm flutter" DART="fvm dart" run` のように
# 上書きしてください。
#
# 一覧: `make help`（または引数なしの `make`）。

FLUTTER ?= flutter
DART    ?= dart
DEFINES ?= --dart-define-from-file=dart_defines/prod.json

# OS を自動判定して実行デバイスを決める。明示的に上書き可能。
#   make run              → OS に合わせて macos / windows を自動選択
#   make run DEVICE=linux → 強制指定
ifeq ($(OS),Windows_NT)
  DEVICE ?= windows
  # GnuWin32 make はデフォルトで sh.exe を探すが、Windows 環境では
  # cmd.exe を明示指定しないと .bat ファイル（flutter.bat 等）を
  # 実行できない。
  SHELL := C:\Windows\System32\cmd.exe
  .SHELLFLAGS := /c
else
  DEVICE ?= macos
endif

# Release ビルド成果物と DMG の出力先。
# DMG_VOLUME はマウント時のボリューム名。app 名と同じ "Roola" にすると、
# Roola.app が /Applications にインストール済み（＝開発機では常にそう）の
# とき macOS の App Management 保護が /Volumes/Roola/Roola.app への書き込み
# を「起動中アプリの改変」と見なしてブロックし hdiutil create が失敗する。
# ボリューム名を app 名と別にして回避する。
APP_BUNDLE     := build/macos/Build/Products/Release/Roola.app
DMG_PATH       := build/Roola.dmg
DMG_VOLUME     := Roola Installer
WIN_EXE_DIR    := build/windows/x64/runner/Release

# 配布用署名・公証の設定。
# - SIGN_IDENTITY: codesign に渡す Developer ID Application 証明書の識別子。
#   各メンテナの環境に依存するため、ここではデフォルトを置かない。
#   使い方:
#     make dist SIGN_IDENTITY="Developer ID Application: NAME (TEAMID)" \
#               NOTARY_PROFILE=my-notary-profile
#   もしくは shell の環境変数 / direnv 等で渡す。
# - NOTARY_PROFILE: xcrun notarytool store-credentials で Keychain に保存した
#   プロファイル名。
# - ENTITLEMENTS: メインアプリ署名時に焼き付ける entitlements。
SIGN_IDENTITY  ?=
NOTARY_PROFILE ?=
ENTITLEMENTS   := macos/Runner/Release.entitlements

.DEFAULT_GOAL := help

.PHONY: help setup get gen watch run format analyze test check build build-windows sign dmg notarize staple dist clean reset reset-windows

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

build: ## macOS Release ビルド（$(APP_BUNDLE) に出力）
	$(FLUTTER) build macos --release $(DEFINES)

build-windows: ## Windows Release ビルド（$(WIN_EXE_DIR)/roola.exe に出力）※ Developer Mode 必須
	$(FLUTTER) build windows --release $(DEFINES)

sign: build ## Developer ID で .app を Hardened Runtime 付きで再帰署名
	@if [ -z "$(SIGN_IDENTITY)" ]; then \
		echo "Error: SIGN_IDENTITY が未設定です。"; \
		echo "  例: make sign SIGN_IDENTITY=\"Developer ID Application: NAME (TEAMID)\""; \
		echo "  または環境変数で渡してください。"; \
		exit 1; \
	fi
	@echo "Signing inner contents under $(APP_BUNDLE) ..."
	@find "$(APP_BUNDLE)/Contents/Frameworks" -type f \( -name "*.dylib" -o -name "*.so" \) \
		-exec codesign --force --options runtime --timestamp \
			--sign "$(SIGN_IDENTITY)" {} \;
	@# Sparkle.framework の内側にネストされている XPC Service / Autoupdate /
	@# Updater.app は CocoaPods 配布時点で Sparkle プロジェクト側の証明書で
	@# 署名されている。公証 (notarize) は「全実体が同じ Developer ID + Hardened
	@# Runtime + secure timestamp で再署名されている」ことを要求するため、
	@# framework 全体署名の前に内側から順に上書き署名する。順序は奥 → 外。
	@SPARKLE_FW="$(APP_BUNDLE)/Contents/Frameworks/Sparkle.framework"; \
	if [ -d "$$SPARKLE_FW" ]; then \
		echo "Re-signing Sparkle nested binaries ..."; \
		for path in \
			"$$SPARKLE_FW/Versions/Current/XPCServices/Installer.xpc" \
			"$$SPARKLE_FW/Versions/Current/XPCServices/Downloader.xpc" \
			"$$SPARKLE_FW/Versions/Current/Updater.app" \
			"$$SPARKLE_FW/Versions/Current/Autoupdate" ; do \
			if [ -e "$$path" ]; then \
				codesign --force --options runtime --timestamp \
					--sign "$(SIGN_IDENTITY)" "$$path"; \
			fi; \
		done; \
	fi
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
	@if [ -z "$(NOTARY_PROFILE)" ]; then \
		echo "Error: NOTARY_PROFILE が未設定です。"; \
		echo "  事前に xcrun notarytool store-credentials で Keychain に保存し、"; \
		echo "  そのプロファイル名を渡してください。"; \
		echo "  例: make notarize NOTARY_PROFILE=my-notary-profile"; \
		exit 1; \
	fi
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

reset: ## macOS: 永続化エントリ・設定を削除（prod / dev 両方）
	rm -rf "$$HOME/Library/Application Support/tech.yahiro.Roola"
	rm -rf "$$HOME/Library/Application Support/dev.tech.yahiro.Roola"

reset-windows: ## Windows: 永続化エントリ・設定を削除
	rm -rf "$$APPDATA/tech.yahiro.Roola"
