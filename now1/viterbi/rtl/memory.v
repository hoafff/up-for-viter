`timescale 1ns/1ps

// Register bank for the Viterbi decoder.
//
// Design intent: every register group has its own write-enable so that
//   (a) at RTL level, registers hold their previous value when not selected,
//       which reduces D-pin and downstream switching activity even when no
//       clock gating cells are inserted;
//   (b) if Genus is later allowed to run with lp_insert_clock_gating=true,
//       these "if (en) reg <= ..." idioms are turned into integrated clock
//       gates with negligible code changes.
//
// IMPORTANT: clock is not gated in RTL; only enables are written. This keeps
// the RTL synthesizable and functionally identical regardless of whether the
// tool inserts ICGs.
//
// Enable groups:
//   1) rx_reg              -> we_rx     = load_frame
//   2) path metrics        -> we_pm     = load_frame | active
//   3) dec_s0 / dec_s1     -> we_d01    = active & state==ST_01
//   4) dec_s2 / dec_s3     -> we_d23    = active & state==ST_23
//   5) dec_s4 / dec_s5     -> we_d45    = active & state==ST_45
//   6) dec_s6 / dec_s7     -> we_d67    = active & state==ST_67
//   7) o_data              -> we_out    = output_cycle (gated/holdable)
//      o_done              -> follows output_cycle every clock (always-on
//                              pulse; not enable-gated, not ICG-eligible)
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

    // ------------------------------------------------------------------
    // Enable signals (used by RTL hold-behavior; also the hook for tool
    // ICG insertion when lp_insert_clock_gating is enabled).
    // Note: o_done is NOT in this list. It is a free-running 1-cycle pulse
    // that mirrors output_cycle and is not intended to be clock-gated.
    // ------------------------------------------------------------------
    wire we_rx  = load_frame;
    wire we_pm  = load_frame | active;
    wire we_d01 = active & (state == ST_01);
    wire we_d23 = active & (state == ST_23);
    wire we_d45 = active & (state == ST_45);
    wire we_d67 = active & (state == ST_67);
    wire we_out = output_cycle;

    // ------------------------------------------------------------------
    // 1) rx_reg : enable-gated by we_rx
    // ------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_reg <= 16'b0;
        end else if (we_rx) begin
            rx_reg <= i_data;
        end
    end

    // ------------------------------------------------------------------
    // 2) path metrics : enable-gated by we_pm
    // ------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pm00 <= 2'd0;
            pm01 <= 2'd3;
            pm10 <= 2'd3;
            pm11 <= 2'd3;
        end else if (we_pm) begin
            if (load_frame) begin
                pm00 <= 2'd0;
                pm01 <= 2'd3;
                pm10 <= 2'd3;
                pm11 <= 2'd3;
            end else begin
                pm00 <= pm_new00;
                pm01 <= pm_new01;
                pm10 <= pm_new10;
                pm11 <= pm_new11;
            end
        end
    end

    // ------------------------------------------------------------------
    // 3) dec_s0 / dec_s1 : enable-gated by we_d01
    // ------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dec_s0 <= 4'b0;
            dec_s1 <= 4'b0;
        end else if (we_d01) begin
            dec_s0 <= dec_even;
            dec_s1 <= dec_odd;
        end
    end

    // ------------------------------------------------------------------
    // 4) dec_s2 / dec_s3 : enable-gated by we_d23
    // ------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dec_s2 <= 4'b0;
            dec_s3 <= 4'b0;
        end else if (we_d23) begin
            dec_s2 <= dec_even;
            dec_s3 <= dec_odd;
        end
    end

    // ------------------------------------------------------------------
    // 5) dec_s4 / dec_s5 : enable-gated by we_d45
    // ------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dec_s4 <= 4'b0;
            dec_s5 <= 4'b0;
        end else if (we_d45) begin
            dec_s4 <= dec_even;
            dec_s5 <= dec_odd;
        end
    end

    // ------------------------------------------------------------------
    // 6) dec_s6 / dec_s7 : enable-gated by we_d67
    // ------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dec_s6 <= 2'b0;
            dec_s7 <= 1'b0;
        end else if (we_d67) begin
            dec_s6 <= dec_even[1:0];
            dec_s7 <= dec_odd[0];
        end
    end

    // ------------------------------------------------------------------
    // 7a) o_data : enable-gated by we_out (= output_cycle).
    //     Hold value outside the output cycle so the 8 flops do not see
    //     D-input switching every clock. ICG-eligible.
    // ------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_data <= 8'b0;
        end else if (we_out) begin
            o_data <= tb_out;
        end
    end

    // ------------------------------------------------------------------
    // 7b) o_done : 1-cycle pulse that mirrors output_cycle.
    //     Implemented as a free-running register update every clock
    //     (no enable), because the pulse must return to 0 the cycle after
    //     output_cycle deasserts. This flop is intentionally NOT clock-
    //     gateable and should not be treated as such by the tool.
    // ------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_done <= 1'b0;
        end else begin
            o_done <= output_cycle;
        end
    end

endmodule

