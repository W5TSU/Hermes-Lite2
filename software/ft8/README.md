# FT8 Decode Pipeline

A multi-process pipeline for skimming [FT8](https://en.wikipedia.org/wiki/FT8) activity directly from a
Hermes-Lite's receive stream, built around [ZeroMQ](https://zeromq.org/) for distributing decode work
across workers and a Fortran FT8 decoder for the actual demodulation.

## Requirements

- The FT8 decoder itself is **not included here**: `ft8d.pyf` is an [f2py](https://numpy.org/doc/stable/f2py/)
  interface definition for a `ft8b` Fortran subroutine (from [WSJT-X](https://wsjt.sourceforge.io/)'s
  FT8 decoder), which must be compiled separately against WSJT-X's Fortran source to produce the `ft8d`
  Python extension module these scripts import.
- Python 3 with `numpy`, `zmq` (pyzmq), and a Hermes-Lite gateware build that can stream raw receiver
  samples (e.g. one of the `_4000` receive-only variants — see
  [`../../gateware/README.md`](../../gateware/README.md)).

## Pipeline

```
rx4000.py  -->  hl2zmq sockets  -->  ft8_worker.py (N workers)  -->  collector.py
(reads IQ)      (job/result       (runs ft8d decoder,             (aggregates spots,
                  distribution)     builds ft8_spot records)        prints/tracks stats)
```

- **`rx4000.py`** — reads the raw receiver sample stream from the radio (matching the fixed
  decimate-by-48 `receiver_4000.v` gateware chain, hence the name) and hands off decode jobs.
- **`hl2zmq.py`** — ZeroMQ socket wrapper classes (`ipc_req_socket`, `tcp_push_socket`,
  `tcp_collector_socket`, `CoherentRXSocket`) that (de)serialize jobs and I/Q data between the stages
  above; this is the messaging glue every other script here imports.
- **`ft8_worker.py`** — a worker process: pulls a decode job over ZeroMQ, runs it through the `ft8d`
  Fortran decoder, and pushes any decoded spots on to the collector. Run one or more per CPU core.
- **`ft8.py`** — the `ft8_spot` record and `ft8_spots` collection used to represent and manage decoded
  spots (sync, SNR, DT, frequency, callsign, grid, raw FT8 message).
- **`collector.py`** — the sink: receives decoded spot objects, prints them, and tracks simple
  per-station/per-grid stats.
- **`maidenhead.py`** — Maidenhead grid-locator ⇄ latitude/longitude conversion (adapted from
  [space-physics/maidenhead](https://github.com/space-physics/maidenhead)), used to compute
  distance/bearing to spotted stations from a configured home location (`HOME` at the top of the file).
