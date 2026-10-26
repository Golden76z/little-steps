"""Lays out the store screenshots, the feature graphic and the 512 px icon.

    flutter test tool/store/screenshots_test.dart   # raw screens first
    uv run --with pillow python tool/store/frame.py

Reads build/store/raw/{fr,en}/*.png, writes docs/store/.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "build/store/raw"
OUT = ROOT / "docs/store"
FONT = ROOT / "assets/fonts/SourGummy-SemiBold.ttf"
ICON = ROOT / "assets/icon/icon.png"

BG_TOP, BG_BOTTOM = (255, 240, 244), (250, 214, 226)
INK = (58, 27, 46)
ACCENT, ACCENT_DEEP = (224, 89, 126), (196, 62, 104)
EDGE = (242, 201, 214)

CAPTIONS = {
    "fr": {
        "01-today": "Tes habitudes du jour, en un coup d’œil",
        "02-timer": "Un minuteur pour chaque séance",
        "03-detail": "Suis chaque verre, chaque page",
        "04-progress": "Regarde tes progrès grandir",
        "05-trophies": "Badges, défis et séries à débloquer",
        "06-create": "Une nouvelle habitude en 3 étapes",
    },
    "en": {
        "01-today": "Today’s habits at a glance",
        "02-timer": "A timer for every session",
        "03-detail": "Track every glass, every page",
        "04-progress": "Watch your progress grow",
        "05-trophies": "Badges, challenges and streaks",
        "06-create": "A new habit in 3 steps",
    },
}
TAGLINE = {
    "fr": "Petites habitudes, grandes séries",
    "en": "Small steps, lasting habits",
}

W, H = 1080, 1920


def gradient(size, top, bottom):
    w, h = size
    img = Image.new("RGB", size, top)
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(h - 1, 1)
        draw.line(
            [(0, y), (w, y)],
            fill=tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)),
        )
    return img


def wrap(draw, text, font, width):
    """Splits [text] into at most two balanced lines that fit [width]."""
    if draw.textlength(text, font=font) <= width:
        return [text]
    words = text.split()
    best = None
    for i in range(1, len(words)):
        a, b = " ".join(words[:i]), " ".join(words[i:])
        widest = max(draw.textlength(a, font=font), draw.textlength(b, font=font))
        if widest <= width and (best is None or widest < best[0]):
            best = (widest, [a, b])
    return best[1] if best else [text]


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, img.width - 1, img.height + radius], radius, fill=255
    )
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def framed(raw: Path, caption: str) -> Image.Image:
    canvas = gradient((W, H), BG_TOP, BG_BOTTOM).convert("RGBA")
    draw = ImageDraw.Draw(canvas)
    font = ImageFont.truetype(str(FONT), 72)
    lines = wrap(draw, caption, font, 900)
    y = 150 if len(lines) == 1 else 110
    for line in lines:
        draw.text((W / 2, y), line, font=font, fill=INK, anchor="mt")
        y += 92

    screen = Image.open(raw).convert("RGB")
    sw = 860
    screen = screen.resize((sw, round(screen.height * sw / screen.width)), Image.LANCZOS)
    top = 400
    screen = screen.crop((0, 0, sw, H - top))  # bleeds off the bottom edge
    phone = rounded(screen, 54)

    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [(W - sw) / 2, top + 18, (W + sw) / 2, H + 60], 54, fill=(150, 60, 95, 70)
    )
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(28)))
    ImageDraw.Draw(canvas).rounded_rectangle(
        [(W - sw) / 2 - 6, top - 6, (W + sw) / 2 + 6, H + 60], 60, fill=EDGE
    )
    canvas.alpha_composite(phone, ((W - sw) // 2, top))
    return canvas.convert("RGB")


def feature_graphic(lang: str) -> Image.Image:
    canvas = gradient((1024, 500), ACCENT, ACCENT_DEEP).convert("RGBA")
    icon = Image.open(ICON).convert("RGBA").resize((300, 300), Image.LANCZOS)
    mask = Image.new("L", icon.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, 299, 299], 66, fill=255)
    icon.putalpha(mask)
    canvas.alpha_composite(icon, (90, 100))
    draw = ImageDraw.Draw(canvas)
    draw.text((450, 170), "Little Steps", font=ImageFont.truetype(str(FONT), 92),
              fill="white", anchor="ls")
    tagline = ImageFont.truetype(str(FONT), 38)
    lines = wrap(draw, TAGLINE[lang], tagline, 520)
    y = 250
    for line in lines:
        draw.text((452, y), line, font=tagline, fill=(255, 236, 242), anchor="ls")
        y += 52
    return canvas.convert("RGB")


def main():
    for lang, captions in CAPTIONS.items():
        folder = OUT / "screenshots" / lang
        folder.mkdir(parents=True, exist_ok=True)
        for i, (name, caption) in enumerate(captions.items(), start=1):
            framed(RAW / lang / f"{name}.png", caption).save(folder / f"{i:02d}.png")
        feature_graphic(lang).save(OUT / f"feature-graphic-{lang}.png")
    Image.open(ICON).convert("RGB").resize((512, 512), Image.LANCZOS).save(
        OUT / "icon-512.png"
    )
    print("written to", OUT)


if __name__ == "__main__":
    main()
