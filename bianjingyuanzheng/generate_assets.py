#!/usr/bin/env python3
"""Generate better placeholder PNG assets for the Godot game."""

import struct
import zlib
import os

def create_png(width, height, pixels):
    """Create a PNG file from raw RGBA pixel data."""
    raw_data = b""
    for y in range(height):
        raw_data += b"\x00"
        row_start = y * width * 4
        row_end = row_start + width * 4
        raw_data += bytes(pixels[row_start:row_end])

    def make_chunk(chunk_type, data):
        chunk = chunk_type + data
        crc = struct.pack(">I", zlib.crc32(chunk) & 0xFFFFFFFF)
        return struct.pack(">I", len(data)) + chunk + crc

    signature = b"\x89PNG\r\n\x1a\n"
    ihdr_data = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    ihdr = make_chunk(b"IHDR", ihdr_data)
    compressed = zlib.compress(raw_data)
    idat = make_chunk(b"IDAT", compressed)
    iend = make_chunk(b"IEND", b"")
    return signature + ihdr + idat + iend


def set_pixel(pixels, x, y, img_width, r, g, b, a=255):
    """Set a pixel at (x,y) in the pixel array."""
    idx = (y * img_width + x) * 4
    pixels[idx] = r
    pixels[idx+1] = g
    pixels[idx+2] = b
    pixels[idx+3] = a


def fill_rect(pixels, x, y, w, h, pw, img_width, r, g, b, a=255, br=255, bg=255, bl=255, ba=255):
    """Draw a filled rectangle with border."""
    # Border
    for bx in range(w):
        for by in range(pw):
            set_pixel(pixels, x+bx, y+by, img_width, br, bg, bl, ba)
            set_pixel(pixels, x+bx, y+h-1-by, img_width, br, bg, bl, ba)
    for by in range(h):
        for bx in range(pw):
            set_pixel(pixels, x+bx, y+by, img_width, br, bg, bl, ba)
            set_pixel(pixels, x+w-1-bx, y+by, img_width, br, bg, bl, ba)
    # Fill
    for fy in range(y+pw, y+h-pw):
        for fx in range(x+pw, x+w-pw):
            set_pixel(pixels, fx, fy, img_width, r, g, b, a)


def draw_rect(pixels, x, y, w, h, pw, img_width, r, g, b, a=255):
    """Draw a rectangle border."""
    for bx in range(w):
        for by in range(pw):
            set_pixel(pixels, x+bx, y+by, img_width, r, g, b, a)
            set_pixel(pixels, x+bx, y+h-1-by, img_width, r, g, b, a)
    for by in range(h):
        for bx in range(pw):
            set_pixel(pixels, x+bx, y+by, img_width, r, g, b, a)
            set_pixel(pixels, x+w-1-bx, y+by, img_width, r, g, b, a)


def draw_triangle_up(pixels, cx, cy, size, pw, img_width, r, g, b, a=255, br=255, bg=255, bl=255, ba=255):
    """Draw an upward-pointing triangle centered at (cx, cy)."""
    half = size // 2
    for row in range(size):
        row_y = cy - half + row
        line_half = int(row * half / size)
        for col in range(-line_half, line_half + 1):
            px, py = cx + col, row_y
            # Check if this pixel is on the edge
            dist_to_edge = line_half - abs(col)
            if dist_to_edge < pw and (abs(col) == line_half or row <= pw or row >= size - pw):
                set_pixel(pixels, px, py, img_width, br, bg, bl, ba)
            else:
                set_pixel(pixels, px, py, img_width, r, g, b, a)


def draw_circle(pixels, cx, cy, radius, pw, img_width, r, g, b, a=255, br=255, bg=255, bl=255, ba=255):
    """Draw a filled circle with border."""
    for dy in range(-radius, radius+1):
        for dx in range(-radius, radius+1):
            dist = (dx*dx + dy*dy) ** 0.5
            if dist <= radius:
                px, py = cx + dx, cy + dy
                if dist > radius - pw:
                    set_pixel(pixels, px, py, img_width, br, bg, bl, ba)
                else:
                    set_pixel(pixels, px, py, img_width, r, g, b, a)


def draw_diamond(pixels, cx, cy, size, pw, img_width, r, g, b, a=255, br=255, bg=255, bl=255, ba=255):
    """Draw a filled diamond shape with border."""
    half = size // 2
    for dy in range(-half, half+1):
        line_half = half - abs(dy)
        for dx in range(-line_half, line_half+1):
            px, py = cx + dx, cy + dy
            if abs(dx) == line_half or abs(dy) == half:
                set_pixel(pixels, px, py, img_width, br, bg, bl, ba)
            else:
                set_pixel(pixels, px, py, img_width, r, g, b, a)


def draw_star_4(pixels, cx, cy, size, pw, img_width, r, g, b, a=255, br=255, bg=255, bl=255, ba=255):
    """Draw a 4-pointed star."""
    half = size // 2
    for dy in range(-half, half+1):
        for dx in range(-half, half+1):
            nx, ny = abs(dx), abs(dy)
            # Star condition: points along axes, tapered toward diagonals
            star_val = max(0, half - (nx + ny))
            if star_val > 0:
                # Check border - any neighbor outside the star
                is_border = False
                for cdx in [-1, 0, 1]:
                    for cdy in [-1, 0, 1]:
                        if cdx == 0 and cdy == 0:
                            continue
                        nnx, nny = abs(dx + cdx), abs(dy + cdy)
                        if max(0, half - (nnx + nny)) == 0:
                            is_border = True
                if is_border:
                    set_pixel(pixels, cx+dx, cy+dy, img_width, br, bg, bl, ba)
                else:
                    set_pixel(pixels, cx+dx, cy+dy, img_width, r, g, b, a)


