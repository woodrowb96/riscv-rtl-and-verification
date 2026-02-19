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
import riscv_32i_defs_pkg::*;
import riscv_32i_control_pkg::*;

module alu(
  //control
  input alu_op_t alu_op,     //alu control signal

  //input
  input word_t in_a,
  input word_t in_b,

  //output
  output word_t result,
  output logic zero             // 1 if result == 0, else 0
);

  //zero flag set when result is all 0s
  assign zero = (result == '0);

  always_comb begin
    case(alu_op)
      ALU_AND:
        result = in_a & in_b;
      ALU_OR:
        result = in_a | in_b;
      ALU_ADD:
        result = in_a + in_b;
      ALU_SUB:
        result = in_a - in_b;
      default:
        result = '0;
    endcase
  end

endmodule
