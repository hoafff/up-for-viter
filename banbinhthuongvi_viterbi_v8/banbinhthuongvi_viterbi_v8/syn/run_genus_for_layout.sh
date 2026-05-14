#!/usr/bin/env bash
set -euo pipefail

# Use a tighter clock for synthesis to leave setup margin after place-route.
# Required:
#   export LIB_FILES="/path/to/sky130_tt.lib"
# Optional override:
#   export CONSTRAINT_FILE="syn/constraints_layout_margin.sdc"

export CONSTRAINT_FILE="${CONSTRAINT_FILE:-syn/constraints_layout_margin.sdc}"

echo "[INFO] Running Genus with layout-margin constraints: ${CONSTRAINT_FILE}"
mkdir -p reports netlist

genus -files syn/run_genus.tcl -log reports/genus_layout_margin.log

echo "============================================================"
echo "[INFO] Genus layout-margin run completed."
echo "[INFO] Netlist/SDC/SDF are in netlist/."
echo "[INFO] Use pnr/run_innovus.sh next."
echo "============================================================"
