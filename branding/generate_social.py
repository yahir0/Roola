#!/usr/bin/env python3
"""Roola のインスタ宣伝画像を生成する。

Polaris デザインシステム（ADR-0038）の世界観で構成する:
- グラファイト 2 トーンの地（well / bg）
- 暖色ゴールド 1 色のアクセント（#D0A341）
- 角丸 R は 4px グリッド準拠（大判では比例拡大）
- 翼＋フォルダのシンボル（branding/roola_icon_master.png, ADR-0053）を主役に置く

使い方: python3 branding/generate_social.py
出力: branding/social/*.png
"""

import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ICON = os.path.join(ROOT, "branding", "roola_icon_master.png")
OUT = os.path.join(ROOT, "branding", "social")
os.makedirs(OUT, exist_ok=True)

# --- Polaris tokens (lib/app/theme.dart より) ---
WELL = (10, 11, 13)
BG = (18, 19, 23)
MACHINE = (16, 17, 21)
GOLD = (208, 163, 65)
TEXT = (236, 239, 242)
TEXT_DIM = (146, 154, 163)
TEXT_FAINT = (104, 111, 120)
TOP_EDGE = (44, 48, 55)
LINE = (42, 45, 51)

# 本文用は日本語ヒラギノ W3。GB（簡体字）版だと漢字が中国語字形になるため使わない。
FONT_JA = "/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc"
FONT_JA_BOLD = "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc"
FONT_LATIN = "/System/Library/Fonts/SFNS.ttf"


def latin(size, weight=None):
    f = ImageFont.truetype(FONT_LATIN, size)
    if weight is not None:
        try:
            f.set_variation_by_axes([weight])
        except Exception:
            pass
    return f


def ja(size, bold=False):
    return ImageFont.truetype(FONT_JA_BOLD if bold else FONT_JA, size)


def vgrad(w, h, top, bottom):
    """縦方向グラデーション。小さく作って引き伸ばし滑らかにする。"""
    g = Image.new("RGB", (1, h))
    px = g.load()
    for y in range(h):
        t = y / (h - 1)
        px[0, y] = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
    return g.resize((w, h))