def draw_M(pixels, cx, cy, img_width, r, g, b, a=255):
    """Draw a simple 'M' letter at (cx, cy) using pixels."""
    # 5x5 M
    letter = [
        0b10001,
        0b11011,
        0b10101,
        0b10001,
        0b10001,
    ]
    for row in range(5):
        for col in range(5):
            if letter[row] & (1 << (4-col)):
                px = cx - 2 + col
                py = cy - 2 + row
                set_pixel(pixels, px, py, img_width, r, g, b, a)


def generate_actor_sheet():
    """Generate actor_32x32.png (128x32, 4 frames of 32x32)."""
    frame_w = 32
    frame_h = 32
    num_frames = 4
    width = frame_w * num_frames
    height = frame_h
    pixels = [0] * (width * height * 4)
    pw = 2  # border width
    cx = frame_w // 2
    cy = frame_h // 2

    # Frame 0: Player - Blue upward triangle
    draw_triangle_up(pixels, cx, cy, 22, pw, width,
                     50, 130, 255, 255,    # fill: blue
                     100, 200, 255, 255)   # border: light blue

    # Frame 1: Normal monster - Red circle with "M"
    draw_circle(pixels, cx + frame_w * 1, cy, 13, pw, width,
                220, 40, 40, 255,     # fill: red
                255, 150, 50, 255)     # border: orange-red
    draw_M(pixels, cx + frame_w * 1, cy, width, 255, 255, 255)

    # Frame 2: Elite monster - Orange diamond
    draw_diamond(pixels, cx + frame_w * 2, cy, 22, pw, width,
                 255, 160, 0, 255,     # fill: orange
                 255, 220, 80, 255)    # border: yellow

    # Frame 3: BOSS monster - Purple 4-pointed star
    draw_star_4(pixels, cx + frame_w * 3, cy, 26, pw, width,
                160, 20, 200, 255,    # fill: purple
                220, 120, 255, 255)   # border: light purple

    return create_png(width, height, pixels)


def generate_tile_sheet():
    """Generate tile_32x32.png (64x64, 4 tiles of 32x32)."""
    tw = 32
    th = 32
    width = tw * 2
    height = th * 2
    pixels = [0] * (width * height * 4)

    # Tile 0 (0,0): Stone floor
    for y in range(th):
        for x in range(tw):
            n = ((x * 7 + y * 13 + x * y * 3) % 5) * 10
            set_pixel(pixels, x, y, width,
                      120 + n, 90 + n, 60 + n)
    draw_rect(pixels, 0, 0, tw, th, 1, width, 50, 40, 30)

    # Tile 1 (32,0): Lava floor
    for y in range(th):
        for x in range(tw):
            if (x % 8 < 3 and y % 8 < 3):
                n = ((x * 3 + y * 7) % 4) * 12
                set_pixel(pixels, x + tw, y, width, 180 + n, 60 + n, 10)
            else:
                n = ((x * 11 + y * 5) % 3) * 20
                set_pixel(pixels, x + tw, y, width, 50 + n, 25 + n, 20 + n)
    draw_rect(pixels, tw, 0, tw, th, 1, width, 80, 30, 10)

    # Tile 2 (0,32): Grass floor
    for y in range(th):
        for x in range(tw):
            n = ((x * 5 + y * 17) % 4) * 10
            set_pixel(pixels, x, y + th, width, 30 + n//2, 100 + n, 25 + n//3)
    draw_rect(pixels, 0, th, tw, th, 1, width, 20, 60, 15)

    # Tile 3 (32,32): Snow/ice floor
    for y in range(th):
        for x in range(tw):
            n = ((x * 9 + y * 11) % 5) * 4
            set_pixel(pixels, x + tw, y + th, width, 200 + n, 210 + n, 230 + n)
    draw_rect(pixels, tw, th, tw, th, 1, width, 140, 150, 170)

    return create_png(width, height, pixels)


def generate_icon_sheet():
    """Generate icon_32x32.png (32x32)."""
    width = 32
    height = 32
    pixels = [0] * (width * height * 4)

    # Coin icon
    draw_circle(pixels, 16, 16, 14, 2, width,
                255, 215, 0, 255,
                255, 180, 0, 255)
    draw_circle(pixels, 16, 16, 9, 1, width,
                255, 200, 0, 255,
                200, 150, 0, 255)

    return create_png(width, height, pixels)


def main():
    output_dir = "/Users/moly/godot_projects/vibejam2026/bianjingyuanzheng/assets/placeholder/"
    os.makedirs(output_dir, exist_ok=True)

    actor_png = generate_actor_sheet()
    with open(os.path.join(output_dir, "actor_32x32.png"), "wb") as f:
        f.write(actor_png)
    print(f"Generated actor_32x32.png ({len(actor_png)} bytes)")

    tile_png = generate_tile_sheet()
    with open(os.path.join(output_dir, "tile_32x32.png"), "wb") as f:
        f.write(tile_png)
    print(f"Generated tile_32x32.png ({len(tile_png)} bytes)")

    icon_png = generate_icon_sheet()
    with open(os.path.join(output_dir, "icon_32x32.png"), "wb") as f:
        f.write(icon_png)
    print(f"Generated icon_32x32.png ({len(icon_png)} bytes)")

    print("\nAll assets generated successfully!")


if __name__ == "__main__":
    main()
