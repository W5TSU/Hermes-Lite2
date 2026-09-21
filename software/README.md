# Software

Host-side tools for working with a Hermes-Lite radio. None of these are required to use a Hermes-Lite —
most users drive it entirely from third-party SDR software (Quisk, Thetis/PowerSDR, SparkSDR, etc.)
speaking openHPSDR protocol 1 over Ethernet. These tools cover things that software doesn't: scripted
control, decode pipelines, and initial setup/diagnostics.

- **[`hermeslite/`](hermeslite/README.md)** — `hermeslite.py`, a standalone Python module for direct
  command/control of a radio (clock configuration, multi-radio sync, TX buffer tuning, gateware
  updates), usable interactively or from a Jupyter notebook, alongside normal SDR software.
- **[`ft8/`](ft8/README.md)** — a multi-worker FT8 decode pipeline built around ZeroMQ and a Fortran FT8
  decoder, for skimming FT8 activity directly from a Hermes-Lite's receive stream.
- **[`hl2setup/`](hl2setup/README.md)** — an FLTK-based C++ GUI for discovering a radio on the network
  and running setup/diagnostic routines (bias, power flatness) on it.
