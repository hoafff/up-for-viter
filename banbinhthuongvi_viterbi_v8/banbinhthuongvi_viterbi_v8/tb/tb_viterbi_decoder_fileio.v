`timescale 1ns/1ps

module tb_viterbi_decoder_fileio;

    reg         clk;
    reg         rst_n;
    reg         en;
    reg  [15:0] i_data;
    wire [7:0]  o_data;
    wire        o_done;

    integer pass_count;
    integer fail_count;
    integer total_count;

    integer fin;
    integer fout;
    integer r1;
    integer r2;

    reg [15:0] encoded_frame;
    reg [7:0]  expected_data;

    integer cycle_count;

    viterbi_decoder dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .en     (en),
        .i_data (i_data),
        .o_data (o_data),
        .o_done (o_done)
    );

    localparam real CLK_PERIOD = 5.55;  // >=180 MHz target

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2.0) clk = ~clk;
    end

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

    task automatic send_frame;
        input [15:0] frame_in;
        begin
            @(negedge clk);
            i_data = frame_in;
            en     = 1'b1;

            @(negedge clk);
            en     = 1'b0;
        end
    endtask

    task automatic wait_done_and_check;
        input [15:0] frame_in;
        input [7:0]  golden_out;
        begin
            cycle_count = 0;

            while ((o_done !== 1'b1) && (cycle_count < 100)) begin
                @(posedge clk);
                #1;
                cycle_count = cycle_count + 1;
            end

            if (cycle_count >= 100) begin
                $display("[FAIL] Timeout. encoded=%h expected=%h",
                         frame_in, golden_out);
                fail_count = fail_count + 1;
            end
            else begin
                if (o_data !== golden_out) begin
                    $display("[FAIL] Data mismatch. encoded=%h expected=%h got=%h latency=%0d",
                             frame_in, golden_out, o_data, cycle_count);
                    fail_count = fail_count + 1;
                end
                else begin
                    $display("[PASS] encoded=%h decoded=%h latency=%0d",
                             frame_in, o_data, cycle_count);
                    pass_count = pass_count + 1;
                end

                @(posedge clk);
                #1;

                if (o_done !== 1'b0) begin
                    $display("[FAIL] o_done is not 1-cycle. encoded=%h", frame_in);
                    fail_count = fail_count + 1;
                end
            end
        end
    endtask

    initial begin
        pass_count  = 0;
        fail_count  = 0;
        total_count = 0;

        // ============================================================
        // VCD dump for Genus power activity
        // Dump only DUT, not whole testbench
        // ============================================================
        $dumpfile("sim/waves/viterbi_activity.vcd");
        $dumpvars(0, tb_viterbi_decoder_fileio.dut);

        apply_reset();

        fin  = $fopen("Viterbi_input_error.txt",  "r");
        fout = $fopen("Viterbi_output_error.txt", "r");

        if (fin == 0) begin
            $display("[FATAL] Cannot open Viterbi_input_error.txt");
            $finish;
        end

        if (fout == 0) begin
            $display("[FATAL] Cannot open Viterbi_output_error.txt");
            $finish;
        end

        while (!$feof(fin) && !$feof(fout)) begin
            r1 = $fscanf(fin,  "%b\n", encoded_frame);
            r2 = $fscanf(fout, "%b\n", expected_data);

            if ((r1 == 1) && (r2 == 1)) begin
                total_count = total_count + 1;

                send_frame(encoded_frame);
                wait_done_and_check(encoded_frame, expected_data);

                repeat (2) @(posedge clk);
                #1;
            end
        end

        $fclose(fin);
        $fclose(fout);

        $display("============================================================");
        $display("[SUMMARY] TOTAL=%0d PASS=%0d FAIL=%0d",
                 total_count, pass_count, fail_count);
        $display("============================================================");

        if (fail_count == 0)
            $display("[TB RESULT] ALL FILE-BASED TESTS PASSED");
        else
            $display("[TB RESULT] SOME FILE-BASED TESTS FAILED");

        #20;
        $finish;
    end

endmodule


