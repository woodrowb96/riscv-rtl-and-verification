import rv32i_defs_pkg::*;

interface if_stage_intf (input logic clk);
  //DUT reset (syncronous)
  logic reset_n;
  //DUT control
  logic branch;
  //DUT input
  word_t branch_target;
  //DUT output
  word_t pc;
  word_t inst;

  clocking cb_drv @(posedge clk);
    default output #1;
    output branch, branch_target, reset_n;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input branch, branch_target, pc, inst;
  endclocking

  function void print(string msg = "");
    $display("[%s] t=%0t branch:%b branch_target:%0d pc:%0d inst:%h",
             msg, $time, branch, branch_target, pc, inst);
  endfunction
endinterface
