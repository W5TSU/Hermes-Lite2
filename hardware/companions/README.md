# Companion Boards

Small add-on boards that plug into headers on the main [`../hl/`](../hl/README.md) board to add
functionality without changing the main board itself. Each is its own KiCad project; most have their
own `README.md` here with a bill of materials, since these are typically hand-assembled in small
quantities rather than ordered fully populated.

| Directory | Board | Purpose |
|---|---|---|
| `n2adr` | HL2 Filter Board | Low-pass filter bank designed by Jim, N2ADR (also the author of the Quisk SDR application) |
| `n2adr_jumper` | HL2 connector | Small header/jumper board pairing with the `n2adr` filter board |
| `io` | Hermes-Lite IO Companion Board | Adds general-purpose I/O |
| `io_jumper` | Jumper Board with IO | I2C GPIO expansion (MCP23008) with an RF edge-launch SMA connector |
| `smallio` | Hermes-Lite Small IO Expansion | Smaller MCP23008-based I/O expansion jumper board |
| `db9` | Hermes-Lite DB9 Adapter | DB9 serial adapter (e.g. for CAT/PTT), with level shifting |
| `psfeedback` | PureSignal Feedback | RF sampling board for PureSignal transmit linearization feedback |

`releases/` holds frozen fabrication-output snapshots for `n2adr` and `n2adr_jumper` (as with
`../hl/releases/`). `pictures/` has assembly reference photos for the DB9 and PureSignal-feedback
boards. `release.py` (this directory) renames Gerber output for a companion board the same way
`../hl/gerber/release.py` does for the main board.
