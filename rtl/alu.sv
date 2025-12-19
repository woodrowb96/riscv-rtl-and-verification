/*
ALU module for single cycle rv32i partial implementation
For this partial implementation I am only implementing AND, OR ADD and SUB operations.

Control:
  alu_op  : 4'b alu operation

  ---------ALU CONTROL-----------------
  | ALU_OP  | Function | result       |
  -------------------------------------
  | 0000    | AND      | in_a & in_b  |
  | 0001    | OR       | in_a | in_b  |
  | 0010    | ADD      | in_a + in_b  |
  | 0110    | SUB      | in_a - in_b  |
  -------------------------------------

Input:
  in_a  :  32'b input a
  in_b  :  32'b input b

Output:
  result  : 32'b result of operation
  zero    : 1'b zero flag
            1 if result == 0, else 0
*/
module alu(
  input logic [3:0] alu_op,

  input logic [31:0] in_a,
  input logic [31:0] in_b,

  output logic [31:0] result,
  output logic zero
);

  // always_comb begin
  //   unique case(alu_op)
  //     4'b0000:
  //       result = in_a & in_b;
  //     4'b0001:
  //       result = in_a | in_b;
  //     4'b0010:
  //       result = in_a + in_b;
  //     4'b0110:
  //       result = in_a - in_b;
  // end

endmodule
