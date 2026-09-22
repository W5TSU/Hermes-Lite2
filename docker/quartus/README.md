# Quartus Docker environment (Radioberry / Cyclone 10 LP)

A containerized Quartus Prime Lite 23.1 install, so `gateware/variants/radioberry_*` can be built
locally without installing Quartus on the host directly. Compile-only — no JTAG/USB passthrough for
programming physical hardware. Scope note: this covers the Radioberry (Cyclone 10 LP) variants only.
The main Hermes-Lite board variants (`hl2b2_main`, `hl2b3to4_*`, `hl2b5up_*`) target Cyclone IV E, which
needs the much older, harder-to-containerize Quartus II ~13.x and isn't covered here.

Version: 23.1std.1 Lite Edition — this matches `LAST_QUARTUS_VERSION` recorded in
`gateware/variants/radioberry_pio_cl016/radioberry.qsf` and `radioberry_pio_cl025/radioberry.qsf`,
the most recently-touched Radioberry variants. Quartus opens older-saved projects (the other
`radioberry_*` variants, on 20.1.1) without issue.

## Setup

1. **Download the installer** (manual — Intel requires an account and a EULA click-through):
   ```sh
   ./download-quartus.sh
   ```
   Walks you through it and stages the file(s) into `installers/` (gitignored — do not commit these,
   they're large and Intel-licensed).

2. **Build the image**:
   ```sh
   ./build.sh
   ```
   This actually runs the Quartus installer inside the Docker build, so it's slow and the resulting
   image is several GB. If the unattended-install step fails, see the note at the top of `Dockerfile` —
   the exact silent-install flags weren't verified against a real download at the time this was written.

3. **Compile a variant**:
   ```sh
   ./compile.sh radioberry_pio_cl016
   ```
   Mounts `../../gateware` into the container and runs that variant's `Makefile` through
   `quartus_sh --flow compile`, same as `make -C gateware/variants/<variant>` would on a host with
   Quartus installed natively. Output lands in `gateware/variants/<variant>/build/` same as always.

## Files

- `download-quartus.sh` — the wizard from step 1. Re-runnable; remembers values in `.env` (gitignored).
- `Dockerfile` — builds the image from whatever's staged in `installers/`.
- `build.sh` — builds the `hermes-lite-quartus` image, reading installer filenames from `.env`.
- `compile.sh <variant>` — runs a variant's build inside the image.
- `installers/`, `.env` — gitignored; local state from the download step.
