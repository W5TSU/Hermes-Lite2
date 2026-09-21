# radio_openhpsdr1

The DSP core shared by every board: per-receiver CIC decimation + FIR filtering + CORDIC frequency
translation, and the matching CORDIC-based transmit chain, wired together against the openHPSDR
protocol 1 sample format. Much of this code descends directly from PowerSDR/openHPSDR — e.g.
`varcic.v` is credited to Alex Shovkoplyas, VE3NEA (2008), with later modifications by VK6APH — see
[`../../../docs/HISTORY.md`](../../../docs/HISTORY.md).

## Top level

`radio.v` is instantiated once by `../hermeslite_core.v`. It `generate`s up to ten receiver instances
based on the `NR` parameter (each variant's top-level wrapper sets `NR`/`NT`/`CW`/etc. — see
[`../../variants/README.md`](../../variants/README.md)) and the transmit chain based on `NT`.

## Receiver chain variants

`radio.v` instantiates one of these per receiver, chosen per-variant by which file the board/variant's
Quartus project compiles in:

- **`receiver_nco.v`** — the standard receiver, used by nearly every mainline variant. Wraps `receiver.v`
  (the core CIC/FIR/CORDIC chain: `cic.v`, `cic_comb.v`, `cic_integrator.v`, `cordic.v`, `cpl_cordic.v`,
  `firfilt.v`, `CicInterpM5.v`, the `firram36*`/`FirInterp*`/`firrom/*` filter RAM and coefficient ROMs)
  with its own NCO/mixer stage.
- **`receiver_4000.v`** — a fixed decimate-by-48 receiver, used only by the receive-only "`_4000`"
  variants (`hl2b5up_4000`, `radioberry_cl016_4000`, `radioberry_cl025_4000`).
- **`receiver_ciconly.v`** — a CIC-only receiver (no FIR stage, ~70 kHz usable bandwidth), used by the
  "`_cicrx`" 10RX multiband-skimming variants.
- **`receiver2/`** (`receiver2.v` plus `recv2_cic.v`, `recv2_cordic.v`, `recv2_firromH.v`,
  `recv2_firram48.v`, `recv2_firx2r2.v`) — an alternate receiver implementation, selectable via `radio.v`'s
  `RECEIVER2` parameter. Present in the source tree but not enabled by any current board/variant.
- **`qs1r/`** — a full alternate CIC/CORDIC/FIR receiver chain ported from the
  [QS1R](http://www.qs1r.org/) project (`qs1r_receiver.v`, `qs1r_cic_comb.v`, `qs1r_cic_integrator.v`,
  `qs1r_cordic.v`, `qs1r_fir*.v`, `qs1r_varcic.v`, `qs1r_memcic*.v`, `qs1r_mult_24Sx24S.v`). Compiled by
  several boards' file lists but not currently instantiated anywhere — kept for reference/experimentation.

## Other modules

- `vna_scanner.v` — sweep-mode controller for the radio's built-in VNA (vector network analyzer)
  function.
- `square.v`, `sqroot.v` — magnitude computation (I/Q envelope) used by measurement/VNA functions.
- `counter.v` — small shared utility counter.
