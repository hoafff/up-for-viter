#!/usr/bin/env bash
set -euo pipefail

echo "=== Synthesis timing ==="
if [[ -f reports/timing.rpt ]]; then grep -i "slack" reports/timing.rpt | head -20; fi

echo "=== Synthesis power ==="
if [[ -f reports/power.rpt ]]; then grep -iE "power|internal|switching|leakage|total" reports/power.rpt | head -80; fi

echo "=== Synthesis QoR ==="
if [[ -f reports/qor.rpt ]]; then grep -iE "Leaf Instance|Sequential|Combinational|Cell Area" reports/qor.rpt; fi

echo "=== PnR post-route timing ==="
if [[ -f reports/pnr/timing_postRoute.rpt ]]; then grep -i "slack" reports/pnr/timing_postRoute.rpt | head -20; else echo "No PnR timing report yet."; fi

echo "=== PnR power ==="
if [[ -f reports/pnr/power.rpt ]]; then grep -iE "power|internal|switching|leakage|total" reports/pnr/power.rpt | head -80; else echo "No PnR power report yet."; fi
