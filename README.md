# RTL to GDS Implementation of Low Power Configurable Multi Clock Digital System

## Overview

This project implements a configurable multi-clock digital system from RTL design to GDSII layout using industry-standard ASIC design tools. The system integrates key digital components, including a register file, ALU, and UART with FIFO, operating across multiple clock domains.

The flow covers RTL verification, linting, synthesis, scan-chain insertion (DFT), formal equivalence checking, static timing analysis (STA), power analysis, and physical implementation (place-and-route) targeting the TSMC 0.13 µm technology node (`scmetro_tsmc_cl013g_rvt`).

The project focuses on low-power design, functional correctness, testability, and timing closure throughout the ASIC implementation flow.



---

## Repository Structure

```text
├── DFT/
│   ├── cons.tcl
│   ├── dft_script.tcl
│   ├── netlists/
│   ├── reports/
│   ├── log/
│   └── system.lst
├── Formality/
│   ├── post-PnR/
│   │   ├── reports/
│   │   ├── logs/
│   │   ├── pnr_fm_script.tcl
│   │   ├── run_pnr_fm.tcl
│   │   └── system.lst
│   ├── post-dft/
│   │   ├── reports/
│   │   ├── logs/
│   │   ├── dft_fm_script.tcl
│   │   ├── run_dft_fm.tcl
│   │   └── system.lst
│   └── post-syn/
│       ├── reports/
│       ├── logs/
│       ├── run_syn_fm.tcl
│       ├── syn_fm_script.tcl
│       └── system.lst
├── PrimeTime/
│   ├── PT.tcl
│   ├── pt.log
│   └── report/
├── SpyGlass/
│   ├── cdc/
│   ├── lint/
│   ├── rdc/
│   ├── spyglass.prj
│   ├── system.sdc
│   └── system.sgdc
├── Synthesis/
│   ├── cons.tcl
│   ├── log/
│   ├── netlists/
│   ├── reports/
│   ├── syn_script.tcl
│   └── system.lst
├── System_pnr/
│   ├── DFT/
│   ├── pnr/
│   └── std_cells/
├── do_files/
├── gls/
├── rtl/
└── rtl_DFT/
```

---

## Clock Architecture & Frequencies

The design utilizes a multi-clock architecture with generated clocks and dedicated test domains.

| Clock Signal | Period | Frequency | Description |
|---|---:|---:|---|
| **REF_CLK** | 10.00 ns | 100.00 MHz | Primary reference clock |
| **ALU_CLK** | 10.00 ns | 100.00 MHz | Gated clock domain for Arithmetic Logic Unit (`U0_CLK_GATE/GATED_CLK`) |
| **UART_CLK** | 271.27 ns | 3.69 MHz | Base UART communication clock |
| **RX_CLK** | 271.27 ns | 3.69 MHz | Receiver sampling clock (divided by 1 from `UART_CLK`) |
| **TX_CLK** | 8,680.64 ns | 115.19 kHz | Transmitter baud clock (divided by 32 from `UART_CLK`) |
| **DFTCLK** (`scan_clk`) | 1,000.00 ns | 1.00 MHz | Dedicated scan test clock |

---

## Design Area & Resource Utilization

- **Total Cell Area:** 24,560.08 units
- **Combinational Area:** 12,946.05 units (~52.7%)
- **Non-Combinational (Sequential) Area:** 11,614.03 units (~47.3%)
- **Port / Net Count:** 882 ports, 2,877 nets

### Subsystem Area Distribution

| Subsystem | Area (units) | Percentage |
|---|---:|---:|
| `U0_RegFile` | 6,663.65 | 27.1% |
| `U0_ALU` | 5,675.22 | 23.1% |
| `U0_UART_FIFO` | 4,526.77 | 18.4% |
| `U0_UART` | 3,786.62 | 15.4% |

---

## Power Analysis (PrimeTime)

### Power Consumption

| Metric | Value | Percentage |
|---|---:|---:|
| **Total Power** | `5.114e-04` (0.511 mW) | — |
| **Cell Internal Power** | `4.157e-04` | 81.29% |
| **Net Switching Power** | `7.737e-05` | 15.13% |
| **Cell Leakage Power** | `1.832e-05` | 3.58% |

**Clock Network Dominance:** Clock network internal and switching power accounts for 96.41% of the power profile (`4.930e-04`).

---

## Formal Equivalence Verification (Formality)

Equivalence checking was executed across all implementation stages against the reference RTL.

| Verification Stage | Passing Compare Points | Failing | Aborted |
|---|---:|---:|---:|
| Post-Synthesis Formality | 355 | 0 | 0 |
| Post-DFT Formality | 345 | 0 | 0 |
| Post-PnR Formality | 345 | 0 | 0 |

