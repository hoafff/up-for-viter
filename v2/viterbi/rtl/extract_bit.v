`timescale 1ns/1ps

// Select two 2-bit received symbols per active cycle.
module extract_bit (
    input  wire [2:0]  state,
    input  wire [15:0] rx_reg,
    output reg  [1:0]  pair_a,
    output reg  [1:0]  pair_b
);

    always @(*) begin
        case (state)
            3'b001: begin pair_a = rx_reg[15:14]; pair_b = rx_reg[13:12]; end
            3'b010: begin pair_a = rx_reg[11:10]; pair_b = rx_reg[ 9: 8]; end
            3'b011: begin pair_a = rx_reg[ 7: 6]; pair_b = rx_reg[ 5: 4]; end
            3'b100: begin pair_a = rx_reg[ 3: 2]; pair_b = rx_reg[ 1: 0]; end
            default: begin pair_a = 2'b00;         pair_b = 2'b00;         end
        endcase
    end

endmodule
