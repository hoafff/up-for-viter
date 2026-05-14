# ============================================================
# Cadence Genus synthesis script for Viterbi decoder
# Try proper ICG clock-gating before elaboration
# ============================================================

set TOP viterbi_decoder
set REPORT_DIR reports
set OUT_DIR    netlist

file mkdir $REPORT_DIR
file mkdir $OUT_DIR

if {![info exists ::env(LIB_FILES)] || $::env(LIB_FILES) == ""} {
    puts "ERROR: LIB_FILES is not set."
    exit 1
}

set LIB_FILES [split $::env(LIB_FILES) ":"]

puts "============================================================"
puts "INFO: Top design : $TOP"
puts "INFO: Libraries  : $LIB_FILES"
puts "============================================================"

set_db library $LIB_FILES

# Lab update: do not use scan flip-flops.
# This matches the requested rule:
#   set_db [get_db lib_cells *SDFF*] .dont_use true
catch {set_db [get_db lib_cells *SDFF*] .dont_use true}
set sdff_cells [get_db lib_cells *SDFF*]
if {[llength $sdff_cells] > 0} {
    puts "INFO: Disable scan flip-flops: $sdff_cells"
    catch {set_db $sdff_cells .dont_use true}
}

# ============================================================
# Enable clock-gating cells if the library marks them dont_use.
# Must be done before read_hdl / elaborate.
# ============================================================

foreach cg_cell {ICGPRECX1 ICGPRECX2 ICGPRECX4 ICGX1 ICGX2 ICGX4} {
    set cells [get_db lib_cells *$cg_cell*]
    if {[llength $cells] > 0} {
        puts "INFO: Enable clock-gating cell $cg_cell"
        catch {set_db $cells .dont_use false}
        catch {set_db $cells .dont_touch false}
    }
}

catch {set_db lp_insert_clock_gating true}
catch {set_db lp_clock_gating_min_flops 4}
catch {set_db lp_clock_gating_style latch}

set RTL_FILES [list \
    rtl/viterbi_decoder.v \
]

read_hdl $RTL_FILES
elaborate $TOP
current_design $TOP

check_design > $REPORT_DIR/check_design.rpt

if {[info exists ::env(CONSTRAINT_FILE)] && $::env(CONSTRAINT_FILE) != ""} {
    set CONSTRAINT_FILE $::env(CONSTRAINT_FILE)
} else {
    set CONSTRAINT_FILE "syn/constraints.sdc"
}
puts "INFO: Reading SDC: $CONSTRAINT_FILE"
read_sdc $CONSTRAINT_FILE

set_db syn_generic_effort high
set_db syn_map_effort     high
set_db syn_opt_effort     high

set ACT_FILE "sim/waves/viterbi_activity.vcd"

# Read RTL VCD before synthesis so Genus can use realistic switching
# activity for power-driven mapping/optimization when supported.
if {[file exists $ACT_FILE]} {
    puts "============================================================"
    puts "INFO: Reading RTL VCD activity before synthesis from $ACT_FILE"
    puts "============================================================"
    if {[catch {read_vcd -static -vcd_scope tb_viterbi_decoder_fileio.dut $ACT_FILE} vcd_msg_pre]} {
        puts "WARNING: pre-synthesis read_vcd failed:"
        puts $vcd_msg_pre
    } else {
        puts "INFO: pre-synthesis read_vcd completed."
        puts $vcd_msg_pre
    }
} else {
    puts "WARNING: VCD activity file not found before synthesis: $ACT_FILE"
}

syn_generic
syn_map
syn_opt

# Re-read VCD after syn_opt for final power reporting.
if {[file exists $ACT_FILE]} {
    puts "============================================================"
    puts "INFO: Reading VCD activity after syn_opt from $ACT_FILE"
    puts "============================================================"
    if {[catch {read_vcd -static -vcd_scope tb_viterbi_decoder_fileio.dut $ACT_FILE} vcd_msg]} {
        puts "WARNING: post-opt read_vcd failed:"
        puts $vcd_msg
        puts "WARNING: Power may use default activity."
    } else {
        puts "INFO: post-opt read_vcd completed."
        puts $vcd_msg
    }
} else {
    puts "============================================================"
    puts "WARNING: VCD activity file not found: $ACT_FILE"
    puts "WARNING: Power report will use default activity."
    puts "============================================================"
}

report_qor                  > $REPORT_DIR/qor.rpt
report_timing -max_paths 20 > $REPORT_DIR/timing.rpt
report_area                 > $REPORT_DIR/area.rpt
catch {report_area -depth 10 > $REPORT_DIR/area_hier.rpt}
report_power                > $REPORT_DIR/power.rpt
catch {report_power -by_hierarchy > $REPORT_DIR/power_hier.rpt}
report_gates                > $REPORT_DIR/gates.rpt

write_hdl > $OUT_DIR/${TOP}_syn.v
write_sdc > $OUT_DIR/${TOP}_syn.sdc
write_sdf > $OUT_DIR/${TOP}_syn.sdf

puts "============================================================"
puts "INFO: Synthesis completed successfully."
puts "INFO: Reports are in $REPORT_DIR"
puts "============================================================"

exit
