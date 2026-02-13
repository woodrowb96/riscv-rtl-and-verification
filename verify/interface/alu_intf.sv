import riscv_32i_defs_pkg::*;

interface alu_intf;
  alu_op_t alu_op;
  word_t in_a;
  word_t in_b;
  word_t result;
  logic zero;

  modport coverage(input alu_op, in_a, in_b, result, zero);
  modport assertion(input alu_op, in_a, in_b, result, zero);

  function print(string msg = "");
    $display("-----------------------");
    $display("ALU INTERFACE:%s\n",msg);
    $display("time: %t", $time);
    $display("-----------------------");
    $display("alu_op: %b", alu_op);
    $display("-----------------------");
    $display("in_a: %h", in_a);
    $display("in_b: %h", in_b);
    $display("-----------------------");
    $display("result: %h", result);
    $display("zero: %b", zero);
    $display("-----------------------");
  endfunction
endinterface
