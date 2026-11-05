"""Lays out the store screenshots, the feature graphic and the 512 px icon.

    flutter test tool/store/screenshots_test.dart   # raw screens first
    uv run --with pillow python tool/store/frame.py

Reads build/store/raw/{fr,en}/*.png, writes docs/store/.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "build/store/raw"
OUT = ROOT / "docs/store"
FONT = ROOT / "assets/fonts/SourGummy-SemiBold.ttf"
ICON = ROOT / "assets/icon/icon.png"

ACCENT, ACCENT_DEEP = (240, 80, 127), (201, 61, 104)
POP_SHADOW = (59, 23, 48, 64)
LILAC, SKY, MINT, LEMON, PEACH = (
    (220, 200, 255),
    (191, 227, 255),
    (182, 240, 210),
    (255, 240, 154),
    (255, 203, 164),
)

# Play guidance: no price or ranking claims ("Free", "#1"…) in these images.
CAPTIONS = {
    "fr": {
        "01-today": "Maintiens appuyé.\nEncore un pas de fait.",
        "02-timer": "Chaque minute compte\npour ta semaine",
        "03-detail": "Suis chaque verre,\nchaque page",
        "04-progress": "Regarde tes\nprogrès grandir",
        "05-trophies": "Badges, défis et séries\nà débloquer",
        "06-create": "Une nouvelle habitude\nen 3 étapes",
    },
    "en": {
        "01-today": "Press and hold.\nOne more step done.",
        "02-timer": "Every minute counts\ntoward your week",
        "03-detail": "Track every glass,\nevery page",
        "04-progress": "Watch your\nprogress grow",
        "05-trophies": "Badges, challenges\nand streaks",
        "06-create": "A new habit\nin 3 steps",
    },
}
TAGLINE = {
    "fr": "Petites habitudes,\ngrandes séries",
    "en": "Small steps,\nlasting habits",
}

# UI element enlarged out of each screen: raw box, corner radius, zoom.
POPS = {
    "01-today": ((53, 699, 1027, 866), 84, 0.95),
    "02-timer": ((53, 1602, 1027, 1866), 44, 0.95),
    "03-detail": ((53, 1222, 1027, 1392), 44, 0.95),
    "04-progress": ((53, 741, 1027, 1016), 44, 0.92),
    # Wraps a line above the week bars in French, which pushes them down.
    ("fr", "04-progress"): ((53, 796, 1027, 1071), 44, 0.92),
    "05-trophies": ((553, 509, 1027, 678), 44, 1.0),
    "06-create": ((53, 1276, 1027, 1418), 44, 0.95),
}

# Edge pills of the feature graphic: x, y, colour.
PILLS = [
    (-80, 44, LILAC),
    (-130, 172, LEMON),
    (-60, 372, MINT),
    (860, 64, SKY),
    (900, 244, PEACH),
    (836, 380, LILAC),
]

W, H = 1080, 1920
SCREEN_W, SCREEN_TOP = 820, 340  # hides the nav bar, which starts at raw y 2148
SCALE = 4  # shapes are drawn large and scaled down to smooth their edges


def rounded_mask(size, radius):
    w, h = size
    mask = Image.new("L", (w * SCALE, h * SCALE), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, w * SCALE - 1, h * SCALE - 1], radius * SCALE, fill=255
    )
    return mask.resize(size, Image.LANCZOS)


def popped(canvas, screen, box, radius, zoom):
    """Pastes [box] of the raw [screen] over its place in the frame, enlarged."""
    x0, y0, x1, y1 = box
    scale = SCREEN_W / screen.width
    size = (round((x1 - x0) * zoom), round((y1 - y0) * zoom))
    left = round((W - SCREEN_W) / 2 + (x0 + x1) / 2 * scale - size[0] / 2)
    top = round(SCREEN_TOP + (y0 + y1) / 2 * scale - size[1] / 2)
    mask = rounded_mask(size, round(radius * zoom))

    shadow = Image.new("RGBA", size, POP_SHADOW)
    shadow.putalpha(mask.point(lambda a: a * POP_SHADOW[3] // 255))
    canvas.alpha_composite(shadow, (left, top + 12))

    crop = screen.crop(box).resize(size, Image.LANCZOS).convert("RGBA")
    crop.putalpha(mask)
    canvas.alpha_composite(crop, (left, top))


def framed(raw: Path, caption: str, pop) -> Image.Image:
    canvas = Image.new("RGBA", (W, H), ACCENT)
    draw = ImageDraw.Draw(canvas)
    font = ImageFont.truetype(str(FONT), 80)
    y = 84
    for line in caption.split("\n"):
        assert draw.textlength(line, font=font) <= 960, f"too wide: {line}"
        draw.text((W / 2, y), line, font=font, fill="white", anchor="mt")
        y += 94
    assert y <= H * 0.2, f"caption over 20% of the image: {caption}"

    source = Image.open(raw).convert("RGB")
    sh = round(source.height * SCREEN_W / source.width)
    screen = source.resize((SCREEN_W, sh), Image.LANCZOS)
    screen = screen.crop((0, 0, SCREEN_W, H - SCREEN_TOP))  # bleeds off the bottom edge
    mask = rounded_mask((SCREEN_W, H - SCREEN_TOP + 60), 52).crop(
        (0, 0, SCREEN_W, H - SCREEN_TOP)
    )
    phone = screen.convert("RGBA")
    phone.putalpha(mask)
    canvas.alpha_composite(phone, ((W - SCREEN_W) // 2, SCREEN_TOP))

    popped(canvas, source, *pop)
    return canvas.convert("RGB")


def feature_graphic(lang: str) -> Image.Image:
    canvas = Image.new("RGB", (1024 * SCALE, 500 * SCALE), ACCENT)
    draw = ImageDraw.Draw(canvas)
    for x, y, color in PILLS:
        for offset, fill in ((8, ACCENT_DEEP), (0, color)):
            draw.rounded_rectangle(
                [
                    x * SCALE,
                    (y + offset) * SCALE,
                    (x + 260) * SCALE,
                    (y + offset + 84) * SCALE,
                ],
                42 * SCALE,
                fill=fill,
            )

    lines = TAGLINE[lang].split("\n")
    size = 100
    while True:  # French runs longer; it must stay clear of the middle pills
        font = ImageFont.truetype(str(FONT), size * SCALE)
        if max(draw.textlength(l, font=font) for l in lines) <= 680 * SCALE:
            break
        size -= 2
    for i, line in enumerate(lines):
        y = 250 + (i - 0.5) * size * 1.12
        draw.text((512 * SCALE, y * SCALE), line, font=font, fill="white", anchor="mm")
    return canvas.resize((1024, 500), Image.LANCZOS)


def main():
    for lang, captions in CAPTIONS.items():
        folder = OUT / "screenshots" / lang
        folder.mkdir(parents=True, exist_ok=True)
        for i, (name, caption) in enumerate(captions.items(), start=1):
            pop = POPS.get((lang, name), POPS[name])
            shot = framed(RAW / lang / f"{name}.png", caption, pop)
            assert shot.size == (W, H) and shot.mode == "RGB"
            shot.save(folder / f"{i:02d}.png")
        graphic = feature_graphic(lang)
        assert graphic.size == (1024, 500) and graphic.mode == "RGB"
        graphic.save(OUT / f"feature-graphic-{lang}.png")
    Image.open(ICON).convert("RGB").resize((512, 512), Image.LANCZOS).save(
        OUT / "icon-512.png"
    )
    print("written to", OUT)


if __name__ == "__main__":
    main()
