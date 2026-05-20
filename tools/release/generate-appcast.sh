#!/usr/bin/env bash
# 既存の DMG から Sparkle appcast.xml を生成するスクリプト。
#
# - 入力: 単一の DMG ファイル
# - 出力: 1 エントリだけの appcast.xml（"最新だけ載せる" 方式）
# - 署名: EdDSA 秘密鍵で各エントリに signature を付与
#
# 秘密鍵の取得方法は 2 通り:
# 1. 環境変数 SPARKLE_PRIVATE_KEY_BASE64 が設定されていればそれを使う
#    （CI 環境を想定。GitHub Actions Secret に置く）
# 2. 環境変数が無ければ generate_appcast が macOS Keychain の
#    "https://sparkle-project.org" エントリを自動使用する（ローカル想定）
#
# Sparkle 公式ツール (generate_appcast) は Sparkle の Release tarball に
# 同梱されている。初回実行時に SPARKLE_DIR にダウンロード・キャッシュする。
#
# 詳細な背景は docs/sparkle.md を参照。
#
# Usage:
#   ./tools/release/generate-appcast.sh <dmg-path> <download-url-prefix> [output-dir]
#
# Example (local テスト):
#   ./tools/release/generate-appcast.sh build/Roola.dmg \
#     https://github.com/yahir0/Roola/releases/download/v0.0.8/ \
#     /tmp/appcast-output
#
# Example (CI で実行):
#   export SPARKLE_PRIVATE_KEY_BASE64="<base64-encoded-private-key>"
#   ./tools/release/generate-appcast.sh build/Roola.dmg \
#     "https://github.com/yahir0/Roola/releases/download/v0.0.8/" \
#     /tmp/appcast-output

set -euo pipefail

DMG_PATH="${1:?usage: $0 <dmg-path> <download-url-prefix> [output-dir]}"
URL_PREFIX="${2:?usage: $0 <dmg-path> <download-url-prefix> [output-dir]}"
OUTPUT_DIR="${3:-./appcast-output}"
SPARKLE_VERSION="${SPARKLE_VERSION:-2.6.4}"
SPARKLE_DIR="${SPARKLE_DIR:-/tmp/sparkle-${SPARKLE_VERSION}}"

if [ ! -f "$DMG_PATH" ]; then
  echo "Error: DMG not found at $DMG_PATH" >&2
  exit 1
fi

# Sparkle ツール群を必要に応じてダウンロード（初回のみ）
if [ ! -x "$SPARKLE_DIR/bin/generate_appcast" ]; then
  echo "Downloading Sparkle ${SPARKLE_VERSION}..." >&2
  TAR_PATH="/tmp/sparkle-${SPARKLE_VERSION}.tar.xz"
  curl -L -f -o "$TAR_PATH" \
    "https://github.com/sparkle-project/Sparkle/releases/download/${SPARKLE_VERSION}/Sparkle-${SPARKLE_VERSION}.tar.xz"
  mkdir -p "$SPARKLE_DIR"
  tar -xJf "$TAR_PATH" -C "$SPARKLE_DIR"
  rm "$TAR_PATH"
fi

# generate_appcast に渡す入力ディレクトリを用意（DMG を 1 個だけ置く）
INPUT_DIR="$(mktemp -d -t roola-appcast-XXXXXX)"
CLEANUP_PATHS=("$INPUT_DIR")
cleanup() {
  for path in "${CLEANUP_PATHS[@]}"; do
    [ -e "$path" ] && rm -rf "$path"
  done
}
trap cleanup EXIT

cp "$DMG_PATH" "$INPUT_DIR/"

# EdDSA 秘密鍵の取り扱い。
#
# Sparkle の sign_update / generate_appcast が --ed-key-file に期待するのは
# 「base64 でエンコードされた秘密鍵を 1 行のテキストとして書いたファイル」。
# Keychain に保存されているのは raw 64 バイトの key データで、ユーザーは
# `security ... -w | base64` でこれを base64 エンコードしてから Secret に
# 貼っている。つまり SPARKLE_PRIVATE_KEY_BASE64 の中身は「raw bytes を base64
# したもの」= Sparkle が期待するファイル形式そのもの。
#
# 以前ここで base64 --decode していたが、それをやると raw bytes をファイルに
# 書いてしまい sign_update が String として読めず "Private key not found in
# the argument" で落ちる。デコードせず env をそのままファイルに流し込むのが
# 正解（前後の空白・改行だけは念のため取り除く）。
KEY_ARGS=()
if [ -n "${SPARKLE_PRIVATE_KEY_BASE64:-}" ]; then
  KEY_FILE="$(mktemp -t sparkle-key-XXXXXX)"
  CLEANUP_PATHS+=("$KEY_FILE")
  printf '%s' "$SPARKLE_PRIVATE_KEY_BASE64" \
    | tr -d '[:space:]' \
    > "$KEY_FILE"
  chmod 600 "$KEY_FILE"
  KEY_ARGS=(--ed-key-file "$KEY_FILE")
  echo "Using EdDSA key from SPARKLE_PRIVATE_KEY_BASE64 env var" >&2
else
  echo "Using EdDSA key from macOS Keychain (generate_appcast auto-discovers)" >&2
fi

# appcast.xml を生成
"$SPARKLE_DIR/bin/generate_appcast" \
  "${KEY_ARGS[@]}" \
  --download-url-prefix "$URL_PREFIX" \
  "$INPUT_DIR"

mkdir -p "$OUTPUT_DIR"
mv "$INPUT_DIR/appcast.xml" "$OUTPUT_DIR/appcast.xml"

echo
echo "Generated: $OUTPUT_DIR/appcast.xml"
echo "----- Preview (head -30) -----"
head -30 "$OUTPUT_DIR/appcast.xml"
