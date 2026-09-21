# Hardware

KiCad schematics and PCB layouts for Hermes-Lite 2.x, plus its companion boards. These are KiCad
projects (`.pro`/`.sch`/`.kicad_pcb`) — open them with [KiCad](https://www.kicad.org/); the files are
not meaningfully editable as plain text.

- **[`hl/`](hl/README.md)** — the main Hermes-Lite 2.0 board: RF front end, power, clocking, Ethernet,
  and I/O. This is what `gateware/boards/hl2b2`, `hl2b3to4`, and `hl2b5up` target.
- **[`companions/`](companions/README.md)** — small add-on boards that plug into the main board's
  headers to add local audio, ATU/amplifier control, filtering, or extra I/O, without changing the main
  board itself.
- **`enclosure/`** — mechanical parts: end caps (`endcaps/<callsign>/`, community-contributed panel
  designs) and a heatsink/enclosure shim (`heatshim/`).

See [`../docs/HISTORY.md`](../docs/HISTORY.md) for how the board's revisions (`hl2p0beta2` through
`hl2p0build9`) relate to the gateware board directories, and each area's own README for BOM generation
and release layout.
