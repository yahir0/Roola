#!/usr/bin/env python3
"""Roola のインスタ用カルーセル投稿（5 枚）を生成する。

Polaris デザインシステム（ADR-0038）の世界観で、機能スクショを交えて構成する:
- 表紙: 翼＋フォルダのシンボル + ワードマーク
- 機能 3 枚: docs/images の実スクショ（ワークスペース / ランチャー / Git）を主役に
- まとめ: 機能リスト + CTA

各スライドは 1080x1350（インスタ縦長）。下部にページドット。
使い方: python3 branding/generate_social_carousel.py
出力: branding/social/carousel/*.png
"""

import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ICON = os.path.join(ROOT, "branding", "roola_icon_master.png")
IMG = os.path.join(ROOT, "docs", "images")
OUT = os.path.join(ROOT, "branding", "social", "carousel")
os.makedirs(OUT, exist_ok=True)

# --- Polaris tokens (lib/app/theme.dart より) ---
WELL = (10, 11, 13)
BG = (18, 19, 23)
GOLD = (208, 163, 65)
TEXT = (236, 239, 242)
TEXT_DIM = (146, 154, 163)
TEXT_FAINT = (104, 111, 120)
TOP_EDGE = (44, 48, 55)
LINE = (42, 45, 51)
SURFACE = (27, 29, 34)

# 本文用は日本語ヒラギノ W3。GB（簡体字）版だと漢字が中国語字形になるため使わない。
FONT_JA = "/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc"
FONT_JA_BOLD = "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc"
FONT_LATIN = "/System/Library/Fonts/SFNS.ttf"

W, H = 1080, 1350
MARGIN = 96
TOTAL = 5


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
    g = Image.new("RGB", (1, h))
    px = g.load()
    for y in range(h):
        t = y / (h - 1)
        px[0, y] = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
    return g.resize((w, h))


def radial_glow(size, color, intensity=1.0):
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
    a = img.split()[-1]
    sh = Image.new("RGBA", img.size, color + (0,))
    sh.putalpha(a.point(lambda v: int(v / 255 * alpha)))
    return sh.filter(ImageFilter.GaussianBlur(blur))


def kern_width(draw, text, font, tracking):
    total = 0
    for ch in text:
        total += draw.textlength(ch, font=font) + tracking
    return total - tracking


def kern_text(draw, pos, text, font, fill, tracking):
    x, y = pos
    for ch in text:
        draw.text((x, y), ch, font=font, fill=fill)
        x += draw.textlength(ch, font=font) + tracking


def centered_kern(draw, cx, y, text, font, fill, tracking):
    w = kern_width(draw, text, font, tracking)
    kern_text(draw, (cx - w / 2, y), text, font, fill, tracking)


# ワードマーク "Roola" の体裁（間延びを締めるため太め + 負トラッキング）。
# 字間はサイズ比例（C 案: 92pt で -5 → 1pt あたり -0.0543）。
WM_WEIGHT = 720
WM_TRACK_RATIO = -5 / 92


def draw_wordmark(draw, cx, y, size, fill):
    centered_kern(draw, cx, y, "Roola", latin(size, weight=WM_WEIGHT), fill, size * WM_TRACK_RATIO)


# 常設スローガン。ワードマーク直下にゴールドで置く。
def draw_slogan(draw, cx, y, size=40):
    centered_kern(draw, cx, y, "For Developers.", latin(size, weight=560), GOLD, 2)


def base_canvas():
    img = vgrad(W, H, BG, WELL).convert("RGBA")
    ImageDraw.Draw(img).line([(0, 0), (W, 0)], fill=TOP_EDGE, width=2)
    return img


def page_dots(img, active):
    d = ImageDraw.Draw(img)
    gap = 26
    r = 5
    cx = W // 2
    start = cx - (TOTAL - 1) * gap / 2
    y = 1286
    for i in range(TOTAL):
        x = start + i * gap
        if i == active:
            d.rounded_rectangle([x - 11, y - r, x + 11, y + r], radius=r, fill=GOLD)
        else:
            d.ellipse([x - r, y - r, x + r, y + r], fill=(70, 74, 82))


def footer_mark(img, y=1190):
    d = ImageDraw.Draw(img)
    ic = Image.open(ICON).convert("RGBA").resize((46, 46), Image.LANCZOS)
    wm = latin(40, weight=WM_WEIGHT)
    track = 40 * WM_TRACK_RATIO
    tw = kern_width(d, "Roola", wm, track)
    total = 46 + 14 + tw
    x = (W - total) / 2
    img.alpha_composite(ic, (int(x), int(y)))
    kern_text(d, (x + 46 + 14, y + 1), "Roola", wm, TEXT, track)


def frame_shot(path, target_w, radius=18, crop=None):
    im = Image.open(path).convert("RGBA")
    if crop:
        im = im.crop(crop)
    ratio = im.height / im.width
    th = int(target_w * ratio)
    im = im.resize((target_w, th), Image.LANCZOS)
    mask = Image.new("L", (target_w, th), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, target_w - 1, th - 1], radius=radius, fill=255)
    im.putalpha(mask)
    return im


def place_shot(img, path, top, target_w=888, radius=18, crop=None):
    shot = frame_shot(path, target_w, radius, crop)
    x = (W - target_w) // 2
    img.alpha_composite(drop_shadow(shot, 38, 170), (x, top + 18))
    img.alpha_composite(shot, (x, top))
    # 縁取り 1px
    d = ImageDraw.Draw(img)
    d.rounded_rectangle(
        [x, top, x + target_w - 1, top + shot.height - 1], radius=radius, outline=LINE, width=2
    )
    return top + shot.height


