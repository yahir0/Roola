#!/usr/bin/env python3
"""Roola の宣伝ステッカー（Mac に貼るダイカット風）を生成する。

Polaris デザインシステム（ADR-0038）の世界観で、定番のラップトップステッカーらしい
「白フチのダイカット + ソフトシャドウ」質感に仕上げる。背景は透過 PNG。

バリエーション:
- 01 die-cut icon : 翼＋フォルダのアイコン単体（角丸スクエアのダイカット）
- 02 wordmark pill: アイコン + Roola ワードマークの横長バッジ
- 03 vertical card: アイコン + Roola + FOR DEVELOPERS. の縦バッジ
- 04 circle badge : 円形バッジ（アイコン + 目的地へ、一瞬で。を周回）
- 05 square card  : 正方形バッジ（アイコン + Roola + FOR DEVELOPERS.）
- preview         : スペースグレイのラップトップ天板に貼った見え方

使い方: python3 branding/generate_stickers.py
出力  : branding/social/stickers/*.png
"""

import math
import os

from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ICON = os.path.join(ROOT, "branding", "roola_icon_master.png")
OUT = os.path.join(ROOT, "branding", "social", "stickers")
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

FONT_JA_BOLD = "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc"
FONT_LATIN = "/System/Library/Fonts/SFNS.ttf"

WHITE = (250, 250, 248)  # ステッカーのフチ（生成りのオフホワイト）

# ワードマーク "Roola" の体裁（カルーセルと統一: 太め + 負トラッキング）
WM_WEIGHT = 720
WM_TRACK_RATIO = -5 / 92

# スローガンの表記。SLOGAN_TITLECASE=True で "For Developers."（タイトルケース）。
# 全大文字は字間広め（0.18em）、タイトルケースは間延びするので狭め（0.03em）にする。
SLOGAN_TRACK_RATIO = 0.18
SLOGAN_TC_TRACK_RATIO = 0.03
SLOGAN_TITLECASE = False

# 末尾の "." をターミナルのカーソル風アクセントに置き換える。全大文字の小さな
# 末尾ピリオドが字間から取り残されて浮く問題を、「意図したアクセント（プロンプト
# のカーソル）」に変えて解消する狙い。Polaris（角丸 R=4px・4px グリッド・暖色
# ゴールド単色 / ADR-0038）とも整合する。
#
# CURSOR_STYLE: カーソルの形。塗りつぶし四角は「文字（■）」に見えてしまうため、
# 既定は枠だけのアウトライン（ターミナル非フォーカス時のカーソル＝箱に見える）。
#   "block_fill"    : 塗りつぶし正方形（≒ ■ に見えがち）
#   "block_outline" : 枠だけの四角（カーソルらしい・既定）
#   "underline"     : 下線カーソル（_）
#   "beam"          : 縦棒カーソル（I ビーム）
CURSOR_BLOCK = True
CURSOR_STYLE = "underline"
CURSOR_GAP_RATIO = 0.30  # 最後の文字とカーソルの間隔（cap height 比）
CURSOR_W_RATIO = 1.0     # ブロック系の横幅（cap height 比。1.0 = 正方形）


def _cursor_width(cap_h):
    """カーソル形状が消費する横幅（cap height 基準）。"""
    if CURSOR_STYLE == "underline":
        return cap_h * 0.72
    if CURSOR_STYLE == "beam":
        return max(2.0, cap_h * 0.16)
    return cap_h * CURSOR_W_RATIO  # block_fill / block_outline


def _draw_cursor(draw, x, y, t, b, fill):
    """左端 x・テキスト top y・cap box (t,b) を基準にカーソルを描く。"""
    cap_h = b - t
    top, base = int(y + t), int(y + b)
    if CURSOR_STYLE == "block_fill":
        w = cap_h * CURSOR_W_RATIO
        draw.rectangle([int(x), top, int(x + w) - 1, base - 1], fill=fill)
    elif CURSOR_STYLE == "block_outline":
        w = cap_h * CURSOR_W_RATIO
        sw = max(2, round(cap_h * 0.12))
        draw.rectangle([int(x), top, int(x + w) - 1, base - 1], outline=fill, width=sw)
    elif CURSOR_STYLE == "underline":
        w = cap_h * 0.72
        sw = max(2, round(cap_h * 0.16))
        draw.rectangle([int(x), base - sw, int(x + w) - 1, base - 1], fill=fill)
    elif CURSOR_STYLE == "beam":
        w = max(2, round(cap_h * 0.16))
        draw.rectangle([int(x), top, int(x) + w - 1, base - 1], fill=fill)


