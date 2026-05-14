#!/usr/bin/env bash
# Copy this file to local_env.sh and edit paths for your lab machine.
# Then run: source pnr/local_env.sh

# Timing .lib files. You may reuse the same variable used by Genus.
export LIB_FILES="/path/to/sky130_fd_sc_hd__tt_025C_1v80.lib"

# LEF files for Innovus. Put technology LEF first, then standard-cell LEF.
# Separate multiple LEF files by colon (:).
export LEF_FILES="/path/to/sky130_fd_sc_hd.tlef:/path/to/sky130_fd_sc_hd.lef"

# Optional extraction tech file. If unavailable, leave empty; Innovus will use default RC.
export QRC_TECH_FILE=""

# Sky130 HD defaults. Override if your lab uses different names.
export SITE_NAME="unithd"
export PIN_LAYER="met3"
export CLOCK_ROUTE_LAYER="met4"
export CORE_UTIL="0.50"
export CORE_MARGIN="10"

# Power/ground net and std-cell PG pin names for sky130_fd_sc_hd.
export PWR_NET="VPWR"
export GND_NET="VGND"
export PWR_PIN="VPWR"
export GND_PIN="VGND"
export WELL_P_PIN="VPB"
export WELL_N_PIN="VNB"

# Set to 1 to try simple ring + special-route power grid.
# If your lab template already handles PG, set this to 0.
export ENABLE_POWER_GRID="1"
export POWER_RING_TOP_LAYER="met5"
export POWER_RING_BOTTOM_LAYER="met4"
