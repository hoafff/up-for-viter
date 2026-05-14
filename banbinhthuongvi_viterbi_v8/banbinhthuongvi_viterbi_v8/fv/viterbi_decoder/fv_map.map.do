
//input ports
add mapped point clk clk -type PI PI
add mapped point rst_n rst_n -type PI PI
add mapped point en en -type PI PI
add mapped point i_data[15] i_data[15] -type PI PI
add mapped point i_data[14] i_data[14] -type PI PI
add mapped point i_data[13] i_data[13] -type PI PI
add mapped point i_data[12] i_data[12] -type PI PI
add mapped point i_data[11] i_data[11] -type PI PI
add mapped point i_data[10] i_data[10] -type PI PI
add mapped point i_data[9] i_data[9] -type PI PI
add mapped point i_data[8] i_data[8] -type PI PI
add mapped point i_data[7] i_data[7] -type PI PI
add mapped point i_data[6] i_data[6] -type PI PI
add mapped point i_data[5] i_data[5] -type PI PI
add mapped point i_data[4] i_data[4] -type PI PI
add mapped point i_data[3] i_data[3] -type PI PI
add mapped point i_data[2] i_data[2] -type PI PI
add mapped point i_data[1] i_data[1] -type PI PI
add mapped point i_data[0] i_data[0] -type PI PI

//output ports
add mapped point o_data[7] o_data[7] -type PO PO
add mapped point o_data[6] o_data[6] -type PO PO
add mapped point o_data[5] o_data[5] -type PO PO
add mapped point o_data[4] o_data[4] -type PO PO
add mapped point o_data[3] o_data[3] -type PO PO
add mapped point o_data[2] o_data[2] -type PO PO
add mapped point o_data[1] o_data[1] -type PO PO
add mapped point o_data[0] o_data[0] -type PO PO
add mapped point o_done o_done -type PO PO

//inout ports




//Sequential Pins
add mapped point o_done/q o_done_reg/Q -type DFF DFF
add mapped point busy/q busy_reg/Q -type DFF DFF
add mapped point dec123[4]/q dec123_reg[4]/Q -type DFF DFF
add mapped point dec123[5]/q dec123_reg[5]/Q -type DFF DFF
add mapped point dec123[6]/q dec123_reg[6]/Q -type DFF DFF
add mapped point dec123[7]/q dec123_reg[7]/Q -type DFF DFF
add mapped point dec123[8]/q dec123_reg[8]/Q -type DFF DFF
add mapped point dec123[9]/q dec123_reg[9]/Q -type DFF DFF
add mapped point dec123[10]/q dec123_reg[10]/Q -type DFF DFF
add mapped point dec123[11]/q dec123_reg[11]/Q -type DFF DFF
add mapped point frame_low[0]/q frame_low_reg[0]/Q -type DFF DFF
add mapped point frame_low[1]/q frame_low_reg[1]/Q -type DFF DFF
add mapped point frame_low[2]/q frame_low_reg[2]/Q -type DFF DFF
add mapped point frame_low[3]/q frame_low_reg[3]/Q -type DFF DFF
add mapped point frame_low[4]/q frame_low_reg[4]/Q -type DFF DFF
add mapped point frame_low[5]/q frame_low_reg[5]/Q -type DFF DFF
add mapped point frame_low[6]/q frame_low_reg[6]/Q -type DFF DFF
add mapped point frame_low[7]/q frame_low_reg[7]/Q -type DFF DFF
add mapped point o_data[2]/q o_data_reg[2]/Q -type DFF DFF
add mapped point o_data[3]/q o_data_reg[3]/Q -type DFF DFF
add mapped point o_data[4]/q o_data_reg[4]/Q -type DFF DFF
add mapped point o_data[5]/q o_data_reg[5]/Q -type DFF DFF
add mapped point o_data[6]/q o_data_reg[6]/Q -type DFF DFF
add mapped point o_data[7]/q o_data_reg[7]/Q -type DFF DFF
add mapped point pm_mid[0]/q pm_mid_reg[0]/Q -type DFF DFF
add mapped point pm_mid[1]/q pm_mid_reg[1]/Q -type DFF DFF
add mapped point pm_mid[3]/q pm_mid_reg[3]/Q -type DFF DFF
add mapped point pm_mid[4]/q pm_mid_reg[4]/Q -type DFF DFF
add mapped point pm_mid[6]/q pm_mid_reg[6]/Q -type DFF DFF
add mapped point pm_mid[7]/q pm_mid_reg[7]/Q -type DFF DFF
add mapped point pm_mid[9]/q pm_mid_reg[9]/Q -type DFF DFF
add mapped point pm_mid[10]/q pm_mid_reg[10]/Q -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