def slogan_str():
    return "For Developers." if SLOGAN_TITLECASE else "FOR DEVELOPERS."


def slogan_word():
    """末尾ピリオドを除いた本体（ブロックカーソル化の対象）。"""
    return "For Developers" if SLOGAN_TITLECASE else "FOR DEVELOPERS"


def slogan_track(size):
    return size * (SLOGAN_TC_TRACK_RATIO if SLOGAN_TITLECASE else SLOGAN_TRACK_RATIO)


def _cap_box(draw, font):
    """フォントの大文字 cap top / baseline を、text 描画と同じ座標系（top 基準）
    で返す。anchor 既定（"la" = 左/ascender top）で測る。"""
    _, t, _, b = draw.textbbox((0, 0), "H", font=font)
    return t, b


def slogan_width(draw, font, tracking):
    """スローガン（ブロックカーソル込み）の総幅。"""
    if not CURSOR_BLOCK:
        return kern_width(draw, slogan_str(), font, tracking)
    word_w = kern_width(draw, slogan_word(), font, tracking)
    t, b = _cap_box(draw, font)
    cap_h = b - t
    return word_w + cap_h * CURSOR_GAP_RATIO + _cursor_width(cap_h)


def draw_slogan(draw, x, y, font, fill, tracking):
    """左揃えでスローガンを描く。CURSOR_BLOCK のとき末尾 "." をゴールドの
    cap height 四角（ブロックカーソル）にする。"""
    if not CURSOR_BLOCK:
        kern_text(draw, (x, y), slogan_str(), font, fill, tracking)
        return
    word = slogan_word()
    kern_text(draw, (x, y), word, font, fill, tracking)
    end_x = x + kern_width(draw, word, font, tracking)
    t, b = _cap_box(draw, font)
    bx0 = end_x + (b - t) * CURSOR_GAP_RATIO
    _draw_cursor(draw, bx0, y, t, b, fill)


def centered_slogan(draw, cx, y, font, fill, tracking):
    """中央揃えでスローガン（ブロックカーソル込み）を描く。"""
    w = slogan_width(draw, font, tracking)
    draw_slogan(draw, cx - w / 2, y, font, fill, tracking)


def latin(size, weight=None):
    f = ImageFont.truetype(FONT_LATIN, size)
    if weight is not None:
        try:
            coords = []
            for a in f.get_variation_axes():
                name = a["name"].decode() if isinstance(a["name"], bytes) else a["name"]
                if name == "Weight":
                    coords.append(weight)
                elif name == "Optical Size":
                    coords.append(min(size, a["maximum"]))
                else:
                    coords.append(a["default"])
            f.set_variation_by_axes(coords)
        except Exception:
            pass
    return f


def ja(size, bold=True):
    return ImageFont.truetype(FONT_JA_BOLD, size)


def kern_width(draw, text, font, tracking):
    return sum(draw.textlength(ch, font=font) + tracking for ch in text) - tracking


def kern_text(draw, pos, text, font, fill, tracking):
    x, y = pos
    for ch in text:
        draw.text((x, y), ch, font=font, fill=fill)
        x += draw.textlength(ch, font=font) + tracking


def centered_kern(draw, cx, y, text, font, fill, tracking):
    w = kern_width(draw, text, font, tracking)
    kern_text(draw, (cx - w / 2, y), text, font, fill, tracking)


def vgrad(w, h, top, bottom):
    g = Image.new("RGB", (1, h))
    px = g.load()
    for y in range(h):
        t = y / (h - 1)
        px[0, y] = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
    return g.resize((w, h))


