# Variants

Each directory here is a **variant** — an actual buildable Quartus project combining one
[board](../boards/README.md)'s device/pin configuration with a specific top-level Verilog wrapper and
feature set. This is the level you build at: `make -C variants/<name>`.

## Contents of a variant directory

- `<name>.qpf` / `<name>.qsf` — the Quartus project and settings files. The `.qsf` typically `source`s
  the board's `general.tcl`/`files.tcl`/`pins.tcl`/`timing.sdc` from `../../boards/<board>/`.
- A top-level wrapper Verilog file (`hermeslite.v` for Hermes-Lite boards, `radioberry.v` for Radioberry
  boards) whose port list matches `hermeslite_core`/`radioberry_core` in `../rtl/`. This is where
  variant-specific parameters (e.g. which receiver count/bandwidth combination, which companion audio
  codec) get set when instantiating the core.
- `Makefile` — drives `quartus_sh --flow compile` and `quartus_cpf` to produce the programming files
  described in [`../README.md`](../README.md#loading-gateware-onto-the-radio).

## Variants

| Variant | Board | Notes |
|---|---|---|
| `hl2b2_main` | `hl2b2` | |
| `hl2b3to4_main`, `hl2b3to4_cicrx` | `hl2b3to4` | `_cicrx` = 10RX-only, CIC-filter-only receiver chain for multiband skimming |
| `hl2b5up_main` | `hl2b5up` | Main gateware for build5+ hardware; what most people use. 4 RX + 1 TX, CW/UART/ATU/fan control enabled |
| `hl2b5up_6rx` | `hl2b5up` | 6-receiver build |
| `hl2b5up_4000` | `hl2b5up` | Receive-only build (no TX/CW/UART/ATU/fan control) with 5 receivers, for monitoring/skimming use |
| `hl2b5up_cicrx` | `hl2b5up` | 10RX-only, CIC-filter-only build (see `_cicrx` above) |
| `hl2b5up_15ce` | `hl2b5up` | Built for the larger EP4CE15 device option |
| `hl2b5up_ak4951v3`, `hl2b5up_ak4951v4` | `hl2b5up` | AK4951 local-audio companion board support; v3 and v4 companion hardware are gateware-incompatible, use the matching variant |
| `hl2b5up_bypassversa` | `hl2b5up` | Bypasses the Versa5 clock generator |
| `radioberry_cl016`, `radioberry_cl025` | `radioberry` | SPI-linked Radioberry, 4 RX + 1 TX with CW; suffix is the target FPGA's logic-cell size |
| `radioberry_cl016_4000`, `radioberry_cl025_4000` | `radioberry` | As above but receive-only (no TX/CW), 6 receivers — same "_4000" pattern as `hl2b5up_4000` |
| `radioberry_pio_cl016`, `radioberry_pio_cl025` | `radioberry-pio` | PIO-linked Radioberry (RP1/Raspberry Pi 5) |
| `radioberry_juice_cl016`, `radioberry_juice_cl025` | `radioberry-juice` | Radioberry "Juice" (FTDI USB-FIFO host link) |
| `radioberry_juice_cl016_cicrx`, `radioberry_juice_cl025_cicrx` | `radioberry-juice` | CIC-only receiver build of the above |

The top-level `Makefile` in this directory has `all`, `release`, `radioberry`, `radioberry-juice`,
`clean`, and `realclean` targets that fan out to the relevant variants — see
[`../README.md`](../README.md#building).

## Adding a variant

Copy the closest existing variant directory, point its `.qsf` at the desired board under `../boards/`,
adjust the top-level wrapper's parameters, and add it to the appropriate target(s) in this directory's
`Makefile`.
