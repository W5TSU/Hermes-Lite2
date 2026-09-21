# Radioberry

FPGA core for the Radioberry companion board, which puts an AD9866-based RF front end (the same chip
used on the main Hermes-Lite board) behind a small FPGA that a Raspberry Pi — or, for `juice`, an FTDI
USB-FIFO host — talks to directly, instead of the FPGA hosting its own Ethernet interface. See
[`../../boards/README.md`](../../boards/README.md) for how the `radioberry`, `radioberry-pio`, and
`radioberry-juice` boards differ, and [`../../../docs/HISTORY.md`](../../../docs/HISTORY.md) for how
Radioberry came to exist.

The DSP chain is the same `../radio_openhpsdr1/` and `../nco/` code used on the main boards; what
differs here is the host link and top-level control.

## SPI / PIO link (`radioberry_core.v`, `pi-pio/`)

- `radioberry_core.v` — top-level core for the SPI-linked `radioberry` board: control/TX-IQ over SPI
  (`spi_slave.v` — an SPI slave sourced from opencores.org) plus a separate RX sample-clock/data path to
  the Pi.
- `pi-pio/radioberry_core.v` — the equivalent top-level core for the `radioberry-pio` board, replacing
  the SPI link with the Raspberry Pi 5 / RP1 PIO peripheral: `pi-pio/rx_pi_pio.v` streams received
  samples upstream to the Pi and `pi-pio/tx_pi_pio.v` receives transmit samples from it.
- `ad9866ctrl.v`, `ad9866pll.v` — Radioberry-specific copies of the AD9866 register control and PLL
  logic (parallel to `../ad9866ctrl.v`/`../ad9866pll.v` used by the main boards).
- `control.v` — command-and-control register decode for the Radioberry link.
- `reset_handler.v` — reset sequencing, originally from Johan Maas (PA3GSB)'s RXSDR project.

## Juice link (`juice/`)

`radioberry-juice` gives the FPGA its own USB host connection (an FTDI FT245-style parallel FIFO) and
runs the openHPSDR protocol directly on-board, rather than relying on host software running on a
Raspberry Pi:

- `radioberry_juice_core.v` — top-level core for the `radioberry-juice`/`radioberry-juice_b1` boards.
- `radioberry_phy.v` — the FTDI FT245 parallel-FIFO physical interface.
- `dsopenhpsdr1.v` / `usopenhpsdr1.v` — Juice-specific copies of the openHPSDR protocol 1
  packer/unpacker (parallel to `../dsopenhpsdr1.v`/`../usopenhpsdr1.v`).
- `i2c_bus.v` — I2C bus interface for on-board peripherals (e.g. the slow ADC).
- `control.v` — command-and-control register decode for the Juice link.
