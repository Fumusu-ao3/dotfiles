#!/usr/bin/env python3
import sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageEnhance, ImageOps

FONT = "/usr/share/fonts/inter/Inter.ttc"

def font(size, bold=False):
    for i in range(40):
        try:
            f = ImageFont.truetype(FONT, size, index=i)
        except OSError:
            break
        name = " ".join(f.getname())
        if bold and name.endswith("Bold") and "Display" not in name and "Extra" not in name and "Semi" not in name:
            return f
        if not bold and name == "Inter Regular":
            return f
    return ImageFont.truetype(FONT, size)

def layout(lines, size, cols, w, h, title_h):
    """Devuelve el alto total de cada columna o None si no entra."""
    f = font(size)
    line_h = int(size * 1.45)
    per_col = -(-len(lines) // cols)
    col_w = (w * 0.86) / cols
    if any(f.getlength(l) > col_w * 0.94 for l in lines):
        return None
    total = per_col * line_h
    return total if total + title_h <= h * 0.86 else None

def main():
    lyr, bg, out, res = sys.argv[1:5]
    title = sys.argv[5] if len(sys.argv) > 5 else ""
    w, h = map(int, res.split("x"))
    lines = open(lyr, encoding="utf-8").read().strip("\n").splitlines()
    lines = [l.rstrip() for l in lines]

    img = ImageOps.fit(Image.open(bg).convert("RGB"), (w, h), Image.LANCZOS)
    img = img.filter(ImageFilter.GaussianBlur(w / 160))
    img = ImageEnhance.Brightness(img).enhance(0.45)

    title_size = max(18, h // 22)
    title_h = int(title_size * 2.2) if title else 0

    best = None
    for size in range(max(12, h // 26), 8, -1):
        for cols in (1, 2, 3):
            if layout(lines, size, cols, w, h, title_h):
                best = (size, cols)
                break
        if best:
            break
    size, cols = best or (9, 3)

    d = ImageDraw.Draw(img)
    f = font(size)
    line_h = int(size * 1.45)
    per_col = -(-len(lines) // cols)
    col_w = (w * 0.86) / cols
    total_h = title_h + per_col * line_h
    y0 = (h - total_h) / 2

    if title:
        tf = font(title_size, bold=True)
        d.text((w / 2, y0), title, font=tf, fill=(255, 255, 255), anchor="ma")

    shadow = (0, 0, 0)
    for c in range(cols):
        chunk = lines[c * per_col:(c + 1) * per_col]
        cx = w * 0.07 + col_w * c + col_w / 2
        y = y0 + title_h
        for l in chunk:
            if l:
                d.text((cx + 1, y + 1), l, font=f, fill=shadow, anchor="ma")
                d.text((cx, y), l, font=f, fill=(235, 235, 240), anchor="ma")
            y += line_h

    img.save(out)

if __name__ == "__main__":
    main()
