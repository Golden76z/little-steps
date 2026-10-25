#!/usr/bin/env python3
"""Synthesises the app's three feedback sounds into assets/sounds/.

Soft sines in C major (fundamental plus a quiet octave), each note with a
raised-cosine attack and an exponential fade that ends on silence, so there
is no click. Mono, 44.1 kHz, 16-bit, peak at -12 dBFS. Stdlib only:

    python3 tool/make_sounds.py
"""

import math
import os
import struct
import wave

RATE = 44100
PEAK = 10 ** (-12 / 20)  # -12 dBFS
C5, E5, G5, C6 = 523.25, 659.26, 783.99, 1046.50

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sounds')


def note(buf, start, freq, length, attack=0.008, gain=1.0):
    """Adds one note to buf: start and length in seconds."""
    first = int(start * RATE)
    count = min(int(length * RATE), len(buf) - first)
    for i in range(count):
        t = i / RATE
        env = 0.5 - 0.5 * math.cos(math.pi * t / attack) if t < attack else 1.0
        env *= math.exp(-5 * t / length)
        env *= 1 - (i / count) ** 8  # lands exactly on zero
        s = math.sin(2 * math.pi * freq * t) + 0.18 * math.sin(4 * math.pi * freq * t)
        buf[first + i] += gain * env * s


def render(name, length, notes):
    buf = [0.0] * int(length * RATE)
    for args in notes:
        note(buf, *args)
    top = max(abs(x) for x in buf)
    frames = b''.join(
        struct.pack('<h', round(x / top * PEAK * 32767)) for x in buf
    )
    with wave.open(os.path.join(OUT, f'{name}.wav'), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(frames)


def main():
    os.makedirs(OUT, exist_ok=True)
    # +1 step: one short, round note.
    render('pop', 0.12, [(0, G5, 0.12, 0.006)])
    # Habit done: two rising notes.
    render('done', 0.35, [(0, E5, 0.16), (0.11, C6, 0.24)])
    # Celebration: a small arpeggio, the last note left to ring.
    render('celebrate', 0.9, [
        (0.00, C5, 0.30, 0.008, 0.8),
        (0.09, E5, 0.30, 0.008, 0.8),
        (0.18, G5, 0.30, 0.008, 0.9),
        (0.27, C6, 0.63, 0.008, 1.0),
    ])


if __name__ == '__main__':
    main()
