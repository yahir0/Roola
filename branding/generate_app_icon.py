#!/usr/bin/env python3
"""Roola の macOS アプリアイコンを生成する。

`roola_icon.svg` と同じ幾何学を Pillow で直接描画し、`AppIcon.appiconset`
用の 7 サイズ PNG を出力する。SVG レンダラ（rsvg/inkscape 等）に依存しない
ための実装。

シンボル構成:
  - 中央円環（連続した細いモノライン）
  - 外周円環（N/E/S/W に隙間を空けた 4 つの円弧）
  - 東西南北の細長い三角形矢印（基部は外周円環の内側、先端は外側へ。
    円弧の隙間を通り、円弧とは触れない）

デザイン根拠: ADR-0038（Polaris デザインシステム）/ branding/README.md。

使い方:
    python3 branding/generate_app_icon.py
"""

from pathlib import Path

from PIL import Image, ImageDraw

# --- 出力先 -----------------------------------------------------------------
_OUT_DIR = (
    Path(__file__).resolve().parent.parent
    / "macos/Runner/Assets.xcassets/AppIcon.appiconset"
)
_SIZES = [16, 32, 64, 128, 256, 512, 1024]

# --- デザイントークン（すべて 1024px キャンバス基準） -----------------------
_GRAPHITE = (0x12, 0x13, 0x17, 255)  # 背景グラファイト
_WHITE = (0xEC, 0xEF, 0xF2, 255)  # シンボル（オフホワイト）
_MARGIN = 100  # 角丸スクエアの余白（macOS アイコングリッド 824/1024）
_CORNER = 184  # 角丸半径
_OUTER_R, _OUTER_W = 200, 20  # 外周円環: 中心線半径 / 線幅（細いモノライン）
_INNER_R, _INNER_W = 108, 20  # 中央円環: 中心線半径 / 線幅
# 外周円環を成す 4 つの円弧 (開始角, 終了角)。角度は 3 時方向から時計回り。
# N/E/S/W の各方向に隙間を空け、そこに矢印を通す。
_OUTER_ARCS = [(19, 71), (109, 161), (199, 251), (289, 341)]
# 東西南北の矢印（中心 512,512 基準）。基部は外周円環の内側、先端は外側で
# 円弧の隙間を通る。各矢印は 4 点ポリゴン: 先端 / 基部の左右の角 / 基部中央
# （先端側へ凹ませて矢印らしさを出す）。
_ARROWS = [
    [(512, 190), (568, 352), (512, 320), (456, 352)],  # 北
    [(834, 512), (672, 456), (704, 512), (672, 568)],  # 東
    [(512, 834), (568, 672), (512, 704), (456, 672)],  # 南
    [(190, 512), (352, 456), (320, 512), (352, 568)],  # 西
]

_SS = 4  # スーパーサンプリング倍率（縮小時の AA 用）
_BASE = 1024 * _SS
_C = _BASE // 2  # 中心


def _circle(draw: ImageDraw.ImageDraw, radius: int, fill: int) -> None:
    r = radius * _SS
    draw.ellipse([_C - r, _C - r, _C + r, _C + r], fill=fill)


def _pieslice(
    draw: ImageDraw.ImageDraw, radius: int, start: int, end: int, fill: int
) -> None:
    r = radius * _SS
    draw.pieslice([_C - r, _C - r, _C + r, _C + r], start, end, fill=fill)


def _render_master() -> Image.Image:
    """1024×_SS の原寸マスター画像を描く。"""
    # 背景: 角丸スクエア（外周は透明）。
    canvas = Image.new("RGBA", (_BASE, _BASE), (0, 0, 0, 0))
    ImageDraw.Draw(canvas).rounded_rectangle(
        [_MARGIN * _SS, _MARGIN * _SS, _BASE - _MARGIN * _SS, _BASE - _MARGIN * _SS],
        radius=_CORNER * _SS,
        fill=_GRAPHITE,
    )

    # シンボルを白く塗る領域のマスク。
    mask = Image.new("L", (_BASE, _BASE), 0)
    md = ImageDraw.Draw(mask)
    # 外周円環: 4 つの円弧（環状セクター）。中央円環より先に描く。
    for start, end in _OUTER_ARCS:
        _pieslice(md, _OUTER_R + _OUTER_W // 2, start, end, 255)
        _pieslice(md, _OUTER_R - _OUTER_W // 2, start, end, 0)
    # 中央円環: 連続。円弧の中抜き（fill 0）の後に描いて欠けないようにする。
    _circle(md, _INNER_R + _INNER_W // 2, 255)
    _circle(md, _INNER_R - _INNER_W // 2, 0)
    # 東西南北の矢印。
    for arrow in _ARROWS:
        md.polygon([(x * _SS, y * _SS) for x, y in arrow], fill=255)

    white_layer = Image.new("RGBA", (_BASE, _BASE), _WHITE)
    return Image.composite(white_layer, canvas, mask)


def main() -> None:
    master = _render_master()
    for size in _SIZES:
        img = master.resize((size, size), Image.LANCZOS)
        img.save(_OUT_DIR / f"app_icon_{size}.png")
        print(f"wrote app_icon_{size}.png")


if __name__ == "__main__":
    main()
