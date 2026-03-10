import rv32i_defs_pkg::*;
import rv32i_control_pkg::*;

interface alu_intf (input logic clk); //alu.sv is purely combinatorial, but well use the clk to synce tests
  alu_op_t alu_op;
  word_t in_a;
  word_t in_b;
  word_t result;
  logic zero;

  clocking cb_drv @(posedge clk);
    default output #1;
    output alu_op, in_a, in_b;
  endclocking

  //well monitor the DUT input and output
  clocking cb_mon @(posedge clk);
    default input #1step;
    input alu_op, in_a, in_b, result, zero;
  endclocking

  // modport coverage(input alu_op, in_a, in_b, result, zero);

  function void print(string msg = "");
    $display("[%s] t=%0t alu_op:%0b in_a:%0h in_b:%0h result:%0h zero:%0b",
             msg, $time, alu_op, in_a, in_b, result, zero);
  endfunction
endinterface
