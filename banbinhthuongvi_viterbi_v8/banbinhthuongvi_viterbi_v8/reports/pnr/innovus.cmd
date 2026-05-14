#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Wed May 13 07:59:36 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v23.37-s090_1 (64bit) 02/09/2026 16:09 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 23.37-s090_1 NR260126-2134/23_17-UB (database version 18.20.682_1) {superthreading v2.20}
#@(#)CDS: AAE 23.17-s025 (64bit) 02/09/2026 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 23.17-s038_1 () Feb  4 2026 22:23:13 ( )
#@(#)CDS: SYNTECH 23.17-s006_1 () Jan 20 2026 01:15:57 ( )
#@(#)CDS: CPE v23.17-s060
#@(#)CDS: IQuantus/TQuantus 23.1.1-s583 (64bit) Mon Nov 24 21:09:39 PST 2025 (Linux 3.10.0-693.el7.x86_64)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
set init_top_cell viterbi_decoder
set init_verilog netlist/viterbi_decoder_syn.v
set init_lef_file {/path/to/tech.lef /path/to/stdcells.lef}
set init_mmmc_file pnr/mmmc.tcl
init_design
win
gui_select -rect {0.09100 0.06400 0.09200 0.05000}
gui_select -rect {0.08100 0.05100 0.06800 0.05400}
gui_select -rect {0.04000 0.07700 0.10800 0.02800}
zoomBox -0.17000 -0.07400 0.25700 0.19300
zoomBox -0.13100 -0.05600 0.23200 0.17100
zoomBox 0.00800 0.00600 0.14500 0.09200
uiSetTool select
