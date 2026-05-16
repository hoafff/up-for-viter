`timescale 1ns/1ps

// Register bank: input frame, path metrics, survivor decisions, and output pulse.
module memory (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        load_frame,
    input  wire        active,
    input  wire        output_cycle,
    input  wire [2:0]  state,
    input  wire [15:0] i_data,

    input  wire [1:0]  pm_new00,
    input  wire [1:0]  pm_new01,
    input  wire [1:0]  pm_new10,
    input  wire [1:0]  pm_new11,
    input  wire [3:0]  dec_even,
    input  wire [3:0]  dec_odd,
    input  wire [7:0]  tb_out,

    output reg  [15:0] rx_reg,
    output reg  [1:0]  pm00,
    output reg  [1:0]  pm01,
    output reg  [1:0]  pm10,
    output reg  [1:0]  pm11,
    output reg  [3:0]  dec_s0,
    output reg  [3:0]  dec_s1,
    output reg  [3:0]  dec_s2,
    output reg  [3:0]  dec_s3,
    output reg  [3:0]  dec_s4,
    output reg  [3:0]  dec_s5,
    output reg  [1:0]  dec_s6,
    output reg         dec_s7,
    output reg  [7:0]  o_data,
    output reg         o_done
);

    localparam ST_01 = 3'b001;
    localparam ST_23 = 3'b010;
    localparam ST_45 = 3'b011;
    localparam ST_67 = 3'b100;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_reg <= 16'b0;
            pm00   <= 2'd0;
            pm01   <= 2'd3;
            pm10   <= 2'd3;
            pm11   <= 2'd3;
            dec_s0 <= 4'b0;
            dec_s1 <= 4'b0;
            dec_s2 <= 4'b0;
            dec_s3 <= 4'b0;
            dec_s4 <= 4'b0;
            dec_s5 <= 4'b0;
            dec_s6 <= 2'b0;
            dec_s7 <= 1'b0;
            o_data <= 8'b0;
            o_done <= 1'b0;
        end else begin
            o_done <= 1'b0;

            if (load_frame) begin
                rx_reg <= i_data;
                pm00   <= 2'd0;
                pm01   <= 2'd3;
                pm10   <= 2'd3;
                pm11   <= 2'd3;
            end else if (active) begin
                pm00 <= pm_new00;
                pm01 <= pm_new01;
                pm10 <= pm_new10;
                pm11 <= pm_new11;

                case (state)
                    ST_01: begin
                        dec_s0 <= dec_even;
                        dec_s1 <= dec_odd;
                    end
                    ST_23: begin
                        dec_s2 <= dec_even;
                        dec_s3 <= dec_odd;
                    end
                    ST_45: begin
                        dec_s4 <= dec_even;
                        dec_s5 <= dec_odd;
                    end
                    ST_67: begin
                        dec_s6 <= dec_even[1:0];
                        dec_s7 <= dec_odd[0];
                    end
                    default: begin
                    end
                endcase
            end else if (output_cycle) begin
                o_data <= tb_out;
                o_done <= 1'b1;
            end
        end
    end

endmodule
