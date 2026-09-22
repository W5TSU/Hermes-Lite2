# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Hermes-Lite 2.x is a low-cost, open-source SDR (software-defined radio) HF transceiver built around
an AD9866 broadband modem chip, an FPGA, and the openHPSDR protocol. The repo contains everything
needed to build one: FPGA gateware (Verilog), KiCad hardware designs, and companion Python/C++
software. See `README.md` and http://www.hermeslite.com for background.

The repo has three largely independent top-level areas — most tasks touch only one:

- `gateware/` — Verilog FPGA source, per-board/per-variant build config, and myhdl/iverilog testbenches.
- `hardware/` — KiCad schematics/PCB layouts for the main board and companion boards, plus BOM tooling.
- `software/` — Host-side tools: a Python control module, an FT8 decoder pipeline, and a C++ USB/discovery setup utility.

## Gateware (`gateware/`)

### Architecture

- `rtl/` — shared Verilog source, organized by function: `ethernet/` (MAC/IP/UDP/ARP/DHCP/ICMP stack),
  `radio_openhpsdr1/` (CIC/CORDIC DSP receiver chains, including alternate `qs1r/` and `receiver2/`
  variants), `nco/` (NCO/sin-cos tables), `localaudio/` (AK4951 codec + sidetone), `radioberry/`
  (Raspberry Pi companion board core, with `pi-pio/` and `juice/` sub-variants), and `primitives/`
  (vendor-specific primitives: `intel/`, `efinix/`, `sim/`). `hermeslite_core.v` is the shared top-level
  core instantiated by every board.
- `boards/<board>/` — per-board Quartus settings as **fragments**, not full projects: `files.tcl`
  (which RTL files to compile), `pins.tcl`/`location*.tcl` (pin assignments), `general.tcl` (device family
  and global Quartus settings), `timing.sdc` (constraints), `configurable_io.tcl`. Boards: `hl2b2`,
  `hl2b3to4`, `hl2b5up` (main HL2 hardware revisions), `radioberry`, `radioberry-pio`, `radioberry-juice`,
  `radioberry-juice_b1` (Raspberry Pi companion boards).
- `variants/<variant>/` — an actual buildable Quartus project per board+feature combination (e.g.
  `hl2b5up_main`, `hl2b5up_6rx`, `hl2b5up_cicrx`, `hl2b5up_ak4951v3/v4`, `radioberry_cl016`,
  `radioberry_cl025`, `radioberry_pio_cl016/cl025`, `radioberry_juice_cl016/cl025`). Each contains a
  `.qpf`/`.qsf` project, a top-level `.v` wrapper (`hermeslite.v` or `radioberry.v`, matching the
  `module hermeslite_core`/`radioberry_core` port list) plus board pin config, and a `Makefile` that
  drives Quartus command-line tools. Naming encodes the FPGA size (`cl016`/`cl025` = target Intel
  Cyclone 10 LP logic-cell count for radioberry; a `_4000` suffix marks a receive-only variant — no
  TX/CW/UART/ATU/fan control — built for monitoring/skimming use).
- `bitfiles/stable/` and `bitfiles/archive/` — released `.rbf`/bitstream outputs, one dated+versioned
  directory per release. `bitfiles/testing/` is created by `make release_test`.
- `sim/` — myhdl-based testbenches (`test_*.py`) that generate Verilog test harnesses around individual
  RTL modules (CORDIC, mixers, I2C, NCO, receiver chains, slow ADC) and drive them with `iverilog`.

### Build commands

Requires Quartus tools (`quartus_sh`, `quartus_cpf`) on `PATH`.

```sh
# Build one variant
make -C gateware/variants/hl2b5up_main

# Build all variants
make -C gateware/variants

# Build only radioberry (Raspberry Pi companion) variants
make -C gateware/variants radioberry
make -C gateware/variants radioberry-juice

# Clean build outputs / clean Quartus db+incremental_db for all variants
make -C gateware/variants clean
make -C gateware/variants realclean

# Cut an official release (requires a clean git tree; copies .rbf files into
# bitfiles/testing/<date>_<VERSION_MAJOR>p<VERSION_MINOR>_<gitrev>/)
make -C gateware/variants release_test
```

