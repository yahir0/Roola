#!/usr/bin/env python3
"""Roola の macOS アプリアイコンを生成する。

ブランドシンボルのマスター画像 `roola_icon_master.png`（1024×1024・角丸スクエア
本体＋外側透明）を各サイズへ縮小し、`AppIcon.appiconset` 用の 7 サイズ PNG を
出力する。

シンボル: ゴールドのフォルダ（エクスプローラ＝アプリの核機能）を、大きく
広がる白い翼が抱く。翼＝「遠くへ飛べる安心感」、フォルダ＝目的地。
デザイン根拠: ADR-0053 / branding/README.md。

マスターの作り直し（元アート差し替え時）:
    新しい元アート（角丸スクエアが黒/透明地に乗った正方形 PNG）を用意し、
    `_build_master()` の SRC を指してこのスクリプトを実行する。通常の
    再生成（サイズ振り直しのみ）は既存マスターをそのまま縮小する。

使い方:
    python3 branding/generate_app_icon.py            # Roola
    python3 branding/generate_app_icon.py monitor    # Roola Monitor（ADR-0069）
"""

import sys
from pathlib import Path

from PIL import Image, ImageDraw

_ROOT = Path(__file__).resolve().parent.parent
# アプリ名 → (マスター画像, 出力先の AppIcon.appiconset)
_TARGETS = {
    "roola": (
        _ROOT / "branding/roola_icon_master.png",
        _ROOT / "macos/Runner/Assets.xcassets/AppIcon.appiconset",
    ),
    "monitor": (
        _ROOT / "branding/roola_meter_icon_master.png",
        _ROOT / "apps/roola_monitor/macos/Runner/Assets.xcassets/AppIcon.appiconset",
    ),
}
_SIZES = [16, 32, 64, 128, 256, 512, 1024]

# macOS アイコングリッド（1024 基準）。本体 824（余白 100）/ 角丸 184。
_MARGIN, _INNER, _CORNER = 100, 824, 184


def _build_master(src_path: Path) -> Image.Image:
    """元アート（黒/透明地の角丸スクエア）を macOS グリッドへ整えてマスター化する。

    元アートの角丸スクエア本体を検出して正方形に整え、824 グリッドへ縮小、
    角丸 R=184 の透明マスクを当てて 1024 キャンバス中央に置く。
    """
    src = Image.open(src_path).convert("RGB")
    bbox = src.convert("L").point(lambda v: 255 if v > 12 else 0).getbbox()
    crop = src.crop(bbox)
    side = max(crop.size)
    square = Image.new("RGB", (side, side), (0, 0, 0))
    square.paste(crop, ((side - crop.size[0]) // 2, (side - crop.size[1]) // 2))

    ss = 4
    base, margin, inner, corner = 1024 * ss, _MARGIN * ss, _INNER * ss, _CORNER * ss
    body = square.resize((inner, inner), Image.LANCZOS).convert("RGBA")
    mask = Image.new("L", (inner, inner), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, inner - 1, inner - 1], radius=corner, fill=255)
    body.putalpha(mask)
    master = Image.new("RGBA", (base, base), (0, 0, 0, 0))
    master.alpha_composite(body, (margin, margin))
    return master.resize((1024, 1024), Image.LANCZOS)


def main() -> None:
    target = sys.argv[1] if len(sys.argv) > 1 else "roola"
    if target not in _TARGETS:
        raise SystemExit(f"unknown target: {target}（{' / '.join(_TARGETS)}）")
    master_path, out_dir = _TARGETS[target]
    if not master_path.exists():
        raise SystemExit(
            f"master not found: {master_path}\n"
            "元アートからマスターを作る場合は _build_master(src) を使う。"
        )
    master = Image.open(master_path).convert("RGBA")
    for size in _SIZES:
        master.resize((size, size), Image.LANCZOS).save(out_dir / f"app_icon_{size}.png")
        print(f"wrote app_icon_{size}.png")


if __name__ == "__main__":
    main()
