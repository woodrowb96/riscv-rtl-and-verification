import riscv_32i_defs_pkg::*;

interface inst_mem_intf;
  word_t inst_addr;
  word_t inst;

  modport monitor(input inst_addr, inst);

  function void print(string msg = "");
    $display("[%s] t=%0t inst_addr:%0d inst:%0h", msg, $time, inst_addr, inst);
  endfunction
endinterface
