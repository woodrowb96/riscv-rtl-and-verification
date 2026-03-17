package tb_if_stage_generator_pkg;
  import tb_if_stage_transaction_pkg::*;
  import base_generator_pkg::*;

  /*==============================================================================*/
  /*------------------------------ GENERATOR -------------------------------------*/
  /*==============================================================================*/
  class if_stage_default_gen extends base_generator #(if_stage_trans);

    function new(mailbox_t gen_to_drv_mbx);
      super.new("IF_STAGE_DEFAULT_GEN", gen_to_drv_mbx);
    endfunction

    function if_stage_trans gen_trans();
      if_stage_trans trans = new();

      assert(trans.randomize()) else
        $fatal(1, "[%s]: gen_trans() randomization failed, base trans", tag);

      return trans;
    endfunction
  endclass

endpackage
