#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Chromora - Procedural Ambient Puzzle Music Generator
Generates a seamless, calming, lo-fi pentatonic puzzle track in 16-bit PCM WAV.
Zero external copyright dependencies, 100% packaged offline.
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

def synth_note(freq, duration, sample_rate=44100, amp=0.25):
    total = int(duration * sample_rate)
    samples = []
    for i in range(total):
        t = i / sample_rate
        # Warm rhodes / electric piano harmonic blend
        env = math.exp(-t * 2.8)
        s = (
            math.sin(2 * math.pi * freq * t) * 0.7 +
            math.sin(2 * math.pi * freq * 2 * t) * 0.2 +
            math.sin(2 * math.pi * freq * 3 * t) * 0.1
        ) * env * amp
        samples.append(s)
    return samples

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    audio_dir = os.path.join(base_dir, "assets", "audio")
    os.makedirs(audio_dir, exist_ok=True)

    sample_rate = 44100
    bpm = 80
    beat_dur = 60.0 / bpm # 0.75s per beat
    total_beats = 16 # 12.0 seconds total loop
    total_samples = int(total_beats * beat_dur * sample_rate)
    buffer = [0.0] * total_samples

    # Pentatonic melody in F major / D minor: F4 (349.23), G4 (392.00), A4 (440.00), C5 (523.25), D5 (587.33)
    # Bass: F2 (87.31), C3 (130.81), D2 (73.42), A2 (110.00)
    melody_events = [
        # (beat_start, freq, duration, amp)
        # Bar 1 (F)
        (0.0, 87.31, beat_dur * 3.5, 0.35), # Bass F2
        (0.0, 349.23, beat_dur * 1.8, 0.18), # F4
        (1.0, 440.00, beat_dur * 1.5, 0.16), # A4
        (2.0, 523.25, beat_dur * 2.0, 0.15), # C5
        (3.0, 392.00, beat_dur * 1.0, 0.14), # G4
        # Bar 2 (C)
        (4.0, 130.81, beat_dur * 3.5, 0.35), # Bass C3
        (4.0, 523.25, beat_dur * 1.8, 0.16), # C5
        (5.0, 440.00, beat_dur * 1.5, 0.15), # A4
        (6.0, 392.00, beat_dur * 1.8, 0.14), # G4
        (7.0, 349.23, beat_dur * 1.2, 0.13), # F4
        # Bar 3 (Dm)
        (8.0, 73.42, beat_dur * 3.5, 0.35), # Bass D2
        (8.0, 587.33, beat_dur * 2.0, 0.16), # D5
        (9.0, 523.25, beat_dur * 1.5, 0.15), # C5
        (10.0, 440.00, beat_dur * 1.8, 0.16), # A4
        (11.0, 523.25, beat_dur * 1.2, 0.14), # C5
        # Bar 4 (Bb / A)
        (12.0, 110.00, beat_dur * 3.5, 0.35), # Bass A2
        (12.0, 440.00, beat_dur * 1.8, 0.16), # A4
        (13.0, 392.00, beat_dur * 1.5, 0.15), # G4
        (14.0, 349.23, beat_dur * 2.0, 0.18), # F4
        (15.0, 392.00, beat_dur * 1.2, 0.14), # G4
    ]

    for start_beat, freq, dur, amp in melody_events:
        start_idx = int(start_beat * beat_dur * sample_rate)
        note_samples = synth_note(freq, dur, sample_rate, amp)
        for i, s in enumerate(note_samples):
            target_idx = (start_idx + i) % total_samples
            buffer[target_idx] += s

    # Gentle ambient chord pad underlying loop
    pad_freqs = [174.61, 220.00, 261.63] # F3, A3, C4 chord
    for i in range(total_samples):
        t = i / sample_rate
        pad_s = 0.0
        for pf in pad_freqs:
            pad_s += math.sin(2 * math.pi * pf * t)
        buffer[i] += pad_s * 0.035

    out_file = os.path.join(audio_dir, "bgm_ambient.wav")
    write_wav(out_file, buffer, sample_rate)
    print(f"Generated calming background music: {out_file} ({len(buffer)/sample_rate:.1f}s loop)")

if __name__ == "__main__":
    main()
