package tb_imm_gen_generator_pkg;
  import verify_const_pkg::*;
  import tb_imm_gen_transaction_pkg::*;

  class tb_imm_gen_generator;
    function imm_gen_trans gen_trans();
      imm_gen_trans trans = new();
      assert(trans.randomize()) else
        $fatal(1, "[TB_IMM_GEN_GENERATOR]: gen_trans() randomization failed");
      return trans;
    endfunction
  endclass

endpackage
