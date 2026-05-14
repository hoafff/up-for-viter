# PnR / Layout flow for viterbi_decoder

This folder adds a baseline Cadence Innovus flow for the Viterbi decoder.
The RTL is still a 2-cycle terminated Viterbi architecture: Branch Metric -> ACS -> Survivor Decision -> Traceback.

## Recommended layout run order

```bash
# 1) Set library paths for your lab machine
cp pnr/local_env_example.sh pnr/local_env.sh
# edit pnr/local_env.sh
source pnr/local_env.sh

# 2) Run RTL simulation and generate VCD activity
bash sim/run_save_log.sh

# 3) Re-synthesize with tighter 5.00 ns SDC for post-layout margin
bash syn/run_genus_for_layout.sh

# 4) Run Innovus place-route
bash pnr/run_innovus.sh
```

## Why synthesize at 5.00 ns?

The lab target is 180 MHz, period about 5.55 ns. The previous synthesis result had only about 86 ps setup slack, which is too thin for layout. `syn/constraints_layout_margin.sdc` uses 5.00 ns so Genus produces a netlist with more pre-layout timing margin. Innovus then closes post-route timing against the generated SDC.

If area or power becomes too high, try 5.20 ns instead by editing `syn/constraints_layout_margin.sdc`.

## Main files

- `syn/run_genus_for_layout.sh`: Genus run using layout-margin SDC.
- `syn/constraints_layout_margin.sdc`: 5.00 ns synthesis constraint.
- `pnr/run_innovus.sh`: Innovus launcher.
- `pnr/run_innovus.tcl`: floorplan, placement, CTS, route, reports.
- `pnr/mmmc.tcl`: MMMC setup from `LIB_FILES` and generated SDC.
- `pnr/local_env_example.sh`: environment variable template.

## Required environment variables

- `LIB_FILES`: timing `.lib`, colon-separated if multiple.
- `LEF_FILES`: technology LEF first, standard-cell LEF after it, colon-separated.

Optional but recommended:

- `QRC_TECH_FILE`: extraction technology file.
- `SITE_NAME`: default `unithd`.
- `PIN_LAYER`: default `met3`.
- `CORE_UTIL`: default `0.50`.
- `ENABLE_POWER_GRID`: default `1`.

## Reports to check

```bash
grep -i "slack" reports/pnr/timing_postRoute.rpt | head -20
grep -iE "power|internal|switching|leakage|total" reports/pnr/power.rpt | head -80
grep -iE "error|violation|short|open" reports/pnr/verifyConnectivity.rpt reports/pnr/verify_drc.rpt
```
