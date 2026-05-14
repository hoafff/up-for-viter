#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_ROOT}"

mkdir -p reports
mkdir -p sim/waves

echo "============================================================"
echo "[INFO] Running RTL file-based simulation"
echo "============================================================"

bash sim/run_xrun.sh | tee reports/simulation.log

echo "============================================================"
echo "[INFO] Simulation log saved to reports/simulation.log"
echo "============================================================"

if [ -f sim/waves/viterbi_activity.vcd ]; then
    echo "[INFO] VCD activity file generated:"
    ls -lh sim/waves/viterbi_activity.vcd
else
    echo "[WARNING] VCD activity file was NOT generated."
fi