The firmware version (`VERSION_MAJOR`/`VERSION_MINOR`, shown to host software and used in release
directory naming) is defined as `localparam` near the top of `gateware/rtl/hermeslite_core.v`.
`VERSION_MAJOR` differs by board (`BOARD==2` selects a different constant), so bump it there — not in
a per-variant file — when changing protocol/firmware version.

### Simulation / testing

Testbenches use `myhdl` + `iverilog` (and `scipy`/`numpy` for spectral checks in some tests).

```sh
cd gateware/sim
python3 test_cordic.py        # run one testbench
make                          # runs test_cordic via Makefile
make clean                    # remove generated .vvp/.lxt/.fst/.v/pycache
```

Other testbenches (`test_mix1.py`, `test_mixtx1.py`, `test_nco1.py`, `test_rx1.py`, `test_rx2.py`,
`test_rx2IQ.py`, `test_sincos.py`, `test_i2c_bus2.py`, `test_cpl_cordic.py`, `test_slow_adc.py`) are run
directly with `python3 <file>.py`; there is no aggregate "run all tests" target.

## Hardware (`hardware/`)

KiCad projects (schematic `.sch`/`.pro`, PCB `.kicad_pcb`) — open with KiCad, not text-editable in any
meaningful way. `hardware/hl/` is the main Hermes-Lite board; `hardware/companions/` holds add-on boards
(`db9`, `io`, `io_jumper`, `n2adr`, `n2adr_jumper`, `psfeedback`, `smallio`), each with its own release
history under `releases/`. `hardware/hl/bom/` has Python scripts (`BOM.py`, `mkassemblybom.py`,
`mkstandardbom.py`, `mkassemblycsv.py`, `updateprices.py`) that generate BOM PDFs/spreadsheets from
`parts.json` and `octopart.db`; these are the only hardware-adjacent files a text-based edit is likely to
touch.

## Software (`software/`)

- `software/hermeslite/` — `hermeslite.py`, a standalone Python module for direct command/control of a
  Hermes-Lite 2.0 over UDP port 1025 (alongside, not instead of, normal SDR software), used interactively
  (`python3 -i hermeslite.py`) or via the included `hermeslite.ipynb` Jupyter notebook. Depends on
  `netifaces` (or `netifaces-plus` on newer Windows/Python) to enumerate local interfaces when
  discovering devices — see `software/hermeslite/README.md` for install specifics. `debug.py` +
  `VCDWriter.py` are for capturing/inspecting protocol traffic as VCD waveforms.
- `software/ft8/` — Python FT8 decode pipeline (`ft8.py`, `ft8_worker.py`, `collector.py`, `rx4000.py`,
  `hl2zmq.py`, `maidenhead.py`); `hl2zmq.py` bridges Hermes-Lite IQ streams to ZeroMQ for the decoder
  workers.
- `software/hl2setup/` — C++ utility (`hl2setup.cxx`, `hl2.cxx`/`.h`, `discover.cxx`) for discovering and
  provisioning Hermes-Lite units on the network. Build with the provided `Makefile` (Linux) or
  `Makefile.mingw` (Windows cross-build).

## Conventions

- Gateware, hardware, and software each have independent versioning/release cadences reflected in their
  own `releases`/`bitfiles` subdirectories — don't assume a change in one area implies a version bump in
  another.
- `hardware/hl/bom/*`, `hardware/hl/libs/*`, `hardware/hl/releases/*`, `hardware/hl/gerber/*`,
  `hardware/companions/*`, and `gateware/bitfiles/*` are marked `linguist-vendored` in `.gitattributes`
  (generated/vendored artifacts, not hand-maintained source).
- `docs/` is a built Sphinx/GitHub Pages site (served at hermeslite.com via `docs/CNAME`) — its HTML is
  generated output, not a source of truth to edit directly.

## Agent skills

### Issue tracker

Issues live as GitHub issues in `W5TSU/Hermes-Lite2`, managed via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root (created lazily by `/domain-modeling`). See `docs/agents/domain.md`.
