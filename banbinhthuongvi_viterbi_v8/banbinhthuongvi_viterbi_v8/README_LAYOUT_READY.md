# v8 layout-ready package

This package keeps the v6/v7 RTL architecture: a 2-cycle terminated Viterbi decoder.
It does not use syndrome decoding and does not replace Viterbi with a lookup table.

The main addition is a Cadence Innovus place-and-route flow under `pnr/`, plus a tighter Genus SDC for layout margin.

Recommended commands:

```bash
source pnr/local_env.sh        # after editing from local_env_example.sh
bash sim/run_save_log.sh
bash syn/run_genus_for_layout.sh
bash pnr/run_innovus.sh
bash scripts/check_reports.sh
```

Current synthesis-only v7/v6 numbers from the previous run were layout-risky because setup slack was only about 86 ps. Use the layout-margin synthesis script before running Innovus.
