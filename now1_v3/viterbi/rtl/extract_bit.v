`timescale 1ns/1ps

// Select two 2-bit received symbols per ACS cycle.
//
// state encoding (defined in control.v):
//   3'b000 = IDLE     -> default branch, outputs forced to 00
//   3'b001 = ST_01    -> use rx_reg[15:14], rx_reg[13:12]
//   3'b010 = ST_23    -> use rx_reg[11:10], rx_reg[ 9: 8]
//   3'b011 = ST_45    -> use rx_reg[ 7: 6], rx_reg[ 5: 4]
//   3'b100 = ST_67    -> use rx_reg[ 3: 2], rx_reg[ 1: 0]
//   3'b101 = ST_OUT   -> default branch, outputs forced to 00
//   3'b110/111        -> unused encodings, default branch, outputs 00
//
// Operand-isolation note: for every non-ACS state (IDLE, ST_OUT, and the
// unused encodings 110/111), pair_a and pair_b are driven to 2'b00 via the
// default arm. That keeps the BMU and downstream ACS combinational tree at
// a constant value during those cycles, reducing switching activity in the
// surrounding logic. The decision to isolate is taken locally from `state`;
// this module does not need a separate `active` input.
module extract_bit (
    input  wire [2:0]  state,
    input  wire [15:0] rx_reg,
    output reg  [1:0]  pair_a,
    output reg  [1:0]  pair_b
);

    always @(*) begin
        // Operand-isolation defaults. Applied for IDLE (000), ST_OUT (101),
        // and the unused 110/111 encodings.
        pair_a = 2'b00;
        pair_b = 2'b00;
        case (state)
            3'b001: begin pair_a = rx_reg[15:14]; pair_b = rx_reg[13:12]; end
            3'b010: begin pair_a = rx_reg[11:10]; pair_b = rx_reg[ 9: 8]; end
            3'b011: begin pair_a = rx_reg[ 7: 6]; pair_b = rx_reg[ 5: 4]; end
            3'b100: begin pair_a = rx_reg[ 3: 2]; pair_b = rx_reg[ 1: 0]; end
            default: ; // keep operand-isolation defaults above
        endcase
    end

endmodule

