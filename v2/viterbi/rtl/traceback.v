`timescale 1ns/1ps

// Combinational traceback for a tail-terminated frame.
// Final encoder state is assumed to be 00 because K=3 encoder appends two tail zeros.
module traceback (
    input  wire [3:0] dec_s0,
    input  wire [3:0] dec_s1,
    input  wire [3:0] dec_s2,
    input  wire [3:0] dec_s3,
    input  wire [3:0] dec_s4,
    input  wire [3:0] dec_s5,
    input  wire [1:0] dec_s6,
    input  wire       dec_s7,
    output reg  [7:0] decoded_data
);

    reg [1:0] state_tb;

    always @(*) begin
        decoded_data = 8'b00000000;

        // Stage 7. Only next-state 00 is live in the tail-pruned traceback.
        state_tb        = {1'b0, dec_s7};
        decoded_data[1] = state_tb[1];

        // Stage 6. Only traceback states 00/01 are live here.
        state_tb        = {state_tb[0], dec_s6[state_tb]};
        decoded_data[2] = state_tb[1];

        state_tb        = {state_tb[0], dec_s5[state_tb]};
        decoded_data[3] = state_tb[1];

        state_tb        = {state_tb[0], dec_s4[state_tb]};
        decoded_data[4] = state_tb[1];

        state_tb        = {state_tb[0], dec_s3[state_tb]};
        decoded_data[5] = state_tb[1];

        state_tb        = {state_tb[0], dec_s2[state_tb]};
        decoded_data[6] = state_tb[1];

        state_tb        = {state_tb[0], dec_s1[state_tb]};
        decoded_data[7] = state_tb[1];

        // decoded_data[0] is the second tail bit and remains 0.
        // dec_s0 is kept as survivor storage for waveform/debug consistency.
    end

endmodule
