# hl2setup

A small FLTK-based C++ GUI for discovering a Hermes-Lite on the network and running setup/diagnostic
routines against it directly over its openHPSDR protocol UDP interface — independent of any SDR
application.

- `discover.cxx` — sends/handles the UDP discovery broadcast used to find radios on the local network.
- `hl2.cxx` / `hl2.h` — the HL2 protocol/control layer: board discovery state, bias test, and power
  flatness test routines, exposed to the GUI (`HL2Run`, `HL2GetBoardId`, `send_discover`, etc.).
- `hl2setup.cxx` — the FLTK GUI itself (buttons/callbacks for setup, bias test, power flatness test).

## Building

Linux, requires [FLTK](https://www.fltk.org/) development files (`fltk-config` on `PATH`):

```sh
make
```

Windows: use `Makefile.mingw`, or open the project in Visual C++ as noted in the main `Makefile`'s `win`
target.
