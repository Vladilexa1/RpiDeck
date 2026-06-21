#!/usr/bin/env python3
"""Тест BlackPill геймпада: показывает оси и кнопки, отмечает протестированные."""
import serial
import sys
import time

PORT = "/dev/ttyAMA0"
BAUD = 115200
NUM_BTN = 15
BTN_PINS = ["PB1", "PB0", "PA7", "PA6", "PA5",
            "PB3", "PB4", "PB5", "PB12", "PB13",
            "PB9", "PB8", "PB7", "PB6", "PA15"]

REFRESH = 1.0 / 30  # 30 Гц для UI, чтобы не моргало

CLR = "\033[2J\033[H"
HIDE = "\033[?25l"
SHOW = "\033[?25h"
B = "\033[1m"
G = "\033[32m"
Y = "\033[33m"
D = "\033[2m"
R = "\033[0m"


def bar(v, width=21, vmax=2048):
    half = width // 2
    pos = max(-half, min(half, int(v / vmax * half)))
    cells = ["·"] * width
    cells[half] = "|"
    if pos > 0:
        for i in range(half + 1, half + 1 + pos):
            cells[i] = "█"
    elif pos < 0:
        for i in range(half + pos, half):
            cells[i] = "█"
    return "[" + "".join(cells) + "]"


def render(lx, ly, rx, ry, btns, tested, bad):
    out = [CLR + B + "BlackPill Gamepad — тест" + R]
    out.append(f"{D}Порт: {PORT} @ {BAUD}   Ctrl+C — выход   битых строк: {bad}{R}")
    out.append("")
    out.append(B + "Стики (±2048 от центра):" + R)
    out.append(f"  LX  {bar(lx)}  {lx:+5d}")
    out.append(f"  LY  {bar(ly)}  {ly:+5d}")
    out.append(f"  RX  {bar(rx)}  {rx:+5d}")
    out.append(f"  RY  {bar(ry)}  {ry:+5d}")
    out.append("")
    out.append(B + "Кнопки  (● = нажата сейчас,  ✓ = уже была нажата):" + R)
    for i in range(NUM_BTN):
        now = f"{G}●{R}" if btns[i] else f"{D}○{R}"
        done = f"{G}✓{R}" if tested[i] else f"{D}·{R}"
        out.append(f"  {now}  btn{i:02d}  {BTN_PINS[i]:<5}  {done}")
    out.append("")
    left = [i for i, t in enumerate(tested) if not t]
    if left:
        names = ", ".join(f"btn{i}({BTN_PINS[i]})" for i in left)
        out.append(f"{Y}Осталось: {names}{R}")
    else:
        out.append(f"{G}{B}✓ Все 12 кнопок протестированы!{R}")
    sys.stdout.write("\n".join(out) + "\n")
    sys.stdout.flush()


def main():
    try:
        ser = serial.Serial(PORT, BAUD, timeout=1)
    except serial.SerialException as e:
        print(f"Не удалось открыть {PORT}: {e}")
        sys.exit(1)

    tested = [False] * NUM_BTN
    last = (0, 0, 0, 0, [0] * NUM_BTN)
    bad = 0
    last_draw = 0.0
    sys.stdout.write(HIDE)

    try:
        while True:
            line = ser.readline().decode("ascii", errors="ignore").strip()
            if line:
                parts = line.split(",")
                if len(parts) == 4 + NUM_BTN:
                    try:
                        vals = [int(p) for p in parts]
                        lx, ly, rx, ry = vals[:4]
                        btns = vals[4:]
                        for i, b in enumerate(btns):
                            if b:
                                tested[i] = True
                        last = (lx, ly, rx, ry, btns)
                    except ValueError:
                        bad += 1
                else:
                    bad += 1

            now = time.monotonic()
            if now - last_draw >= REFRESH:
                render(*last, tested, bad)
                last_draw = now
    except KeyboardInterrupt:
        pass
    finally:
        sys.stdout.write(SHOW)
        sys.stdout.flush()
        ser.close()


if __name__ == "__main__":
    main()
