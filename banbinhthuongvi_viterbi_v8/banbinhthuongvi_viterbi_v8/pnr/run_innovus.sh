#!/usr/bin/env bash
set -euo pipefail

# Required before running:
#   export LIB_FILES="/path/to/*.lib"
#   export LEF_FILES="/path/to/tech.lef:/path/to/stdcell.lef"
# Optional:
#   export QRC_TECH_FILE="/path/to/qrcTechFile"
#   export SITE_NAME=unithd
#   export CORE_UTIL=0.50
#   export ENABLE_POWER_GRID=1

if [[ -z "${LIB_FILES:-}" ]]; then
  echo "ERROR: LIB_FILES is not set."
  exit 1
fi
if [[ -z "${LEF_FILES:-}" ]]; then
  echo "ERROR: LEF_FILES is not set."
  exit 1
fi
if [[ ! -f netlist/viterbi_decoder_syn.v ]]; then
  echo "ERROR: netlist/viterbi_decoder_syn.v not found. Run syn/run_genus_for_layout.sh first."
  exit 1
fi

mkdir -p reports/pnr layout

echo "[INFO] Starting Innovus PnR"
echo "[INFO] LIB_FILES=${LIB_FILES}"
echo "[INFO] LEF_FILES=${LEF_FILES}"
innovus -64 -files pnr/run_innovus.tcl -log reports/pnr/innovus.log

echo "============================================================"
echo "[INFO] Innovus run completed."
echo "[INFO] Reports: reports/pnr/"
echo "[INFO] Outputs: layout/"
echo "============================================================"
