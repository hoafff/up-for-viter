# Optional tighter synthesis constraint for layout margin.
# Use this only if you want to synthesize for ~200 MHz, then layout/signoff at 180 MHz.
create_clock -name clk -period 5.00 [get_ports clk]

set_input_delay  0.3 -clock clk [get_ports {en i_data}]
set_output_delay 0.3 -clock clk [get_ports {o_data o_done}]

set_false_path -from [get_ports rst_n]