def die_cut(content, border=46, shadow_blur=40, shadow_alpha=120, shadow_dy=22):
    """content(RGBA) のシルエットに沿った白フチ + ソフトシャドウを付けたステッカーを返す。

    アルファをブラー → しきい値で外側に膨張させ、角が自然に丸い die-cut 風の輪郭にする。
    返り値は (border + shadow) ぶんだけ拡張した透過キャンバス。
    """
    pad = border + shadow_blur + abs(shadow_dy) + 12
    w, h = content.size
    canvas = Image.new("RGBA", (w + pad * 2, h + pad * 2), (0, 0, 0, 0))
    ox, oy = pad, pad

    alpha = content.split()[-1]
    base = Image.new("L", canvas.size, 0)
    base.paste(alpha, (ox, oy))

    # 膨張（白フチ）: ブラー → しきい値。border の太さぶん広げる。
    grow = base.filter(ImageFilter.GaussianBlur(border * 0.62))
    border_mask = grow.point(lambda v: 255 if v > 36 else 0)
    border_mask = border_mask.filter(ImageFilter.GaussianBlur(1.2))  # フチを軽く整える

    # ドロップシャドウ（フチ形状を落とす）
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sh_a = border_mask.point(lambda v: int(v / 255 * shadow_alpha))
    shadow.putalpha(sh_a)
    shadow = shadow.filter(ImageFilter.GaussianBlur(shadow_blur))
    shadow = Image.composite(
        Image.new("RGBA", canvas.size, (0, 0, 0, 255)),
        Image.new("RGBA", canvas.size, (0, 0, 0, 0)),
        shadow.split()[-1],
    )
    canvas.alpha_composite(shadow, (0, shadow_dy))

    # 白フチ本体
    white = Image.new("RGBA", canvas.size, WHITE + (0,))
    white.putalpha(border_mask)
    canvas.alpha_composite(white)

    # コンテンツを上に
    canvas.alpha_composite(content, (ox, oy))
    return canvas


def rounded_card(w, h, radius):
    """Polaris 地のグラファイト角丸カード（縦グラデ地 + 細い枠線）。"""
    card = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    fill = vgrad(w, h, BG, WELL).convert("RGBA")
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w - 1, h - 1], radius=radius, fill=255)
    card.paste(fill, (0, 0), mask)
    # 枠線
    ImageDraw.Draw(card).rounded_rectangle(
        [1, 1, w - 2, h - 2], radius=radius - 1, outline=LINE, width=2
    )
    return card, mask


def icon_img(size):
    return Image.open(ICON).convert("RGBA").resize((size, size), Image.LANCZOS)


