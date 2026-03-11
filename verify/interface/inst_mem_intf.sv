import rv32i_defs_pkg::*;

interface inst_mem_intf(input logic clk);
  word_t inst_addr;
  word_t inst;

  clocking cb_drv @(posedge clk);
    default output #1;
    output inst_addr;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input inst_addr, inst;
  endclocking

  modport monitor(input clk, inst_addr, inst);

  function void print(string msg = "");
    $display("[%s] t=%0t inst_addr:%0d inst:%0h", msg, $time, inst_addr, inst);
  endfunction
endinterface
