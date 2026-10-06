#!/usr/bin/env python3
"""アクティビティモニタ単体アプリのアイコン・マスターを生成する。

Roola のブランドシンボル `roola_icon_master.png` から翼をそのまま流用し、
フォルダ部分をセグメント式タコメーター（点灯／消灯セグメント＋白い針）に
差し替える。翼がメーターを懐に抱く構図は Roola と共通で、兄弟アプリで
あることを示す。メーターはアクティビティタブの TACHO（DIGITAL）表示に対応。

翼は画像生成由来の有機的な形状なので描き直さない（コード手描きでは品質が
出ないため）。メーターは幾何形状なのでここで手続き的に描く。

出力: `branding/roola_meter_icon_master.png`（1024×1024・外側透明）

使い方（Pillow / NumPy が必要）:
    python3 branding/generate_meter_icon_master.py
"""

import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

_ROOT = Path(__file__).resolve().parent.parent
_SRC = _ROOT / "branding/roola_icon_master.png"
_OUT = _ROOT / "branding/roola_meter_icon_master.png"

# 描画は 4 倍で行い縮小してアンチエイリアスをかける。
_SS = 4
_GOLD = (240, 168, 16)
_GOLD_DIM = (92, 72, 30)
_WHITE = (244, 244, 242)

# メーター形状（1024 基準）。弧の右側は翼の裏に隠れる。
_CX, _CY, _R = 418, 500, 212
_SEG_WIDTH = 55
_START_DEG = 172  # 翼の先端を避けるため左端を少し上げる
_END_DEG = 400
_SEGMENTS = 12
_LIT = 7  # 消灯セグメントが翼の手前に 2〜3 個見える点灯数
_GAP_DEG = 5


def _masks(base):
    sat = base[..., :3].max(axis=2) - base[..., :3].min(axis=2)
    wing = (base[..., :3].min(axis=2) > 110) & (sat < 40)
    h, w = base.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]
    # フォルダと翼の内側の影を含む「懐」の領域
    pocket = (
        ((xx - 390) ** 2 / 250**2 + (yy - 530) ** 2 / 240**2 <= 1)
        & (xx >= 140) & (xx <= 640) & (yy >= 300) & (yy <= 760)
    )
    return wing, pocket


def _dilate(mask, size):
    img = Image.fromarray((mask * 255).astype(np.uint8))
    return np.array(img.filter(ImageFilter.MaxFilter(size))) > 0


def _inpaint_background(base, fill, wing, pocket):
    """懐の領域を周囲の背景色から推定して埋める（正規化畳み込み）。"""
    known = ~(fill | _dilate(wing, 41) | _dilate(pocket, 21)) & (base[..., 3] == 255)
    k_img = Image.fromarray((known * 255).astype(np.uint8))
    num = (base[..., :3] * known[..., None]).astype(np.uint8)
    h, w = base.shape[:2]
    out = np.zeros((h, w, 3))
    done = np.zeros((h, w), bool)
    for sigma, blur, threshold in (
        (30, ImageFilter.GaussianBlur(30), 0.2),
        (80, ImageFilter.GaussianBlur(80), 0.2),
        (300, ImageFilter.BoxBlur(300), 0.0),
    ):
        den = np.array(k_img.filter(blur)).astype(np.float64) / 255
        nv = np.stack(
            [np.array(Image.fromarray(num[..., c]).filter(blur)).astype(np.float64) for c in range(3)],
            -1,
        )
        ok = (den > threshold) & ~done
        out[ok] = (nv / np.maximum(den, 1e-3)[..., None])[ok]
        done |= ok
    return out.astype(np.int32)


def _to_img(arr):
    return Image.fromarray(arr.clip(0, 255).astype(np.uint8), "RGBA")


def _scaled_box(cx, cy, r):
    return [(cx - r) * _SS, (cy - r) * _SS, (cx + r) * _SS, (cy + r) * _SS]


def _draw_meter(size, hub_hole_color):
    layer = Image.new("RGBA", (size * _SS, size * _SS), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    sweep = _END_DEG - _START_DEG
    step = sweep / _SEGMENTS
    for i in range(_SEGMENTS):
        s = _START_DEG + i * step
        d.arc(
            _scaled_box(_CX, _CY, _R), s, s + step - _GAP_DEG,
            fill=_GOLD if i < _LIT else _GOLD_DIM, width=int(_SEG_WIDTH * _SS),
        )

    # 針は点灯セグメントの境目を指す
    deg = _START_DEG + step * _LIT - _GAP_DEG / 2
    a, n = math.radians(deg), math.radians(deg + 90)
    length, tail, half = _R - _SEG_WIDTH * 0.9, 26, 15.6
    tip = (_CX + length * math.cos(a), _CY + length * math.sin(a))
    back = (_CX - tail * math.cos(a), _CY - tail * math.sin(a))
    poly = [
        (back[0] + half * math.cos(n), back[1] + half * math.sin(n)),
        tip,
        (back[0] - half * math.cos(n), back[1] - half * math.sin(n)),
    ]
    d.polygon([(x * _SS, y * _SS) for x, y in poly], fill=_WHITE)
    d.ellipse(_scaled_box(_CX, _CY, 31), fill=_WHITE)
    d.ellipse(_scaled_box(_CX, _CY, 11), fill=hub_hole_color)
    return layer.resize((size, size), Image.LANCZOS)


def main():
    base = np.array(Image.open(_SRC).convert("RGBA")).astype(np.int32)
    h, w = base.shape[:2]
    wing, pocket = _masks(base)
    fill = pocket & ~wing

    smooth = _inpaint_background(base, fill, wing, pocket)
    erased = base.copy()
    erased[fill, :3] = smooth[fill]
    bg_full = base[..., :3].copy()
    bg_full[fill | wing] = smooth[fill | wing]

    hub_hole = tuple(int(c) for c in smooth[_CY, _CX])
    img = Image.alpha_composite(_to_img(erased), _draw_meter(w, hub_hole))

    # 翼を前面に戻す。翼の周囲に背景色の隙間を作り、メーターを懐に抱く形にする。
    wing_img = Image.fromarray((wing * 255).astype(np.uint8))
    gap = wing_img.filter(ImageFilter.MaxFilter(19)).filter(ImageFilter.GaussianBlur(1))
    gap = Image.fromarray(np.minimum(np.array(gap), (pocket * 255).astype(np.uint8)))
    img = Image.composite(Image.fromarray(bg_full.clip(0, 255).astype(np.uint8)).convert("RGBA"), img, gap)
    img = Image.composite(_to_img(base), img, wing_img.filter(ImageFilter.GaussianBlur(0.6)))

    img.save(_OUT)
    print(f"wrote {_OUT.relative_to(_ROOT)}")


if __name__ == "__main__":
    main()
