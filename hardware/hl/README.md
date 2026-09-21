# Hermes-Lite 2.0 Main Board

KiCad project for the main Hermes-Lite 2.0 board (`hermeslite.pro`/`.sch`/`.kicad_pcb`), split across
schematic sheets by subsystem: `Clock.sch`, `Ethernet.sch`, `InputOutput.sch`, `PA.sch`, `Power.sch`,
`RFFrontend.sch`. `hermeslite.pdf` is the rendered schematic and `hermeslite.net`/`.xml` are generated
netlist/BOM-source exports — see [`../../docs/HISTORY.md`](../../docs/HISTORY.md) for how this board's
revisions map to the gateware `hl2b2`/`hl2b3to4`/`hl2b5up` board directories.

- **`libs/`** — project-specific KiCad symbol/footprint libraries (`hermeslite.lib`, `hermeslite.dcm`,
  `hermeslite.pretty`).
- **`releases/`** — one directory per hardware release (`hl2p0beta2` … `hl2p0build9`), each a frozen
  snapshot of the fabrication outputs for that revision.
- **`gerber/`** — Gerber/drill export tooling: `release.py <dir>` renames KiCad's Gerber output into the
  conventional extensions (`.GTL`/`.GBL`/`.GTO`/`.GBO`/`.GTS`/`.GBS`/`.GML`/`.TXT`) expected by fab
  houses; `postprocess.py`/`postprocesspos.py` do further cleanup of the Gerber/placement files.
- **`bom/`** — BOM generation, built around a shared `BOM.py` module that reads `../hermeslite.xml`
  (KiCad's netlist/BOM export) plus `parts.json`/`octopart.db` for part metadata and pricing:
  - `mkstandardbom.py` — the standard (non-assembly) BOM, rendered to `bom.standard.pdf` via `bom.tex`.
  - `mkassemblybom.py` / `mkassemblycsv.py` — BOM for contract assembly, rendered to
    `bom.assembly.pdf`/`.xlsx` via `bomassembly.tex`.
  - `mknopabom.py` — BOM variant excluding the PA (power amplifier) section.
  - `updateprices.py` — refreshes part pricing in `octopart.db` via the Octopart API.

Each script's `optionset` argument to `BOM.BOM(...)` controls which conditionally-populated parts
(DNI/ADNI — "do not install" / "assembly DNI") are included; see the individual scripts for the exact
sets used.
