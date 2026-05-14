#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_ROOT}"

mkdir -p reports

echo "============================================================"
echo "[INFO] Running RTL file-based simulation"
echo "============================================================"

bash sim/run_xrun.sh | tee reports/simulation.log

echo "============================================================"
echo "[INFO] Simulation log saved to reports/simulation.log"
echo "============================================================"
