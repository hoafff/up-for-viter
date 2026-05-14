# Layout-margin SDC for synthesis before Innovus PnR.
# Target is intentionally tighter than 180 MHz so post-layout parasitic
# has usable setup slack margin.
# 5.00 ns = 200 MHz.
create_clock -name clk -period 5.00 [get_ports clk]

# Keep IO delay modest but non-zero to avoid unconstrained IO paths.
set_input_delay  0.3 -clock clk [get_ports {en i_data}]
set_output_delay 0.3 -clock clk [get_ports {o_data o_done}]

# Async reset is not timed as data.
set_false_path -from [get_ports rst_n]
