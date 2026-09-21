Hermes-Lite 2.x
===============

See the main [Hermes-Lite Web Page](http://www.hermeslite.com) for the latest links and details.

This is a low-cost, open-source software defined amateur radio HF transceiver based on a
[broadband modem chip](http://www.analog.com/en/broadband-products/broadband-codecs/ad9866/products/product.html)
and the [Hermes SDR project](https://web.archive.org/web/20250417152647/https://openhpsdr.org/hermes.php)
(openhpsdr.org is offline; linked above via the Internet Archive). It speaks openHPSDR protocol 1 over
Ethernet, so it works with existing SDR software such as Quisk, Thetis/PowerSDR, and SparkSDR. See
[`docs/HISTORY.md`](docs/HISTORY.md) for how Hermes-Lite relates to the original Hermes/openHPSDR project
and how this codebase got to where it is today.

This repository contains everything needed to build one: FPGA gateware, KiCad hardware designs, and
host-side software. Each area has its own README with details specific to it:

- [`gateware/`](gateware/README.md) — Verilog FPGA source, per-board and per-variant build
  configuration, and simulation testbenches. Start here if you want to build or modify the firmware
  that runs on the radio, or load a prebuilt release onto one.
- [`hardware/`](hardware/README.md) — KiCad schematics and PCB layouts for the main board and its
  companion boards (audio codec, ATU control, extra I/O), plus BOM generation tooling.
- [`software/`](software/README.md) — Host-side tools: a Python control/scripting module
  (`hermeslite.py`), an FT8 decode pipeline, and a C++ discovery/provisioning utility.

## Getting started

- **Building a radio:** see [`hardware/README.md`](hardware/README.md) for the PCB/BOM files, and
  [`gateware/README.md`](gateware/README.md) for how to build and load gateware onto it once assembled.
- **Using an existing radio:** most people use one of the SDR applications above rather than anything in
  this repository directly; [`software/hermeslite/README.md`](software/hermeslite/README.md) covers the
  optional Python control module for configuring experimental features.
- **Project background:** [`docs/HISTORY.md`](docs/HISTORY.md).
