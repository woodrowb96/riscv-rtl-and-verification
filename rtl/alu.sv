/*
  ALU module for riscv rv32i implementation.

  NOTE: I havent implemented all the operations yet.

Control:
  alu_op  : 4'b alu operation

  ---------ALU CONTROL-----------------
  | ALU_OP  | Function | result       |
  -------------------------------------
  | 0000    | ALU_AND  | in_a & in_b  |
  | 0001    | ALU_OR   | in_a | in_b  |
  | 0010    | ALU_ADD  | in_a + in_b  |
  | 0110    | ALU_SUB  | in_a - in_b  |
  -------------------------------------

Input:
  in_a  :  32'b input a
  in_b  :  32'b input b

Output:
  result  : 32'b result of operation
            - Note: result will output 0 if alu_op is an invalid operation

Output flags:
  zero: 1'b zero flag, set when result == 0
*/
import rv32i_defs_pkg::*;
import rv32i_control_pkg::*;

module alu(
  //control
  input alu_op_t alu_op,

  //input
  input word_t in_a,
  input word_t in_b,

  //output
  output word_t result,

  //output flags
  output logic zero
);

  assign zero = (result == '0);

  always_comb begin
    unique case(alu_op)
      ALU_AND: begin
        result = in_a & in_b;
      end
      ALU_OR: begin
        result = in_a | in_b;
      end
      ALU_ADD: begin
        result = in_a + in_b;
      end
      ALU_SUB: begin
        result = in_a - in_b;
      end
      default: begin
        result = '0;
      end
    endcase
  end

endmodule
