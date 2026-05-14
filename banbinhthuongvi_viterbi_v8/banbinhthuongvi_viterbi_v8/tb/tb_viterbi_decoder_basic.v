`timescale 1ns/1ps

module tb_viterbi_decoder_basic;

    reg         clk;
    reg         rst_n;
    reg         en;
    reg  [15:0] i_data;
    wire [7:0]  o_data;
    wire        o_done;

    integer pass_count;
        integer fail_count;

        localparam integer EXPECTED_LATENCY = 1;

        // -------------------------------------------- -----------------------------
        // DUT
        // -------------------------------------------------------------------------
        viterbi_decoder dut (
            .clk   (clk),
            .rst_n (rst_n),
            .en    (en),
            .i_data(i_data),
            .o_data(o_data),
            .o_done(o_done)
        );

        // -------------------------------------------------------------------------
        //3.00 ns clock = 333.33 MHz
        // -------------------------------------------------------------------------
        localparam real CLK_PERIOD = 5.55;  // >=180 MHz target

        initial begin
            clk = 1'b0;
            forever #(CLK_PERIOD/2.0) clk = ~clk;
        end

        // -------------------------------------------------------------------------
        // Reference convolutional encoder
        //
        // Convention:
        //   src[7] is the first bit in time
        //   first encoded pair goes to i_data[15:14]
        // -------------------------------------------------------------------------
        function [15:0] ref_encode;
            input [7:0] src;
        integer k;
        reg s0, s1;
        reg u;
        reg out1, out2;
        begin
            ref_encode = 16'h0000;
            s0 = 1'b0;
            s1 = 1'b0;

            for (k = 0; k < 8; k = k + 1) begin
                u    = src[7-k];      // MSB is first bit in time
                out1 = u ^ s0 ^ s1;  // g1 = 111
                out2 = u ^ s1;       // g2 = 101

                ref_encode[15 - 2*k -: 2] = {out1, out2};

                s1 = s0;
                s0 = u;
            end
        end
    endfunction

    // -------------------------------------------------------------------------
    // Reset task
    // -------------------------------------------------------------------------
    task automatic apply_reset;
        begin
            rst_n  = 1'b0;
            en     = 1'b0;
            i_data = 16'h0000;

            repeat (3) @(posedge clk);
            #1;
            rst_n = 1'b1;

            repeat (2) @(posedge clk);
            #1;
        end
    endtask

    // -------------------------------------------------------------------------
    // Send one encoded frame, en pulse = 1 cycle
    // -------------------------------------------------------------------------
    task automatic send_frame;
        input [15:0] encoded_frame;
        begin
            @(negedge clk);
            i_data = encoded_frame;
            en     = 1'b1;

            @(negedge clk);
            en     = 1'b0;
        end
    endtask

    // -------------------------------------------------------------------------
    // Wait for done, check exact latency and output data
    //
    // For v6, o_done is asserted one cycle after send_frame returns because
    // the decoder performs two 4-stage ACS passes over two cycles.
    // -------------------------------------------------------------------------
    task automatic wait_done_and_check;
        input [7:0]  expected_data;
        input [15:0] encoded_frame;
        integer cycle_count;
        begin
            cycle_count = 0;

            while ((o_done !== 1'b1) && (cycle_count < 200)) begin
                @(posedge clk);
                #1;
                cycle_count = cycle_count + 1;
            end

            if (cycle_count >= 200) begin
                $display("[FAIL] Timeout waiting o_done. encoded=%h expected=%h",
                         encoded_frame, expected_data);
                fail_count = fail_count + 1;
            end
            else begin
                if (cycle_count !== EXPECTED_LATENCY) begin
                    $display("[FAIL] Latency mismatch. encoded=%h expected_latency=%0d got=%0d",
                             encoded_frame, EXPECTED_LATENCY, cycle_count);
                    fail_count = fail_count + 1;
                end

                if (o_data !== expected_data) begin
                    $display("[FAIL] Data mismatch. encoded=%h expected=%h got=%h",
                             encoded_frame, expected_data, o_data);
                    fail_count = fail_count + 1;
                end
                else if (cycle_count === EXPECTED_LATENCY) begin
                    $display("[PASS] encoded=%h decoded=%h latency=%0d",
                             encoded_frame, o_data, cycle_count);
                    pass_count = pass_count + 1;
                end

                // o_done must be exactly 1 cycle
                @(posedge clk);
                #1;
                if (o_done !== 1'b0) begin
                    $display("[FAIL] o_done is not a 1-cycle pulse. encoded=%h",
                             encoded_frame);
                    fail_count = fail_count + 1;
                end
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Run one testcase from 8-bit source data
    // -------------------------------------------------------------------------
    task automatic run_case;
        input [7:0] src_data;
        reg   [15:0] encoded_frame;
        begin
            encoded_frame = ref_encode(src_data);

            $display("------------------------------------------------------------");
            $display("[INFO] src_data=%h encoded_frame=%h", src_data, encoded_frame);

            send_frame(encoded_frame);
            wait_done_and_check(src_data, encoded_frame);

            repeat (2) @(posedge clk);
            #1;
        end
    endtask

    // -------------------------------------------------------------------------
    // Main test sequence
    // -------------------------------------------------------------------------
    initial begin
        pass_count = 0;
        fail_count = 0;

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_viterbi_decoder_basic);

        apply_reset();

        // Smoke tests for terminated frames: the last two source bits are tail 0s.
        run_case(8'h00);
        run_case(8'hFC);
        run_case(8'hA8);
        run_case(8'h54);
        run_case(8'h80);
        run_case(8'h3C);

        $display("============================================================");
        $display("[SUMMARY] PASS=%0d FAIL=%0d", pass_count, fail_count);
        $display("============================================================");

        if (fail_count == 0)
            $display("[TB RESULT] ALL SMOKE TESTS PASSED");
        else
            $display("[TB RESULT] SOME TESTS FAILED");

        #20;
        $finish;
    end

endmodule

