`timescale 1ns/1ps

module viterbi_decoder (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,
    input  wire [15:0] i_data,
    output reg  [7:0]  o_data,
    output reg         o_done
);

    // ============================================================
    // v7: 2-cycle tail-pruned terminated Viterbi decoder
    // ------------------------------------------------------------
    // True hard-decision Viterbi architecture:
    //   Branch Metric -> ACS -> Survivor Decision -> Traceback
    //
    // K = 3, R = 1/2, generators g0 = 111 and g1 = 101.
    // The official lab frames are terminated: the last two source bits are
    // tail zeros, therefore the trellis must end in state 00.  v7 keeps the
    // same terminated Viterbi assumption as v6, but prunes the last two
    // trellis stages to input=0 branches only.  This removes unnecessary
    // ACS logic while staying inside a Viterbi trellis implementation.
    //
    // Cycle 1: compute stages 0..3, save midpoint metrics/decisions.
    // Cycle 2: compute stages 4..5 full ACS, stages 6..7 tail-pruned ACS,
    //          traceback from final state 00, and assert o_done.
    // Latency: o_done is asserted 1 cycle after the accepted en pulse.
    // ============================================================

    localparam [2:0] INF = 3'd7;

    reg        busy;
    reg [7:0]  frame_low;
    reg [11:0] pm_mid;       // {pm3, pm2, pm1, pm0} after trellis stage 3
    reg [11:0] dec123;       // {dec3, dec2, dec1}; dec0 is unnecessary

    wire start_decode = (!busy) && en;

    function [2:0] sat3;
        input [3:0] x;
        begin
            sat3 = x[3] ? INF : x[2:0];
        end
    endfunction

    // Full 4-state ACS trellis step.
    // Return format: {dec[3:0], pm3_next, pm2_next, pm1_next, pm0_next}.
    function [15:0] acs_step;
        input [2:0] p0;
        input [2:0] p1;
        input [2:0] p2;
        input [2:0] p3;
        input [1:0] rx;

        reg [1:0] bm00;
        reg [1:0] bm01;
        reg [1:0] bm10;
        reg [1:0] bm11;

        reg [3:0] c0a;
        reg [3:0] c0b;
        reg [3:0] c1a;
        reg [3:0] c1b;
        reg [3:0] c2a;
        reg [3:0] c2b;
        reg [3:0] c3a;
        reg [3:0] c3b;

        reg sel0;
        reg sel1;
        reg sel2;
        reg sel3;

        reg [2:0] pn0;
        reg [2:0] pn1;
        reg [2:0] pn2;
        reg [2:0] pn3;
        begin
            bm00 = {1'b0,  rx[1]} + {1'b0,  rx[0]};
            bm01 = {1'b0,  rx[1]} + {1'b0, ~rx[0]};
            bm10 = {1'b0, ~rx[1]} + {1'b0,  rx[0]};
            bm11 = {1'b0, ~rx[1]} + {1'b0, ~rx[0]};

            c0a = {1'b0, p0} + {2'b00, bm00}; // old 00 + input 0 -> new 00
            c0b = {1'b0, p1} + {2'b00, bm11}; // old 01 + input 0 -> new 00

            c1a = {1'b0, p2} + {2'b00, bm10}; // old 10 + input 0 -> new 01
            c1b = {1'b0, p3} + {2'b00, bm01}; // old 11 + input 0 -> new 01

            c2a = {1'b0, p0} + {2'b00, bm11}; // old 00 + input 1 -> new 10
            c2b = {1'b0, p1} + {2'b00, bm00}; // old 01 + input 1 -> new 10

            c3a = {1'b0, p2} + {2'b00, bm01}; // old 10 + input 1 -> new 11
            c3b = {1'b0, p3} + {2'b00, bm10}; // old 11 + input 1 -> new 11

            sel0 = (c0b < c0a);
            sel1 = (c1b < c1a);
            sel2 = (c2b < c2a);
            sel3 = (c3b < c3a);

            pn0 = sat3(sel0 ? c0b : c0a);
            pn1 = sat3(sel1 ? c1b : c1a);
            pn2 = sat3(sel2 ? c2b : c2a);
            pn3 = sat3(sel3 ? c3b : c3a);

            acs_step = {{sel3, sel2, sel1, sel0}, pn3, pn2, pn1, pn0};
        end
    endfunction

    // Tail-zero ACS for the second-to-last trellis stage.
    // Only input=0 branches are legal, so only next states 00 and 01 exist.
    // Return format: {dec_state1, dec_state0, pm1_next, pm0_next}.
    function [7:0] acs_tail6;
        input [2:0] p0;
        input [2:0] p1;
        input [2:0] p2;
        input [2:0] p3;
        input [1:0] rx;

        reg [1:0] bm00;
        reg [1:0] bm01;
        reg [1:0] bm10;
        reg [1:0] bm11;

        reg [3:0] c0a;
        reg [3:0] c0b;
        reg [3:0] c1a;
        reg [3:0] c1b;

        reg sel0;
        reg sel1;
        reg [2:0] pn0;
        reg [2:0] pn1;
        begin
            bm00 = {1'b0,  rx[1]} + {1'b0,  rx[0]};
            bm01 = {1'b0,  rx[1]} + {1'b0, ~rx[0]};
            bm10 = {1'b0, ~rx[1]} + {1'b0,  rx[0]};
            bm11 = {1'b0, ~rx[1]} + {1'b0, ~rx[0]};

            // input=0 only
            c0a = {1'b0, p0} + {2'b00, bm00}; // old 00 -> new 00
            c0b = {1'b0, p1} + {2'b00, bm11}; // old 01 -> new 00
            c1a = {1'b0, p2} + {2'b00, bm10}; // old 10 -> new 01
            c1b = {1'b0, p3} + {2'b00, bm01}; // old 11 -> new 01

            sel0 = (c0b < c0a);
            sel1 = (c1b < c1a);

            pn0 = sat3(sel0 ? c0b : c0a);
            pn1 = sat3(sel1 ? c1b : c1a);

            acs_tail6 = {sel1, sel0, pn1, pn0};
        end
    endfunction

    // Final tail-zero ACS.  Only final state 00 is legal.
    // Return dec_state0 for traceback from s8=00 to s7.
    function acs_tail7_dec;
        input [2:0] p0;
        input [2:0] p1;
        input [1:0] rx;

        reg [1:0] bm00;
        reg [1:0] bm11;
        reg [3:0] c0a;
        reg [3:0] c0b;
        begin
            bm00 = {1'b0,  rx[1]} + {1'b0,  rx[0]};
            bm11 = {1'b0, ~rx[1]} + {1'b0, ~rx[0]};

            // input=0 only, final state=00 only
            c0a = {1'b0, p0} + {2'b00, bm00}; // old 00 -> new 00
            c0b = {1'b0, p1} + {2'b00, bm11}; // old 01 -> new 00

            acs_tail7_dec = (c0b < c0a);
        end
    endfunction

    // Four consecutive full ACS trellis steps for the first half.
    // pm_in format : {pm3, pm2, pm1, pm0}
    // rx4 format   : first pair at [7:6], fourth pair at [1:0]
    // Return format: {dec3, dec2, dec1, dec0, pm3_out, pm2_out, pm1_out, pm0_out}
    function [27:0] acs4_full;
        input [11:0] pm_in;
        input [7:0]  rx4;

        reg [15:0] r0;
        reg [15:0] r1;
        reg [15:0] r2;
        reg [15:0] r3;
        begin
            r0 = acs_step(pm_in[2:0], pm_in[5:3], pm_in[8:6], pm_in[11:9], rx4[7:6]);
            r1 = acs_step(r0[2:0],    r0[5:3],    r0[8:6],    r0[11:9],    rx4[5:4]);
            r2 = acs_step(r1[2:0],    r1[5:3],    r1[8:6],    r1[11:9],    rx4[3:2]);
            r3 = acs_step(r2[2:0],    r2[5:3],    r2[8:6],    r2[11:9],    rx4[1:0]);

            acs4_full = {r3[15:12], r2[15:12], r1[15:12], r0[15:12], r3[11:0]};
        end
    endfunction

    // Last four stages: stage4/stage5 are full ACS, stage6/stage7 are
    // tail-pruned ACS because the two tail bits are zero.
    // Return format: {dec7_state0, dec6_state1, dec6_state0, dec5[3:0], dec4[3:0]}.
    function [10:0] acs4_tail_pruned;
        input [11:0] pm_in;
        input [7:0]  rx4;

        reg [15:0] r4;
        reg [15:0] r5;
        reg [7:0]  r6;
        reg        d7;
        begin
            r4 = acs_step(pm_in[2:0], pm_in[5:3], pm_in[8:6], pm_in[11:9], rx4[7:6]);
            r5 = acs_step(r4[2:0],    r4[5:3],    r4[8:6],    r4[11:9],    rx4[5:4]);

            r6 = acs_tail6(r5[2:0], r5[5:3], r5[8:6], r5[11:9], rx4[3:2]);
            d7 = acs_tail7_dec(r6[2:0], r6[5:3], rx4[1:0]);

            acs4_tail_pruned = {d7, r6[7], r6[6], r5[15:12], r4[15:12]};
        end
    endfunction

    wire [27:0] first4 = acs4_full({INF, INF, INF, 3'd0}, i_data[15:8]);
    wire [10:0] last4  = acs4_tail_pruned(pm_mid, frame_low);

    wire [11:0] pm4_next   = first4[11:0];
    wire [3:0]  dec1_next  = first4[19:16];
    wire [3:0]  dec2_next  = first4[23:20];
    wire [3:0]  dec3_next  = first4[27:24];

    wire [3:0] dec1 = dec123[3:0];
    wire [3:0] dec2 = dec123[7:4];
    wire [3:0] dec3 = dec123[11:8];

    wire [3:0] dec4 = last4[3:0];
    wire [3:0] dec5 = last4[7:4];
    wire [3:0] dec6 = {2'b00, last4[9], last4[8]};
    wire [3:0] dec7 = {3'b000, last4[10]};

    // Traceback from terminated final state s8 = 00.
    // o_data[7] is the first decoded bit in time. o_data[1:0] are tail zeros.
    reg [1:0] s7;
    reg [1:0] s6;
    reg [1:0] s5;
    reg [1:0] s4;
    reg [1:0] s3;
    reg [1:0] s2;
    reg [1:0] s1;
    reg [7:0] decoded_path;

    always @(*) begin
        decoded_path = 8'h00;

        s7 = {1'b0, dec7[0]};
        decoded_path[1] = s7[1];

        s6 = {s7[0], dec6[s7]};
        decoded_path[2] = s6[1];

        s5 = {s6[0], dec5[s6]};
        decoded_path[3] = s5[1];

        s4 = {s5[0], dec4[s5]};
        decoded_path[4] = s4[1];

        s3 = {s4[0], dec3[s4]};
        decoded_path[5] = s3[1];

        s2 = {s3[0], dec2[s3]};
        decoded_path[6] = s2[1];

        s1 = {s2[0], dec1[s2]};
        decoded_path[7] = s1[1];
    end

    // Control registers.  Only handshake state is reset.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy   <= 1'b0;
            o_done <= 1'b0;
        end else begin
            o_done <= 1'b0;

            if (start_decode) begin
                busy <= 1'b1;
            end else if (busy) begin
                busy   <= 1'b0;
                o_done <= 1'b1;
            end
        end
    end

    // Datapath registers intentionally have no reset: they are written before use.
    always @(posedge clk) begin
        if (start_decode) begin
            frame_low <= i_data[7:0];
            pm_mid    <= pm4_next;
            dec123    <= {dec3_next, dec2_next, dec1_next};
        end else if (busy) begin
            o_data <= decoded_path;
        end
    end

endmodule
