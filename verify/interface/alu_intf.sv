import riscv_32i_defs_pkg::*;
import riscv_32i_control_pkg::*;

interface alu_intf;
  alu_op_t alu_op;
  word_t in_a;
  word_t in_b;
  word_t result;
  logic zero;

  modport coverage(input alu_op, in_a, in_b, result, zero);

  function void print(string msg = "");
    $display("[%s] t=%0t alu_op:%0b in_a:%0h in_b:%0h result:%0h zero:%0b",
             msg, $time, alu_op, in_a, in_b, result, zero);
  endfunction
endinterface
