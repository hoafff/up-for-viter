# ============================================================
# Innovus place-and-route script for viterbi_decoder
# Designed as a layout-ready baseline for sky130-like std-cell labs.
# Keep all tech-specific paths in environment variables.
# ============================================================

proc env_or_default {name default} {
    if {[info exists ::env($name)] && $::env($name) != ""} {
        return $::env($name)
    }
    return $default
}

set TOP        "viterbi_decoder"
set REPORT_DIR "reports/pnr"
set OUT_DIR    "layout"
file mkdir $REPORT_DIR
file mkdir $OUT_DIR

if {![file exists "netlist/${TOP}_syn.v"]} {
    puts "ERROR: netlist/${TOP}_syn.v not found. Run synthesis first."
    exit 1
}
if {![info exists ::env(LEF_FILES)] || $::env(LEF_FILES) == ""} {
    puts "ERROR: LEF_FILES is not set."
    exit 1
}

set lef_files [split $::env(LEF_FILES) ":"]
set SITE_NAME   [env_or_default SITE_NAME "unithd"]
set PIN_LAYER   [env_or_default PIN_LAYER "met3"]
set CLK_LAYER   [env_or_default CLOCK_ROUTE_LAYER "met4"]
set CORE_UTIL   [env_or_default CORE_UTIL "0.50"]
set CORE_MARGIN [env_or_default CORE_MARGIN "10"]

set PWR_NET     [env_or_default PWR_NET "VPWR"]
set GND_NET     [env_or_default GND_NET "VGND"]
set PWR_PIN     [env_or_default PWR_PIN "VPWR"]
set GND_PIN     [env_or_default GND_PIN "VGND"]
set WELL_P_PIN  [env_or_default WELL_P_PIN "VPB"]
set WELL_N_PIN  [env_or_default WELL_N_PIN "VNB"]
set ENABLE_PG   [env_or_default ENABLE_POWER_GRID "1"]

puts "============================================================"
puts "INFO: Top        : $TOP"
puts "INFO: LEF files  : $lef_files"
puts "INFO: Site       : $SITE_NAME"
puts "INFO: Core util  : $CORE_UTIL"
puts "INFO: Pin layer  : $PIN_LAYER"
puts "INFO: PG nets    : $PWR_NET / $GND_NET"
puts "============================================================"

# -------------------------
# Init design
# -------------------------
set init_top_cell $TOP
set init_verilog  "netlist/${TOP}_syn.v"
set init_lef_file $lef_files
set init_mmmc_file "pnr/mmmc.tcl"

init_design

# -------------------------
# Global power/ground connect
# -------------------------
catch {globalNetConnect $PWR_NET -type pgpin -pin $PWR_PIN -inst * -verbose}
catch {globalNetConnect $GND_NET -type pgpin -pin $GND_PIN -inst * -verbose}
catch {globalNetConnect $PWR_NET -type pgpin -pin $WELL_P_PIN -inst * -verbose}
catch {globalNetConnect $GND_NET -type pgpin -pin $WELL_N_PIN -inst * -verbose}

# -------------------------
# Floorplan
# -------------------------
catch {setDesignMode -process 130}

# floorPlan arguments: aspect_ratio, core_util, left, bottom, right, top margins.
# Small block: use conservative utilization to reduce post-route congestion.
if {[catch {floorPlan -site $SITE_NAME -r 1.0 $CORE_UTIL $CORE_MARGIN $CORE_MARGIN $CORE_MARGIN $CORE_MARGIN} fp_msg]} {
    puts "WARNING: floorPlan with site $SITE_NAME failed: $fp_msg"
    puts "WARNING: Trying floorPlan without explicit site."
    floorPlan -r 1.0 $CORE_UTIL $CORE_MARGIN $CORE_MARGIN $CORE_MARGIN $CORE_MARGIN
}

# Reasonable IO pin placement. Non-fatal if a layer name differs in the lab LEF.
set input_pins  [list clk rst_n en i_data\[0\] i_data\[1\] i_data\[2\] i_data\[3\] i_data\[4\] i_data\[5\] i_data\[6\] i_data\[7\] i_data\[8\] i_data\[9\] i_data\[10\] i_data\[11\] i_data\[12\] i_data\[13\] i_data\[14\] i_data\[15\]]
set output_pins [list o_done o_data\[0\] o_data\[1\] o_data\[2\] o_data\[3\] o_data\[4\] o_data\[5\] o_data\[6\] o_data\[7\]]
catch {setPinAssignMode -pinEditInBatch true}
catch {editPin -pin $input_pins  -side LEFT  -layer $PIN_LAYER -spreadType CENTER}
catch {editPin -pin $output_pins -side RIGHT -layer $PIN_LAYER -spreadType CENTER}
catch {setPinAssignMode -pinEditInBatch false}

