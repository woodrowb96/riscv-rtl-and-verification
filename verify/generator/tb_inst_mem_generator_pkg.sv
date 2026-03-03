package tb_inst_mem_generator_pkg;
  import tb_inst_mem_transaction_pkg::*;

  class tb_inst_mem_generator;

    function inst_mem_trans gen_trans();
      inst_mem_trans trans = new();
      assert(trans.randomize()) else
        $fatal(1, "[TB_INST_MEM_GENERATOR]: gen_trans() randomization failed");
      return trans;
    endfunction
  endclass
endpackage
