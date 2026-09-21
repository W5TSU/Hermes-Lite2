# History of Hermes-Lite

This document traces Hermes-Lite's lineage from the openHPSDR project through
Hermes-Lite 1.x to the current Hermes-Lite 2.x, and summarizes how the
gateware, hardware, and software in this repository evolved. Dates and facts
below are drawn from this repository's git history and release directories,
from the [Hermes-Lite2 wiki](https://github.com/softerhardware/Hermes-Lite2/wiki),
and from the openHPSDR project's own site, archived at the Internet Archive
since openhpsdr.org is no longer online (see **Sources** at the bottom).

## Origins: openHPSDR and Hermes (2006–2013)

[openHPSDR](https://web.archive.org/web/20250417152647/https://openhpsdr.org/)
("High Performance Software Defined Radio") was an open-source hardware and
software project for amateur radio, hosted with support from
[TAPR](http://www.tapr.org/) (Tucson Amateur Packet Radio) starting around
2006. Rather than building one fixed radio, the project defined a modular bus
architecture: separate boards for the backplane (Atlas), receiver (Mercury),
transmitter (Penelope/PennyLane), USB/Ethernet interface (Ozy/Metis), filters
(Alex), and so on, each connected through a common connector so experimenters
could mix and match modules. PowerSDR and the ghpsdr family were the
reference host applications.

[Hermes](https://web.archive.org/web/20250417152647/https://openhpsdr.org/hermes.php)
began in 2009 as a proposal by Kevin, M0KHZ, the module's project lead: having
studied the Verilog for both Mercury (receive) and Penelope (transmit), he
merged their logic into a single FPGA on a single Euro-card-sized (100 x 160
mm) board, aiming to replace several separate HPSDR boards with one. Hermes
originally planned USB2 connectivity; in August 2010 the project switched to
an Ethernet PHY instead, which became a defining feature of every board
descended from it, including Hermes-Lite. The protocol this produced — UDP
frames of packed I/Q and control data — is what this repository's gateware
still refers to as "openHPSDR protocol 1" (see `gateware/rtl/dsopenhpsdr1.v`
and `usopenhpsdr1.v`), and what `gateware/rtl/sync.v`/`cdc_sync.v` still credit
to "HPSDR" in their file headers. Hermes was sold as a kit through TAPR and
later through Apache Labs.

## Hermes-Lite 1.x (2014–2016)

Hermes-Lite began as an effort to make an Hermes-class radio affordable to
build at home, without a run of custom PCB fab and assembly. Roughly 100
Hermes-Lite 1.x units were built by experimenters starting in 2014. Because
FPGAs were harder to hand-solder economically at the time, Hermes-Lite 1.x
was built around a commodity BeMicro SDK/CV/CVA9 FPGA development card plus a
companion RF front-end board, keeping the expensive part (the FPGA and its
board-bring-up) off the shelf. That project is now archived and deprecated in
favor of Hermes-Lite 2.x; see its
[wiki](https://github.com/softerhardware/Hermes-Lite/wiki) and
[repository](https://github.com/softerhardware/Hermes-Lite).

## Hermes-Lite 2.x: this repository (2016–present)

This repository begins with its "Initial commit" on 2016-11-23, alongside the
first hardware for what became the `hl2p0beta2` release — the board named
"beta2" in `hardware/hl/releases/`. The goal of 2.x was to go a step further
than 1.x: put the FPGA, the Ethernet PHY, and the AD9866 broadband modem chip
all on one small, low-cost board, removing the separate FPGA carrier card
entirely. Early commits (December 2016 – January 2017) bring up Ethernet and
LEDs on real hardware, and the first working receive path lands
2017-01-17 ("Initial firmware with RX working"), with transmit following
shortly after.

### Hardware revisions

The board went through several major hardware revisions, each recorded under
`hardware/hl/releases/` and each with its own gateware "board" directory
under `gateware/boards/`:

| Hardware release(s) | Gateware board directory | Notes |
|---|---|---|
| `hl2p0beta2` | `hl2b2` | First public design, late 2016 |
| `hl2p0beta3`, `hl2p0beta4` | `hl2b3to4` | Shared gateware/pin config |
| `hl2p0beta5` through `hl2p0build9` | `hl2b5up` | "build5 and up"; current mainline hardware, produced across several group-buy runs (`build6`–`build9`) |

The `hl2b2`/`hl2b3to4`/`hl2b5up` split still shapes the gateware layout today
— see `gateware/README.md` and `gateware/boards/README.md`.

### Gateware architecture and versioning

The gateware was originally a single flat project per board. The 2019-10-19
commit "Refactor to add hermeslite_core with wrappers" introduced the
`hermeslite_core.v` shared core plus the current `boards/` (pin/device
config) and `variants/` (buildable project) split described in
`gateware/README.md` — the architecture every board and variant still follows.

Firmware version numbers are embedded directly in `hermeslite_core.v` as
`VERSION_MAJOR`/`VERSION_MINOR` and stamped into every release directory name
under `gateware/bitfiles/`. The archived releases there span
`20200119_69p0` (January 2020) through the `74p2` stable release
(December 2023), with development past `75.x` ongoing in `master` and not
yet archived as a numbered release.

### Companion boards and Radioberry

Over time, companion hardware was added around the core radio:

- Audio/ATU/amplifier companions (`hardware/companions/`) — `n2adr`, `io`,
  `smallio`, `db9`, `psfeedback` — add local audio codecs, ATU control, and
  extra I/O without changing the main board.
- **Radioberry**, added 2019-12-21 ("radioberry firmware and gateware
  added"), lets a Raspberry Pi host the radio directly: the Pi talks to an
  FPGA (also programmed from this repo, see `gateware/boards/radioberry*`)
  over SPI or, in the newer `radioberry-pio` variant (2025), the RP1/RP5's
  PIO peripheral, instead of over Ethernet. The related but separate
  **radioberry-juice** board (added 2021-06-24) instead gives the FPGA its
  own FTDI USB-FIFO host link and runs the full openHPSDR protocol packer
  on-board, independent of the Pi's SPI/PIO link. Radioberry PIO-mode support
  for the Raspberry Pi 5 and RP1 chipset is the most recently active area of
  this repository's development (see recent commits touching
  `gateware/rtl/radioberry/pi-pio/`).

### Software

`software/hermeslite/hermeslite.py` (the Python control module),
`software/hl2setup/` (the C++ discovery/provisioning tool), and
`software/ft8/` (the FT8 decode pipeline) were all added later to support
users and downstream projects rather than to bring up the radio itself; see
`software/README.md` for what each does.

## Further history

- The [Hermes-Lite2 wiki "Releases" page](https://github.com/softerhardware/Hermes-Lite2/wiki/Releases)
  tracks group-buy build numbers and release notes in more detail than this
  file does.
- The [hermes-lite Google Group](https://groups.google.com/forum/#!forum/hermes-lite)
  is the project's long-running discussion archive.
- `gateware/bitfiles/*/README.md` files record what changed release-to-release
  for the gateware specifically.

## Sources

- openHPSDR project overview — archived 2025-04-17:
  <https://web.archive.org/web/20250417152647/https://openhpsdr.org/>
- Hermes module page (M0KHZ's original proposal) — archived 2025-04-17:
  <https://web.archive.org/web/20250417152647/https://openhpsdr.org/hermes.php>
- [Hermes-Lite2 wiki — Releases](https://github.com/softerhardware/Hermes-Lite2/wiki/Releases)
- [Hermes-Lite (1.x) wiki](https://github.com/softerhardware/Hermes-Lite/wiki)
- [hermeslite.com](http://www.hermeslite.com) (published from `docs/` in this repository)
- This repository's own `git log` and `hardware/hl/releases/`, `gateware/bitfiles/` directories
