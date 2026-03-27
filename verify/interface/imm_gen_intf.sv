interface imm_gen_intf(input logic clk);
  word_t inst;
  word_t imm;

  bit valid; //sim only

  clocking cb_drv @(posedge clk);
    default output #1;
    output inst, valid;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input inst, imm, valid;
  endclocking

  modport monitor(input clk, inst, imm);

  function void print(string msg = "");
    $display("[%s] t=%0t inst:%0h imm:%0h", msg, $time, inst, imm);
  endfunction
endinterface