def radial_glow(size, color, intensity=1.0):
    """中心が明るい放射グロー(L マスク)を作り color で着色した RGBA を返す。"""
    s = 360
    m = Image.new("L", (s, s), 0)
    px = m.load()
    c = s / 2
    for y in range(s):
        for x in range(s):
            d = (((x - c) ** 2 + (y - c) ** 2) ** 0.5) / c
            v = max(0.0, 1.0 - d)
            px[x, y] = int((v ** 2.2) * 255 * intensity)
    m = m.resize(size).filter(ImageFilter.GaussianBlur(size[0] // 24))
    layer = Image.new("RGBA", size, color + (0,))
    layer.putalpha(m)
    return layer


def drop_shadow(img, blur, alpha, color=(0, 0, 0)):
    """画像のアルファ形状から柔らかい影レイヤーを作る。"""
    a = img.split()[-1]
    sh = Image.new("RGBA", img.size, color + (0,))
    sh.putalpha(a.point(lambda v: int(v / 255 * alpha)))
    return sh.filter(ImageFilter.GaussianBlur(blur))


def kern_text(draw, pos, text, font, fill, tracking):
    """文字間隔(トラッキング)を効かせて 1 文字ずつ描く。戻り値は総幅。"""
    x, y = pos
    for ch in text:
        draw.text((x, y), ch, font=font, fill=fill)
        w = draw.textlength(ch, font=font)
        x += w + tracking
    return x - tracking - pos[0]


def kern_width(draw, text, font, tracking):
    total = 0
    for ch in text:
        total += draw.textlength(ch, font=font) + tracking
    return total - tracking


def centered_kern(draw, cx, y, text, font, fill, tracking):
    w = kern_width(draw, text, font, tracking)
    kern_text(draw, (cx - w / 2, y), text, font, fill, tracking)


# ワードマーク "Roola" の体裁（間延びを締めるため太め + 負トラッキング）。
# 字間はサイズ比例（C 案: 92pt で -5 → 1pt あたり -0.0543）。
WM_WEIGHT = 720
WM_TRACK_RATIO = -5 / 92


def draw_wordmark(draw, cx, y, size, fill):
    centered_kern(draw, cx, y, "Roola", latin(size, weight=WM_WEIGHT), fill, size * WM_TRACK_RATIO)


# 常設スローガン。ワードマーク直下にゴールドで置く。LP ヒーローに合わせ全大文字
# ＋字間 0.18em。末尾は "." を置かず、ターミナルのプロンプト想起の下線カーソル（_）
# にする（generate_social_carousel.py / generate_stickers.py と統一）。
SLOGAN_TRACK_RATIO = 0.18
SLOGAN_WORD = "FOR DEVELOPERS"


def draw_slogan(draw, cx, y, size=38):
    font = latin(size, weight=560)
    track = size * SLOGAN_TRACK_RATIO
    word_w = kern_width(draw, SLOGAN_WORD, font, track)
    _, t, _, b = draw.textbbox((0, 0), "H", font=font)
    cap_h = b - t
    gap = cap_h * 0.30          # 文字とカーソルの間隔
    cur_w = cap_h * 0.72        # 下線カーソルの幅
    sw = max(2, round(cap_h * 0.16))  # 下線の太さ
    x = cx - (word_w + gap + cur_w) / 2
    kern_text(draw, (x, y), SLOGAN_WORD, font, GOLD, track)
    cx0 = x + word_w + gap
    draw.rectangle(
        [int(cx0), int(y + b) - sw, int(cx0 + cur_w) - 1, int(y + b) - 1], fill=GOLD
    )


def load_icon(box):
    ic = Image.open(ICON).convert("RGBA")
    ic = ic.resize((box, box), Image.LANCZOS)
    return ic


# ---------------------------------------------------------------------------
# 1) 正方形ヒーロー 1080x1080
# ---------------------------------------------------------------------------
def build_square():
    W = H = 1080
    base = vgrad(W, H, BG, WELL).convert("RGBA")
    d = ImageDraw.Draw(base)

    # 上端 1px ハイライト（筐体の縁）
    d.line([(0, 0), (W, 0)], fill=TOP_EDGE, width=2)

    # アイコン背後のゴールドグロー
    glow_box = 760
    glow = radial_glow((glow_box, glow_box), GOLD, intensity=0.30)
    cx = W // 2
    icon_cy = 410
    base.alpha_composite(glow, (cx - glow_box // 2, icon_cy - glow_box // 2))

    # アイコン本体（影付き）
    ibox = 380
    icon = load_icon(ibox)
    ix, iy = cx - ibox // 2, icon_cy - ibox // 2
    shadow = drop_shadow(icon, blur=34, alpha=150)
    base.alpha_composite(shadow, (ix, iy + 22))
    base.alpha_composite(icon, (ix, iy))

    d = ImageDraw.Draw(base)

    # ワードマーク Roola + スローガン
    draw_wordmark(d, cx, 646, 132, TEXT)
    draw_slogan(d, cx, 782, 40)

    # ゴールドのアンダーライン（4px グリッド準拠）
    ul_w = 96
    d.rounded_rectangle(
        [cx - ul_w // 2, 862, cx + ul_w // 2, 866], radius=2, fill=GOLD
    )

    # コンセプトタグライン（日本語）
    centered_kern(d, cx, 902, "目的地へ、一瞬で。", ja(46, bold=True), TEXT, 3)

    # サブ説明
    centered_kern(d, cx, 974, "ファイル・ターミナル・Claude Code を、ワンクリックで。", ja(27), TEXT_DIM, 1)

    base.convert("RGB").save(os.path.join(OUT, "roola_ig_square.png"))
    print("wrote roola_ig_square.png")


# ---------------------------------------------------------------------------
# 2) ポートレート 1080x1350（機能訴求）
# ---------------------------------------------------------------------------
def build_portrait():
    W, H = 1080, 1350
    base = vgrad(W, H, BG, WELL).convert("RGBA")
    d = ImageDraw.Draw(base)
    d.line([(0, 0), (W, 0)], fill=TOP_EDGE, width=2)
    cx = W // 2

    # グロー + アイコン
    glow_box = 720
    glow = radial_glow((glow_box, glow_box), GOLD, intensity=0.28)
    icon_cy = 358
    base.alpha_composite(glow, (cx - glow_box // 2, icon_cy - glow_box // 2))
    ibox = 340
    icon = load_icon(ibox)
    ix, iy = cx - ibox // 2, icon_cy - ibox // 2
    base.alpha_composite(drop_shadow(icon, 30, 150), (ix, iy + 20))
    base.alpha_composite(icon, (ix, iy))

    d = ImageDraw.Draw(base)

    # ワードマーク + スローガン
    draw_wordmark(d, cx, 552, 118, TEXT)
    draw_slogan(d, cx, 680, 36)

    ul_w = 88
    d.rounded_rectangle([cx - ul_w // 2, 752, cx + ul_w // 2, 756], radius=2, fill=GOLD)

    centered_kern(d, cx, 792, "目的地へ、一瞬で。", ja(42, bold=True), TEXT, 3)

    # 機能 3 点（左揃え・ゴールドのドット）
    feats = [
        ("フォルダをブラウズ", "エクスプローラ中心のファイル操作"),
        ("ワンクリックで起動", "「ディレクトリ + 動作」を登録"),
        ("ターミナル & Claude Code", "シェル・コマンド・Skill をその場で実行"),
    ]
    fy = 912
    left = 188
    tfont = ja(34, bold=True)
    sfont = ja(26)
    for title, desc in feats:
        # ゴールドのドット
        d.ellipse([left, fy + 12, left + 14, fy + 26], fill=GOLD)
        d.text((left + 40, fy), title, font=tfont, fill=TEXT)
        d.text((left + 40, fy + 46), desc, font=sfont, fill=TEXT_DIM)
        fy += 118

    # フッタのサブ説明
    centered_kern(d, cx, 1274, "ファイル・ターミナル・Claude Code を、ワンクリックで。", ja(25), TEXT_FAINT, 1)

    base.convert("RGB").save(os.path.join(OUT, "roola_ig_portrait.png"))
    print("wrote roola_ig_portrait.png")


if __name__ == "__main__":
    build_square()
    build_portrait()
