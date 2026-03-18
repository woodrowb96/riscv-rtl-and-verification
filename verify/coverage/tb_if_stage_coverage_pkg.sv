package tb_if_stage_coverage_pkg;
  import tb_if_stage_transaction_pkg::*;

  class tb_if_stage_coverage;

    if_stage_trans trans;

    function new();
      this.cg = new();
    endfunction

    function sample(if_stage_trans trans);
      this.trans = trans;
      cg.sample();
    endfunction

    /*==============================  COVERGROUP  =================================*/
    covergroup cg;
    endgroup

  endclass

endpackage