def radial_glow(size, color, intensity=1.0):
    """中心が濃く外へ向かって消えるソフトな円形グロー（RGBA）。"""
    s = 200
    m = Image.new("L", (s, s), 0)
    px = m.load()
    c = s / 2
    for y in range(s):
        for x in range(s):
            d = (((x - c) ** 2 + (y - c) ** 2) ** 0.5) / c
            v = max(0.0, 1.0 - d)
            px[x, y] = int((v ** 2.2) * 255 * intensity)
    m = m.resize(size).filter(ImageFilter.GaussianBlur(size[0] // 18))
    layer = Image.new("RGBA", size, color + (0,))
    layer.putalpha(m)
    return layer


def place_icon(card, size, topleft, glow=True):
    """アプリアイコンをカードに置く。地と同色で溶けて見えないよう、背後にゴールドの
    グローと落ち影を入れて浮かせ、角丸地の輪郭を読み取れるようにする。"""
    x, y = topleft
    cx_, cy_ = x + size // 2, y + size // 2
    if glow:
        g = int(size * 1.5)
        card.alpha_composite(radial_glow((g, g), GOLD, 0.30), (cx_ - g // 2, cy_ - g // 2))
    icon = icon_img(size)
    # 落ち影（アイコンのアルファ形状を黒く落とす）
    a = icon.split()[-1]
    sh = Image.new("RGBA", icon.size, (0, 0, 0, 0))
    sh.putalpha(a.point(lambda v: int(v / 255 * 150)))
    sh = sh.filter(ImageFilter.GaussianBlur(int(size * 0.05)))
    card.alpha_composite(sh, (x, y + int(size * 0.03)))
    card.alpha_composite(icon, (x, y))


def save(img, name):
    path = os.path.join(OUT, name)
    img.save(path)
    print("wrote", name, img.size)
    return path


# ---------------------------------------------------------------------------
# 01: アイコン単体ダイカット
# ---------------------------------------------------------------------------
def sticker_icon():
    icon = icon_img(620)
    out = die_cut(icon, border=44, shadow_blur=46, shadow_alpha=130, shadow_dy=24)
    return save(out, "01_icon.png")


# ---------------------------------------------------------------------------
# 02: 横長ワードマークバッジ（アイコン + Roola）
# ---------------------------------------------------------------------------
def sticker_wordmark_pill():
    isz = 188
    pad_x, pad_y = 64, 52
    gap = 40
    tmp = ImageDraw.Draw(Image.new("RGBA", (1, 1)))
    wm_font = latin(150, weight=WM_WEIGHT)
    track = 150 * WM_TRACK_RATIO
    # FOR DEVELOPERS.（小・金）/ Roola（大）/ URL（小・dim）の上下対称ロックアップ。
    eb_h = 24
    eb_font = latin(eb_h, weight=700)
    eb_track = slogan_track(eb_h)
    url_h = 22
    url_font = latin(url_h, weight=520)
    url_track = 2
    wm_w = kern_width(tmp, "Roola", wm_font, track)
    eb_w = slogan_width(tmp, eb_font, eb_track)
    url_w = kern_width(tmp, "yahiro.tech/roola", url_font, url_track)
    text_w = max(wm_w, eb_w, url_w)

    w = int(pad_x + isz + gap + text_w + pad_x)
    h = int(pad_y + isz + pad_y)
    radius = h // 2  # ピル形
    card, _ = rounded_card(w, h, radius)
    d = ImageDraw.Draw(card)

    place_icon(card, isz, (pad_x, (h - isz) // 2))
    tx = pad_x + isz + gap
    # 縦中央に 3 行。Roola が大きく上下パディングが効くため、g_eb / g_url を負にして寄せる。
    g_eb = -14   # eyebrow → Roola
    g_url = 6    # Roola → URL（150px の Roola はベースラインが下なので em ボックスの下に出す）
    block_h = eb_h + g_eb + 150 + g_url + url_h
    ty = (h - block_h) // 2 - 2
    draw_slogan(d, tx + 4, ty, eb_font, GOLD, eb_track)
    roola_y = ty + eb_h + g_eb
    kern_text(d, (tx, roola_y), "Roola", wm_font, TEXT, track)
    kern_text(d, (tx + 4, roola_y + 150 + g_url), "yahiro.tech/roola", url_font, TEXT_DIM, url_track)

    out = die_cut(card, border=40, shadow_blur=44, shadow_alpha=125, shadow_dy=22)
    return save(out, "02_wordmark_pill.png")


# ---------------------------------------------------------------------------
# 03: 縦バッジ（アイコン + Roola + FOR DEVELOPERS.）
# ---------------------------------------------------------------------------
def sticker_vertical():
    w, h = 620, 760
    radius = 72
    card, _ = rounded_card(w, h, radius)
    d = ImageDraw.Draw(card)
    cx = w // 2

    # HP ヒーローと同じロックアップ: アイコン → FOR DEVELOPERS.（極小 eyebrow）→
    # Roola → 目的地へ、一瞬で。 → URL。overlap はアイコン箱下部の空白へ文字を寄せる量。
    isz = 320
    overlap = 26
    eb_h = 20   # eyebrow（HP 比 ≈ ワードマークの 15%）
    g_eb = 16   # eyebrow → ワードマーク
    wm_h = 126
    g_tag = 26  # ワードマーク → 日本語タグライン
    tag_h = 50
    g_url = 22  # タグライン → URL
    url_h = 24
    group_h = isz - overlap + eb_h + g_eb + wm_h + g_tag + tag_h + g_url + url_h
    iy = (h - group_h) // 2

    place_icon(card, isz, (cx - isz // 2, iy))

    eb_y = iy + isz - overlap
    centered_slogan(d, cx, eb_y, latin(eb_h, weight=700), GOLD, slogan_track(eb_h))

    wm_y = eb_y + eb_h + g_eb
    centered_kern(d, cx, wm_y, "Roola", latin(wm_h, weight=WM_WEIGHT), TEXT, wm_h * WM_TRACK_RATIO)

    tag_y = wm_y + wm_h + g_tag
    centered_kern(d, cx, tag_y, "目的地へ、一瞬で。", ja(tag_h, bold=True), TEXT, 3)

    url_y = tag_y + tag_h + g_url
    centered_kern(d, cx, url_y, "yahiro.tech/roola", latin(url_h, weight=520), TEXT_DIM, 2)

    out = die_cut(card, border=42, shadow_blur=46, shadow_alpha=128, shadow_dy=24)
    return save(out, "03_vertical.png")


# ---------------------------------------------------------------------------
# 05: 正方形バッジ（アイコン + Roola + FOR DEVELOPERS.）
# ---------------------------------------------------------------------------
def sticker_square():
    w = h = 680
    radius = 80
    card, _ = rounded_card(w, h, radius)
    d = ImageDraw.Draw(card)
    cx = w // 2

    # HP ヒーローと同じロックアップ: アイコン → FOR DEVELOPERS.（極小 eyebrow）→
    # Roola → 目的地へ、一瞬で。 → URL。overlap はアイコン箱下部の空白へ文字を寄せる量。
    isz = 264
    overlap = 22
    eb_h = 18   # eyebrow（HP 比 ≈ ワードマークの 15%）
    g_eb = 14   # eyebrow → ワードマーク
    wm_h = 108
    g_tag = 24  # ワードマーク → 日本語タグライン
    tag_h = 44
    g_url = 18  # タグライン → URL
    url_h = 22
    group_h = isz - overlap + eb_h + g_eb + wm_h + g_tag + tag_h + g_url + url_h
    iy = (h - group_h) // 2

    place_icon(card, isz, (cx - isz // 2, iy))

    eb_y = iy + isz - overlap
    centered_slogan(d, cx, eb_y, latin(eb_h, weight=700), GOLD, slogan_track(eb_h))

    wm_y = eb_y + eb_h + g_eb
    centered_kern(d, cx, wm_y, "Roola", latin(wm_h, weight=WM_WEIGHT), TEXT, wm_h * WM_TRACK_RATIO)

    tag_y = wm_y + wm_h + g_tag
    centered_kern(d, cx, tag_y, "目的地へ、一瞬で。", ja(tag_h, bold=True), TEXT, 3)

    url_y = tag_y + tag_h + g_url
    centered_kern(d, cx, url_y, "yahiro.tech/roola", latin(url_h, weight=520), TEXT_DIM, 2)

    out = die_cut(card, border=44, shadow_blur=46, shadow_alpha=128, shadow_dy=24)
    return save(out, "05_square.png")


# ---------------------------------------------------------------------------
# 04: 円形バッジ（中央=HP ロックアップ + 上弧に目的地へ、一瞬で。のエンブレム調）
# ---------------------------------------------------------------------------
def sticker_circle():
    D = 640
    card = Image.new("RGBA", (D, D), (0, 0, 0, 0))
    fill = vgrad(D, D, BG, WELL).convert("RGBA")
    mask = Image.new("L", (D, D), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, D - 1, D - 1], fill=255)
    card.paste(fill, (0, 0), mask)
    d = ImageDraw.Draw(card)
    cx = cy = D // 2

    # 二重リング（細線 + ゴールドの破線リング）
    d.ellipse([6, 6, D - 7, D - 7], outline=LINE, width=3)
    d.ellipse([26, 26, D - 27, D - 27], outline=TOP_EDGE, width=2)

    # 円弧に沿ったテキスト。座標系は 0°=右 / 90°=下 / 180°=左。
    # 各文字の実幅ぶんだけ弧に沿って進める（プロポーショナル配置）ので、句読点など
    # 幅の狭い文字の前後が間延びしない。anchor="ms" で全文字を共通ベースラインに揃える。
    def arc_text(text, font, fill, radius, center_deg, tracking=0.0, flip=False):
        advs = [d.textlength(ch, font=font) + tracking for ch in text]
        total = sum(advs) - tracking
        cursor = -total / 2
        for ch, a in zip(text, advs):
            s = cursor + (a - tracking) / 2
            dtheta = math.degrees(s / radius)
            if flip:
                ang = center_deg - dtheta
                rot = -(ang - 90)
            else:
                ang = center_deg + dtheta
                rot = -(ang + 90)
            rad = math.radians(ang)
            px = cx + radius * math.cos(rad)
            py = cy + radius * math.sin(rad)
            glyph = Image.new("RGBA", (140, 140), (0, 0, 0, 0))
            ImageDraw.Draw(glyph).text((70, 70), ch, font=font, fill=fill, anchor="ms")
            glyph = glyph.rotate(rot, resample=Image.BICUBIC, center=(70, 70))
            card.alpha_composite(glyph, (int(px - 70), int(py - 70)))
            cursor += a

    # 上弧のみ（目的地へ、一瞬で。）。弧を上下 2 本にするとレンズ形になり口に
    # 見えるため、上弧 1 本だけにする。
    arc_text("目的地へ、一瞬で。", ja(38), TEXT, 250, center_deg=-90, tracking=10)

    # 中央: HP と同じロックアップ（アイコン → FOR DEVELOPERS_ → Roola）。上弧に
    # 釣り合うよう、わずかに上へ寄せる。
    isz = 264
    overlap = 22
    eb_h = 18
    g_eb = 12
    wm_h = 84
    group_h = isz - overlap + eb_h + g_eb + wm_h
    iy = cy - 6 - group_h // 2

    place_icon(card, isz, (cx - isz // 2, iy))

    eb_y = iy + isz - overlap
    centered_slogan(d, cx, eb_y, latin(eb_h, weight=700), GOLD, slogan_track(eb_h))

    wm_y = eb_y + eb_h + g_eb
    centered_kern(d, cx, wm_y, "Roola", latin(wm_h, weight=WM_WEIGHT), TEXT, wm_h * WM_TRACK_RATIO)

    # URL は Roola の直下に寄せる（旧: cy+208 でロックアップから離れて浮いていた）。
    url_y = wm_y + wm_h + 14
    centered_kern(d, cx, url_y, "yahiro.tech/roola", latin(22, weight=520), TEXT_DIM, 2)

    card.putalpha(mask)
    out = die_cut(card, border=44, shadow_blur=46, shadow_alpha=128, shadow_dy=24)
    return save(out, "04_circle.png")


# ---------------------------------------------------------------------------
# プレビュー: スペースグレイの天板に貼った見え方
# ---------------------------------------------------------------------------
def preview(paths):
    W, H = 1600, 1000
    lid = vgrad(W, H, (78, 80, 84), (52, 54, 58)).convert("RGBA")
    # アルミの微細な縦ヘアライン
    d = ImageDraw.Draw(lid)
    for x in range(0, W, 3):
        shade = 6 if (x // 3) % 2 == 0 else -6
        c = tuple(max(0, min(255, 64 + shade)) for _ in range(3))
        d.line([(x, 0), (x, H)], fill=c + (40,), width=1)

    def paste(p, scale, center):
        s = Image.open(p).convert("RGBA")
        nw = int(s.width * scale)
        nh = int(s.height * scale)
        s = s.resize((nw, nh), Image.LANCZOS)
        lid.alpha_composite(s, (center[0] - nw // 2, center[1] - nh // 2))

    paste(paths["icon"], 0.50, (250, 300))
    paste(paths["vertical"], 0.42, (250, 720))
    paste(paths["circle"], 0.50, (760, 300))
    paste(paths["square"], 0.46, (760, 760))
    paste(paths["pill"], 0.44, (1270, 470))
    save(lid.convert("RGB").convert("RGBA"), "00_preview_on_laptop.png")


# ---------------------------------------------------------------------------
# 比較: 末尾の扱い（ピリオド / ブロックカーソル）を拡大して見比べる
# ---------------------------------------------------------------------------
def slogan_compare():
    """`FOR DEVELOPERS` の末尾の扱いを並べた拡大比較。CURSOR_STYLE の
    グローバルを一時的に差し替えて各案を描く（塗りつぶし四角は文字に見える
    ため、枠 / 下線 / 縦棒のカーソル形を見比べる）。"""
    global CURSOR_BLOCK, CURSOR_STYLE
    saved = (CURSOR_BLOCK, CURSOR_STYLE)

    rows = [
        ("現状: ピリオド", (False, None)),
        ("塗り四角（文字に見える）", (True, "block_fill")),
        ("枠カーソル（おすすめ）", (True, "block_outline")),
        ("下線カーソル", (True, "underline")),
        ("縦棒カーソル", (True, "beam")),
    ]

    size = 84
    row_h = 132
    y0 = 56
    w, h = 1220, y0 + row_h * len(rows) + 24
    radius = 40
    card, _ = rounded_card(w, h, radius)
    d = ImageDraw.Draw(card)
    cx = w // 2
    font = latin(size, weight=700)
    track = size * SLOGAN_TRACK_RATIO
    label = ja(24)

    for i, (name, (blk, style)) in enumerate(rows):
        CURSOR_BLOCK, CURSOR_STYLE = blk, style
        ry = y0 + i * row_h
        centered_kern(d, cx, ry, name, label, TEXT_DIM, 1)
        centered_slogan(d, cx, ry + 40, font, GOLD, track)
        if i < len(rows) - 1:
            d.line([(80, ry + row_h - 14), (w - 80, ry + row_h - 14)],
                   fill=LINE, width=1)

    CURSOR_BLOCK, CURSOR_STYLE = saved
    return save(card, "slogan_compare.png")


def render_all():
    paths = {
        "icon": sticker_icon(),
        "pill": sticker_wordmark_pill(),
        "vertical": sticker_vertical(),
        "circle": sticker_circle(),
        "square": sticker_square(),
    }
    preview(paths)
    slogan_compare()


if __name__ == "__main__":
    # スローガンは HP（textTransform: uppercase）に合わせて全大文字「FOR DEVELOPERS.」。
    render_all()
    print("done ->", OUT)