- **Post-Synthesis:** 355 passing compare points, 0 failing, 0 aborted.
- **Post-DFT:** 345 passing compare points, 0 failing, 0 aborted. Scan mux wrapping and test wrapper adjustments accounted for.
- **Post-PnR:** 345 passing compare points, 0 failing, 0 aborted, confirming full logical preservation through physical layout and routing.

---

## Design-for-Test (DFT) & Scan Insertion

Scan insertion was performed using **Synopsys Design Compiler DFTMAX**, implementing a full-scan architecture with multiplexed flip-flops.

### DFT Configuration

| Parameter | Result |
|---|---|
| Scan Methodology | Full Scan |
| Scan Style | Multiplexed Flip-Flop |
| Number of Scan Chains | 4 |
| Total Scan Cells | 351 |
| Maximum Configured Chain Length | 100 |
| Clock Mixing | Disabled |
| Scan Clock | 1 MHz |
| Estimated Test Coverage | **99.50%** |
| Total Faults Analyzed | 16,176 |

### Scan Chain Distribution

| Chain | Length |
|---|---:|
| S1 | 88 |
| S2 | 88 |
| S3 | 88 |
| S4 | 87 |

### DFT Verification

Post-insertion DFT design rule checking and fault coverage estimation were performed. The analysis reported one constant-1 violation associated with a clock-gating cell; the remaining 351 sequential cells were identified as valid scan cells.

The reported 99.50% test coverage is an estimate generated by DFT Compiler, rather than a result from completed ATPG pattern simulation.

---

## Physical Implementation & Place-and-Route (PnR)

- **Tool Flow:** Executed via advanced physical implementation and routing environments (Innovus / PnR engine).
- **Floorplanning:** Die area optimized for core utilization, incorporating standard cell placement rows and power grid ring definitions.
- **Clock Tree Synthesis (CTS):** Minimized clock skew and insertion delay across all functional and test domains, validating maximum transition and capacitance limits.
- **Routing & DRC/LVC:** Detailed metal routing performed across multiple metal layers with zero geometrical violations (`.geom.rpt`) and verified connectivity (`.conn.rpt`).
- **Signoff Deliverables:** Final layout database (`.enc`), standard delay format (`.sdf`), extracted parasitics (`.spf`), and GDSII stream files (`.gds`) fully generated in the export directory.

---

## Final Post-Route Timing Closure (Innovus `timeDesign`)

The final post-route timing summaries for `SYS_TOP` show **positive worst negative slack (WNS)** and **zero total negative slack (TNS)** for both setup and hold checks, with **no violating paths** in the reported categories.

### Setup Timing — Post-Route

| Metric | All | Reg-to-Reg | Input-to-Reg | Reg-to-Output | Input-to-Output | Clock Gating |
|---|---:|---:|---:|---:|---:|---:|
| WNS (ns) | **+0.177** | +0.177 | +6.006 | +213.229 | N/A | +7.863 |
| TNS (ns) | **0.000** | 0.000 | 0.000 | 0.000 | N/A | 0.000 |
| Violating paths | **0** | 0 | 0 | 0 | N/A | 0 |
| Reported paths | 1,057 | 1,043 | 368 | 7 | N/A | 1 |

### Hold Timing — Post-Route

| Metric | All | Reg-to-Reg | Input-to-Reg | Reg-to-Output | Input-to-Output | Clock Gating |
|---|---:|---:|---:|---:|---:|---:|
| WNS (ns) | **+0.081** | +0.081 | +0.200 | +2.363 | N/A | +0.446 |
| TNS (ns) | **0.000** | 0.000 | 0.000 | 0.000 | N/A | 0.000 |
| Violating paths | **0** | 0 | 0 | 0 | N/A | 0 |
| Reported paths | 1,057 | 1,043 | 368 | 7 | N/A | 1 |

### Post-Route Design Rule Checks

| Check | Violating Nets (Terms) | Worst Violation |
|---|---:|---:|
| Maximum Capacitance | 0 (0) | 0.000 |
| Maximum Transition | 0 (0) | 0.000 |
| Maximum Fanout | 0 (0) | 0.000 |

**Timing Closure Result:** The final post-route reports show **no setup or hold violations** and **no reported capacitance, transition, or fanout violations**. The setup and hold summaries each report a density value of `100.000%` (report field; not necessarily physical core utilization).

**Source Reports:**

- `System_pnr/pnr/timingReports/SYS_TOP_postRoute.summary`
- `System_pnr/pnr/timingReports/SYS_TOP_postRoute_hold.summary`


---

## Simulation & Verification (Gate-Level Simulation)

- **Testbench Architecture:** Verified using top-level testbenches (`SYS_TOP_tb.v`) driving stimulus across functional and test modes.
- **Gate-Level Simulation (GLS):** Post-synthesis and post-PnR netlists simulated alongside back-annotated SDF timing files to guarantee zero race conditions, setup/hold violations, or functional regressions under nominal and corner conditions.
