#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_ROOT}"

mkdir -p sim/waves

echo "[INFO] Project root : ${PROJECT_ROOT}"
echo "[INFO] Running Cadence xrun with sim/run.f"

xrun -clean -f sim/run.f

echo "[INFO] Simulation completed."

if [ -f sim/waves/viterbi_activity.vcd ]; then
    echo "[INFO] VCD generated:"
    ls -lh sim/waves/viterbi_activity.vcd
else
    echo "[WARNING] VCD not found: sim/waves/viterbi_activity.vcd"
fi
