# Gateware

FPGA source for Hermes-Lite 2.x and its Radioberry companion boards, plus the per-board build
configuration and testbenches used to produce the `.rbf`/`.sof`/`.jic` files in `bitfiles/`.

All boards target Intel/Altera FPGAs (Cyclone IV E on the main Hermes-Lite board, Cyclone 10 LP on
Radioberry) and build with Quartus. `gateware/rtl/primitives/efinix/` exists for a possible future
Efinix target but is not currently wired into any board's build.

See [`../docs/HISTORY.md`](../docs/HISTORY.md) for how this architecture and the version numbering
below came about.

## Layout

- **`rtl/`** — shared Verilog source, used by every board. See [`rtl/README.md`](rtl/README.md).
- **`boards/<board>/`** — per-board Quartus settings, as **fragments** rather than full projects:
  `files.tcl` (which RTL files to compile), `pins.tcl`/`location*.tcl` (pin assignments), `general.tcl`
  (device family and global Quartus settings), `timing.sdc` (constraints). See
  [`boards/README.md`](boards/README.md).
- **`variants/<variant>/`** — an actual buildable Quartus project per board+feature combination, each
  with a `.qpf`/`.qsf` project, a top-level wrapper `.v` file, and a `Makefile`. See
  [`variants/README.md`](variants/README.md).
- **`bitfiles/`** — released bitstreams. `stable/` holds the current recommended release, `archive/`
  every prior dated/versioned release, and `testing/` is created locally by `make release_test`. Each
  release directory has its own `README.md` describing that release and how to load it (see below).
- **`sim/`** — myhdl/iverilog testbenches for individual RTL modules. See
  [`sim/README.md`](sim/README.md).

The firmware version (`VERSION_MAJOR`/`VERSION_MINOR`, reported to host software and used in release
directory naming) is a `localparam` near the top of `rtl/hermeslite_core.v`. It differs by board
(`BOARD==2` selects a different constant for Radioberry), so bump it there — not in a per-variant file
— when changing protocol/firmware version.

## Building

Requires Quartus tools (`quartus_sh`, `quartus_cpf`) on `PATH`.

```sh
# Build one variant
make -C variants/hl2b5up_main

# Build all variants
make -C variants

# Build only Radioberry variants
make -C variants radioberry
make -C variants radioberry-juice

# Clean build outputs / clean Quartus db+incremental_db for all variants
make -C variants clean
make -C variants realclean

# Cut an official release (requires a clean git tree; copies .rbf files into
# bitfiles/testing/<date>_<VERSION_MAJOR>p<VERSION_MINOR>_<gitrev>/)
make -C variants release_test
```

## Loading gateware onto the radio

Every build produces several output file types with different loading mechanisms; which ones exist for
a given release depends on that release's `README.md` under `bitfiles/`:

- **`.rbf` — network update (what almost everyone uses).** Raw binary format, loaded over Ethernet using
  the openHPSDR protocol's gateware-update mechanism. Any SDR application that supports Hermes-Lite
  gateware updates (Quisk, Thetis, SparkSDR, ...) can do this from its UI. It can also be done
  programmatically with `software/hermeslite/hermeslite.py`'s `HermesLite.update_gateware(filename)`
  (or `update_gateware_github(version)` to fetch a named release straight from `bitfiles/` in this
  repository) — the radio must be idle (not running) for this to work; the tool erases the existing
  program and streams the new one in over UDP port 1024. If a board is running gateware that predates
  network update support, update to a `_main` variant first, then to the desired variant.
- **`.sof` / `.jic` — JTAG via Quartus.** `.sof` is a volatile, FPGA-only image (`quartus_pgm`); `.jic`
  programs the board's nonvolatile configuration EEPROM. Used for initial bring-up or recovery when a
  board has no network-update-capable gateware yet, and requires a JTAG connection to the board.
- **`.svf`** — the same nonvolatile/volatile programming as `.jic`/`.sof`, but for non-Quartus JTAG
  tools such as urjtag or openocd.
- **`.jic.jam` / `.sof.jam`** — the same programming as `.jic`/`.sof`, played with a JAM/STAPL player
  instead of Quartus. Used by the Radioberry Raspberry Pi setup image.

For the full step-by-step procedure (recommended tools, JTAG wiring, troubleshooting) see the
[Updating Gateware wiki page](https://github.com/softerhardware/Hermes-Lite2/wiki/Updating-Gateware),
which is maintained outside this repository.

## Testing

See [`sim/README.md`](sim/README.md).
