# Sound effects and music

Everything here is made by `tools/sid_audio.py`, which renders it with a small software model of the
Commodore 64's MOS 6581 SID chip (`tools/sidsynth.py`). No samples and no outside audio are used.

The model has what gives the SID its sound: three voices, triangle / sawtooth / pulse (with pulse
width modulation) / noise waveforms, combined waveforms, the ADSR envelope, the resonant filter, and a
50 Hz driver tick that steps pitch, pulse width, vibrato and arpeggios the way C64 music drivers did.
The tracks use the usual tricks: a slow arpeggio standing in for a chord, and a soft triangle lead
over a long bass.

To change a sound, edit `tools/sid_audio.py` and run

    python3 tools/sid_audio.py sounds

It needs python3 with numpy, and `sox` for the OGG encoding. A render takes about ten seconds.

| Folder | Content |
|---|---|
| `sfx/` | 22 short effects, mapped to the game's diary events in `scripts/engine/Sfx.gd` |
| `music/` | `dungeon` (D minor), `cavern` (A minor) and `boss` (E minor): slow, soft and without drums, so they can run for a long time. They loop, the biome picks one |

Volumes are set in the options menu (Esc) and kept in `user://settings.cfg`.
