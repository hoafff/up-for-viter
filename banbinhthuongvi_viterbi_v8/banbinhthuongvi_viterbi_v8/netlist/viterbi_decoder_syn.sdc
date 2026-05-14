# ####################################################################

#  Created by Genus(TM) Synthesis Solution 23.17-s085_1 on Thu May 14 14:52:40 +07 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design viterbi_decoder

create_clock -name "clk" -period 5.55 -waveform {0.0 2.775} [get_ports clk]
group_path -name cg_enable_group_clk -through [list \
  [get_pins RC_CG_HIER_INST0/enable]  \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST1/enable]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST0/enable]  \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST1/enable]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST0/enable]  \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST1/enable]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST0/enable]  \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST1/enable]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/E] ]
set_false_path -from [get_ports rst_n]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports en]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[15]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[14]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[13]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[12]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[11]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[10]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[9]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[8]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[7]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[6]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[5]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[4]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[3]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[2]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[1]}]
set_input_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {i_data[0]}]
set_output_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {o_data[7]}]
set_output_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {o_data[6]}]
set_output_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {o_data[5]}]
set_output_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {o_data[4]}]
set_output_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {o_data[3]}]
set_output_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {o_data[2]}]
set_output_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {o_data[1]}]
set_output_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports {o_data[0]}]
set_output_delay -clock [get_clocks clk] -add_delay 0.3 [get_ports o_done]
set_wire_load_mode "enclosed"
set_dont_use false [get_lib_cells sky130_tt_1.8_25/ICGPRECX1]
set_dont_use false [get_lib_cells sky130_tt_1.8_25/ICGPRECX2]
set_dont_use false [get_lib_cells sky130_tt_1.8_25/ICGPRECX4]
set_dont_use false [get_lib_cells sky130_tt_1.8_25/ICGX1]
set_dont_use false [get_lib_cells sky130_tt_1.8_25/ICGX2]
set_dont_use false [get_lib_cells sky130_tt_1.8_25/ICGX4]
set_dont_use true [get_lib_cells sky130_tt_1.8_25/SDFFRX1]
set_dont_use true [get_lib_cells sky130_tt_1.8_25/SDFFRX4]
set_dont_use true [get_lib_cells sky130_tt_1.8_25/SDFFSRX1]
set_dont_use true [get_lib_cells sky130_tt_1.8_25/SDFFSRX4]
set_dont_use true [get_lib_cells sky130_tt_1.8_25/SDFFSX1]
set_dont_use true [get_lib_cells sky130_tt_1.8_25/SDFFSX4]
set_dont_use true [get_lib_cells sky130_tt_1.8_25/SDFFX1]
set_dont_use true [get_lib_cells sky130_tt_1.8_25/SDFFX4]
