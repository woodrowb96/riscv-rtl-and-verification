interface imm_gen_intf;
  word_t inst;
  word_t imm;

  modport monitor(input inst, imm);

  function void print(string msg = "");
    $display("[%s] t=%0t inst:%0h imm:%0h", msg, $time, inst, imm);
  endfunction
endinterface
