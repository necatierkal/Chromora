#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Chromora - Procedural Sound Effects Synthesizer
Generates clean, pleasant casual puzzle sound effects in 16-bit PCM WAV format.
Zero external copyright dependencies, 100% offline.
"""

import math
import os
import struct
import wave

def write_wav(filename, samples, sample_rate=44100):
    with wave.open(filename, 'w') as wav:
        wav.setnchannels(1) # Mono
        wav.setsampwidth(2) # 16-bit
        wav.setframerate(sample_rate)
        raw = bytearray()
        for s in samples:
            val = max(-1.0, min(1.0, s))
            int_val = int(val * 32767)
            raw.extend(struct.pack('<h', int_val))
        wav.writeframes(raw)

def synth_pop(duration=0.08, f_start=320, f_end=580, sample_rate=44100):
    samples = []
    total = int(duration * sample_rate)
    for i in range(total):
        t = i / sample_rate
        frac = i / total
        f = f_start + (f_end - f_start) * frac
        env = math.exp(-frac * 6.0)
        s = math.sin(2 * math.pi * f * t) * env * 0.7
        samples.append(s)
    return samples

def synth_tube_select(duration=0.06, f=440, sample_rate=44100):
    samples = []
    total = int(duration * sample_rate)
    for i in range(total):
        t = i / sample_rate
        frac = i / total
        env = (1.0 - frac) * math.exp(-frac * 4.0)
        s = (math.sin(2 * math.pi * f * t) + 0.3 * math.sin(2 * math.pi * f * 2.7 * t)) * env * 0.6
        samples.append(s)
    return samples

def synth_error_buzz(duration=0.15, f=130, sample_rate=44100):
    samples = []
    total = int(duration * sample_rate)
    for i in range(total):
        t = i / sample_rate
        frac = i / total
        env = 1.0 - frac
        # Square-ish wave for gentle buzz
        s = (1.0 if math.sin(2 * math.pi * f * t) > 0 else -1.0) * env * 0.3
        samples.append(s)
    return samples

def synth_level_win(duration=0.7, sample_rate=44100):
    samples = []
    total = int(duration * sample_rate)
    notes = [523.25, 659.25, 783.99, 1046.50] # C5, E5, G5, C6 arpeggio
    note_len = int(total / len(notes))
    for i in range(total):
        note_idx = min(i // note_len, len(notes) - 1)
        f = notes[note_idx]
        t = i / sample_rate
        note_frac = (i % note_len) / note_len
        env = math.exp(-note_frac * 3.5)
        s = (math.sin(2 * math.pi * f * t) + 0.25 * math.sin(2 * math.pi * f * 2 * t)) * env * 0.6
        samples.append(s)
    return samples

def synth_star_collect(duration=0.25, f=880, sample_rate=44100):
    samples = []
    total = int(duration * sample_rate)
    for i in range(total):
        t = i / sample_rate
        frac = i / total
        f_cur = f + 400 * frac
        env = math.exp(-frac * 5.0)
        s = (math.sin(2 * math.pi * f_cur * t) + 0.3 * math.sin(2 * math.pi * f_cur * 3 * t)) * env * 0.6
        samples.append(s)
    return samples

def synth_powerup(duration=0.2, f_start=300, f_end=800, sample_rate=44100):
    samples = []
    total = int(duration * sample_rate)
    for i in range(total):
        t = i / sample_rate
        frac = i / total
        f = f_start + (f_end - f_start) * (frac ** 0.5)
        env = (1.0 - frac)
        s = math.sin(2 * math.pi * f * t) * env * 0.5
        samples.append(s)
    return samples

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    audio_dir = os.path.join(base_dir, "assets", "audio")
    os.makedirs(audio_dir, exist_ok=True)

    print("Generating procedural audio assets...")
    write_wav(os.path.join(audio_dir, "tube_select.wav"), synth_tube_select())
    write_wav(os.path.join(audio_dir, "ball_move.wav"), synth_pop())
    write_wav(os.path.join(audio_dir, "invalid_buzz.wav"), synth_error_buzz())
    write_wav(os.path.join(audio_dir, "level_win.wav"), synth_level_win())
    write_wav(os.path.join(audio_dir, "star_collect.wav"), synth_star_collect())
    write_wav(os.path.join(audio_dir, "quest_complete.wav"), synth_level_win(duration=0.5))
    write_wav(os.path.join(audio_dir, "powerup.wav"), synth_powerup())
    print(f"Generated 7 crisp WAV sound effects in: {audio_dir}")

if __name__ == "__main__":
    main()
