# ============================================================
# Innovus MMMC setup for viterbi_decoder
# Uses environment variables so it can match the lab installation.
# Required: LIB_FILES
# Optional: QRC_TECH_FILE, PNR_SDC
# ============================================================

proc env_or_default {name default} {
    if {[info exists ::env($name)] && $::env($name) != ""} {
        return $::env($name)
    }
    return $default
}

if {![info exists ::env(LIB_FILES)] || $::env(LIB_FILES) == ""} {
    puts "ERROR: LIB_FILES is not set for MMMC."
    exit 1
}

set lib_files [split $::env(LIB_FILES) ":"]
set sdc_file [env_or_default PNR_SDC "netlist/viterbi_decoder_syn.sdc"]
if {![file exists $sdc_file]} {
    puts "WARNING: $sdc_file not found; falling back to syn/constraints.sdc"
    set sdc_file "syn/constraints.sdc"
}

create_library_set -name LS_TYP -timing $lib_files

set qrc_file [env_or_default QRC_TECH_FILE ""]
if {$qrc_file != "" && [file exists $qrc_file]} {
    create_rc_corner -name RC_TYP -qx_tech_file $qrc_file
} else {
    puts "WARNING: QRC_TECH_FILE not set/found. Using default RC corner."
    create_rc_corner -name RC_TYP
}

create_delay_corner -name DC_TYP -library_set LS_TYP -rc_corner RC_TYP
create_constraint_mode -name CM_FUNC -sdc_files [list $sdc_file]
create_analysis_view -name AV_SETUP -constraint_mode CM_FUNC -delay_corner DC_TYP
create_analysis_view -name AV_HOLD  -constraint_mode CM_FUNC -delay_corner DC_TYP

set_analysis_view -setup [list AV_SETUP] -hold [list AV_HOLD]
