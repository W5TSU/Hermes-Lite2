# Simulation

Per-module testbenches for the DSP-heavy parts of `../rtl/`, built with [myhdl](http://www.myhdl.org/)
and run through `iverilog`/`vvp`. Each `test_*.py` embeds a small Verilog testbench (as a Python string),
drives the RTL module under test with myhdl, and checks its output — usually against a numpy/scipy
reference model, sometimes visually via an FFT plot.

## Running

```sh
python3 test_cordic.py        # run one testbench directly
make                           # runs test_cordic via the Makefile
make clean                     # remove generated .vvp/.lxt/.fst/.v/__pycache__
```

There's no aggregate "run everything" target — run each `test_*.py` directly with `python3`:

- `test_cordic.py`, `test_cpl_cordic.py` — CORDIC frequency-translation core (`../rtl/radio_openhpsdr1/cordic.v`/`cpl_cordic.v`).
- `test_mix1.py`, `test_mixtx1.py` — mixer modules (`../rtl/nco/mix1.v`/`mixtx1.v`).
- `test_nco1.py`, `test_sincos.py` — NCO phase accumulator and sin/cos core (`../rtl/nco/`).
- `test_rx1.py`, `test_rx2.py`, `test_rx2IQ.py` — receiver CIC/FIR chains (`../rtl/radio_openhpsdr1/`).
- `test_i2c_bus2.py` — the I2C bus interface (`../rtl/i2c_bus2.v`), using the third-party `i2c.py`
  bus-functional model (Copyright Alex Forencich).
- `test_slow_adc.py` — the slow ADC readback state machine (`../rtl/slow_adc.v`).

## Shared helpers

- `spectrum.py` — FFT/spectral-plot helper (numpy/pyfftw/matplotlib) used to visually verify DSP output.
- `compfreq.py` — converts a frequency in Hz to the NCO phase-increment word used as test stimulus.
- `nco_hlm.py` — a numpy "high-level model" of the NCO/mixer, used as a golden reference to compare RTL
  output against.
- `i2c.py` — third-party I2C bus-functional model used by `test_i2c_bus2.py`.
- `sincos_coarse.txt`, `sin_fine.txt` — copies of the NCO lookup tables from `../rtl/nco/`, used as
  `$readmemh` inputs by the generated testbenches.

## Dependencies

`iverilog`, `python3`, `myhdl`, `numpy`, `scipy`; `spectrum.py` additionally needs `pyfftw` and
`matplotlib` if a test uses it for plotting.
