#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_ROOT}"

mkdir -p reports
mkdir -p netlist

echo "============================================================"
echo "[INFO] Project root: ${PROJECT_ROOT}"
echo "[INFO] Running Cadence Genus synthesis"
echo "============================================================"

if [ -z "${LIB_FILES:-}" ]; then
    echo "[ERROR] LIB_FILES is not set."
    echo ""
    echo "You need to set your standard-cell .lib file first."
    echo "Example:"
    echo "  export LIB_FILES=\"/path/to/your/standard_cell.lib\""
    echo ""
    echo "To find possible .lib files, try:"
    echo "  find /opt /tools /home -name \"*.lib\" 2>/dev/null | head -50"
    echo ""
    exit 1
fi

echo "[INFO] LIB_FILES = ${LIB_FILES}"

# Try common Genus invocation styles
if genus -files syn/run_genus.tcl -log reports/genus.log; then
    echo "[INFO] Genus completed with -files option."
else
    echo "[WARN] genus -files failed. Trying genus -f ..."
    genus -f syn/run_genus.tcl -log reports/genus.log
fi

echo "============================================================"
echo "[INFO] Done."
echo "[INFO] Check these reports:"
echo "  reports/timing.rpt"
echo "  reports/area.rpt"
echo "  reports/power.rpt"
echo "  reports/qor.rpt"
echo "============================================================"