# Optional simple PG ring/route. If your lab has a separate PG template,
# set ENABLE_POWER_GRID=0 and source that template instead.
if {$ENABLE_PG == "1"} {
    set ring_top    [env_or_default POWER_RING_TOP_LAYER "met5"]
    set ring_bottom [env_or_default POWER_RING_BOTTOM_LAYER "met4"]
    puts "INFO: Trying simple PG ring on $ring_top/$ring_bottom"
    catch {addRing -nets [list $PWR_NET $GND_NET] -type core_rings -follow core \
        -layer [list top $ring_top bottom $ring_top left $ring_bottom right $ring_bottom] \
        -width 1.0 -spacing 1.0 -offset 1.0} pg_ring_msg
    if {[info exists pg_ring_msg] && $pg_ring_msg != ""} { puts "INFO/WARN addRing: $pg_ring_msg" }
    catch {sroute -connect {corePin blockPin padPin padRing floatingStripe} -nets [list $PWR_NET $GND_NET]} pg_sroute_msg
    if {[info exists pg_sroute_msg] && $pg_sroute_msg != ""} { puts "INFO/WARN sroute: $pg_sroute_msg" }
}

# -------------------------
# Placement and pre-CTS opt
# -------------------------
catch {setPlaceMode -congEffort high}
if {[catch {place_design} place_msg]} {
    puts "WARNING: place_design failed: $place_msg"
    puts "WARNING: Trying legacy placeDesign."
    placeDesign
}

catch {optDesign -preCTS}
timeDesign -preCTS -numPaths 20 > $REPORT_DIR/timing_preCTS.rpt

# -------------------------
# CTS and post-CTS opt
# -------------------------
# Give Innovus freedom to keep clock short; for tiny design this is enough.
catch {set_ccopt_property target_skew 0.05}
catch {set_ccopt_property target_max_trans 0.15}
catch {set_ccopt_property route_type $CLK_LAYER}

if {[catch {ccopt_design} cts_msg]} {
    puts "WARNING: ccopt_design failed: $cts_msg"
    puts "WARNING: Trying legacy clockDesign."
    catch {clockDesign}
}

catch {optDesign -postCTS}
catch {optDesign -postCTS -hold}
timeDesign -postCTS -numPaths 20 > $REPORT_DIR/timing_postCTS.rpt

# -------------------------
# Routing and post-route opt
# -------------------------
catch {setNanoRouteMode -routeWithTimingDriven true}
catch {setNanoRouteMode -routeWithSiDriven true}
catch {setNanoRouteMode -drouteFixAntenna true}

routeDesign

catch {optDesign -postRoute}
catch {optDesign -postRoute -hold}
timeDesign -postRoute -numPaths 50 > $REPORT_DIR/timing_postRoute.rpt
catch {timeDesign -postRoute -hold -numPaths 50 > $REPORT_DIR/timing_postRoute_hold.rpt}

# -------------------------
# Reports and outputs
# -------------------------
catch {report_timing -max_paths 50 > $REPORT_DIR/timing.rpt}
catch {report_area > $REPORT_DIR/area.rpt}
catch {report_power > $REPORT_DIR/power.rpt}
catch {report_power -by_hierarchy > $REPORT_DIR/power_hier.rpt}
catch {report_qor > $REPORT_DIR/qor.rpt}
catch {verifyConnectivity -type all -error 1000 -warning 50 > $REPORT_DIR/verifyConnectivity.rpt}
catch {verify_drc > $REPORT_DIR/verify_drc.rpt}

saveNetlist $OUT_DIR/${TOP}_pnr.v
catch {write_sdf $OUT_DIR/${TOP}_pnr.sdf}
catch {write_sdc $OUT_DIR/${TOP}_pnr.sdc}
catch {streamOut $OUT_DIR/${TOP}.gds -mapFile [env_or_default GDS_MAP_FILE ""] -libName DesignLib -units 1000 -mode ALL}

saveDesign $OUT_DIR/${TOP}.enc

puts "============================================================"
puts "INFO: Innovus PnR completed."
puts "INFO: Check post-route timing: $REPORT_DIR/timing_postRoute.rpt"
puts "INFO: Check DRC/connectivity: $REPORT_DIR/verify_drc.rpt and verifyConnectivity.rpt"
puts "============================================================"
exit
