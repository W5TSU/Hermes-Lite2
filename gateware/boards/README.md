# Boards

Each directory here is a **board** — a set of Quartus TCL/SDC fragments describing one piece of
physical hardware's FPGA device, pins, and global settings. A board directory is *not* a buildable
Quartus project by itself; it's included by one or more projects under [`../variants/`](../variants/README.md)
that pick a top-level Verilog file and pull in a board's `files.tcl`/`pins.tcl`/`general.tcl`/`timing.sdc`.

This split exists because the same board can run more than one feature combination (e.g. `hl2b5up` runs
`hl2b5up_main`, `hl2b5up_6rx`, `hl2b5up_cicrx`, and the AK4951 audio-companion variants), and the same
RTL and pin mapping shouldn't be duplicated per variant.

## Boards

| Directory | Hardware | Notes |
|---|---|---|
| `hl2b2` | Hermes-Lite 2.0 beta2 | First public revision |
| `hl2b3to4` | Hermes-Lite 2.0 beta3/beta4 | Shares gateware/pins between the two hardware revisions |
| `hl2b5up` | Hermes-Lite 2.0 build5 and later | Current mainline hardware; most active variants target this board |
| `radioberry` | Radioberry (SPI link to Raspberry Pi) | FPGA companion for a Raspberry Pi, talks to the Pi over SPI |
| `radioberry-pio` | Radioberry (PIO link, RP1/RPi5) | Same FPGA hardware as `radioberry`, but uses the RP1/Raspberry Pi 5 PIO peripheral instead of SPI |
| `radioberry-juice` / `radioberry-juice_b1` | Radioberry "Juice" | FTDI USB-FIFO host link instead of a Raspberry Pi; runs the full openHPSDR protocol packer on-board |

See [`../../docs/HISTORY.md`](../../docs/HISTORY.md) for how these hardware revisions relate to the
releases under `hardware/hl/releases/` and to Radioberry's origin.

## Fragment files

A board directory typically contains:

- `general.tcl` — `FAMILY`/`DEVICE` and other global Quartus assignments common to every variant built
  against this board.
- `files.tcl` — the list of RTL source files (from `../rtl/`) to compile. Different variants of the same
  board may use different `files.tcl`s (or override entries) to swap in alternate RTL, e.g. a CIC-only
  receiver chain.
- `pins.tcl` and, where present, `location*.tcl`/`configurable_io.tcl` — physical pin assignments.
- `veth_2p5.tcl` / `vlvds_2p5.tcl` — I/O standard assignments for the Ethernet/LVDS pins at particular
  voltage levels.
- `timing.sdc` — Quartus TimeQuest timing constraints (clocks, false paths, multicycle paths).

## Adding a board

Copy the closest existing board directory as a starting point, update `general.tcl` for the target
device and `pins.tcl`/`timing.sdc` for the new pinout, then create a variant under
[`../variants/`](../variants/README.md) that references it.