# ---------------------------------------------------------------------------
# Slide 1: 表紙
# ---------------------------------------------------------------------------
def slide_cover():
    img = base_canvas()
    cx = W // 2
    glow_box = 720
    icon_cy = 398
    img.alpha_composite(radial_glow((glow_box, glow_box), GOLD, 0.28),
                        (cx - glow_box // 2, icon_cy - glow_box // 2))
    ibox = 360
    icon = Image.open(ICON).convert("RGBA").resize((ibox, ibox), Image.LANCZOS)
    ix, iy = cx - ibox // 2, icon_cy - ibox // 2
    img.alpha_composite(drop_shadow(icon, 32, 150), (ix, iy + 20))
    img.alpha_composite(icon, (ix, iy))

    d = ImageDraw.Draw(img)
    draw_wordmark(d, cx, 624, 124, TEXT)
    draw_slogan(d, cx, 756, 40)
    d.rounded_rectangle([cx - 44, 832, cx + 44, 836], radius=2, fill=GOLD)

    centered_kern(d, cx, 872, "目的地へ、一瞬で。", ja(48, bold=True), TEXT, 3)
    centered_kern(d, cx, 952, "ファイル・ターミナル・Claude Code を、ワンクリックで。", ja(27), TEXT_DIM, 1)

    # スワイプ誘導
    centered_kern(d, cx, 1108, "スワイプで機能紹介  →", ja(30, bold=True), GOLD, 2)
    page_dots(img, 0)
    img.convert("RGB").save(os.path.join(OUT, "01_cover.png"))
    print("wrote 01_cover.png")


# ---------------------------------------------------------------------------
# 機能スライド共通
# ---------------------------------------------------------------------------
def feature_slide(idx, label, title, desc_lines, shot, filename,
                  crop=None, shot_w=888, shot_top=430):
    img = base_canvas()
    d = ImageDraw.Draw(img)
    # ゴールドのラベル（番号 + 英字）
    num = f"{idx:02d}"
    lf = latin(30, weight=620)
    d.text((MARGIN, 108), num, font=lf, fill=GOLD)
    nw = d.textlength(num, font=lf)
    kern_text(d, (MARGIN + nw + 22, 110), label, latin(26, weight=560), TEXT_FAINT, 3)

    # タイトル
    d.text((MARGIN, 156), title, font=ja(60, bold=True), fill=TEXT)
    # 説明（複数行）
    y = 250
    for ln in desc_lines:
        d.text((MARGIN, y), ln, font=ja(30), fill=TEXT_DIM)
        y += 44

    place_shot(img, shot, top=shot_top, target_w=shot_w, crop=crop)
    footer_mark(img)
    page_dots(img, idx)
    img.convert("RGB").save(os.path.join(OUT, filename))
    print("wrote", filename)


# ---------------------------------------------------------------------------
# Slide 5: まとめ + CTA
# ---------------------------------------------------------------------------
def slide_outro():
    img = base_canvas()
    cx = W // 2
    d = ImageDraw.Draw(img)

    # 小アイコン + グロー
    glow_box = 460
    icon_cy = 250
    img.alpha_composite(radial_glow((glow_box, glow_box), GOLD, 0.22),
                        (cx - glow_box // 2, icon_cy - glow_box // 2))
    ibox = 184
    icon = Image.open(ICON).convert("RGBA").resize((ibox, ibox), Image.LANCZOS)
    img.alpha_composite(drop_shadow(icon, 22, 140), (cx - ibox // 2, icon_cy - ibox // 2 + 14))
    img.alpha_composite(icon, (cx - ibox // 2, icon_cy - ibox // 2))

    d = ImageDraw.Draw(img)
    centered_kern(d, cx, 392, "目的地へ、一瞬で。", ja(52, bold=True), TEXT, 3)
    d.rounded_rectangle([cx - 44, 484, cx + 44, 488], radius=2, fill=GOLD)

    feats = [
        "エクスプローラ中心のファイル操作",
        "お気に入り / ランチャーをツリーで管理",
        "アプリ内 PTY ターミナル",
        "画像 / PDF 対応のファイルプレビュー",
        "Git ビュー・アクティビティモニタ内蔵",
    ]
    fy = 562
    # 中央寄せの左揃えブロック
    block_left = 232
    tfont = ja(32)
    for f in feats:
        d.ellipse([block_left, fy + 13, block_left + 13, fy + 26], fill=GOLD)
        d.text((block_left + 36, fy), f, font=tfont, fill=TEXT)
        fy += 64

    draw_slogan(d, cx, 968, 38)
    centered_kern(d, cx, 1030, "macOS · MIT License", latin(26, weight=440), TEXT_FAINT, 1.5)

    footer_mark(img, y=1124)
    page_dots(img, 4)
    img.convert("RGB").save(os.path.join(OUT, "05_outro.png"))
    print("wrote 05_outro.png")


if __name__ == "__main__":
    slide_cover()
    feature_slide(
        1, "WORKSPACE", "3 画面ワークスペース",
        ["エクスプローラ・Git・ターミナルを", "1 つのタブに束ねて素早く行き来"],
        os.path.join(IMG, "hero.png"), "02_workspace.png",
    )
    feature_slide(
        2, "LAUNCHER", "ワンクリックで起動",
        ["「ディレクトリ + 動作」をサイドバーに登録。", "シェル / 任意コマンド / Claude Code"],
        os.path.join(IMG, "launcher.png"), "03_launcher.png",
        # サイドバーの LAUNCHER + RUNNING をアップにする
        crop=(95, 850, 540, 1560), shot_w=440, shot_top=418,
    )
    feature_slide(
        3, "GIT", "Git も内蔵ビューで",
        ["差分・ステージ・コミット・履歴を", "アプリから直接あつかえる"],
        os.path.join(IMG, "git.png"), "04_git.png",
    )
    slide_outro()
