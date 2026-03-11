package tb_imm_gen_tests_pkg;
  import base_test_pkg::*;
  import tb_imm_gen_transaction_pkg::*;
  import tb_imm_gen_generator_pkg::*;
  import tb_imm_gen_driver_pkg::*;
  import tb_imm_gen_monitor_pkg::*;
  import tb_imm_gen_scoreboard_pkg::*;
  import tb_imm_gen_coverage_pkg::*;

  /*=============================== BASE TEST ==================================*/
  virtual class imm_gen_base_test #(type GEN_T) extends base_test #(
      imm_gen_trans, GEN_T, imm_gen_driver, imm_gen_monitor, imm_gen_scoreboard);

    protected function new(virtual imm_gen_intf vif, tb_imm_gen_coverage coverage, string tag = "IMM_GEN_BASE_TEST");
      super.new(tag);

      gen = new(gen_to_drv_mbx);
      drv = new(vif, "IMM_GEN_DRV", gen_to_drv_mbx);
      mon = new(vif, "IMM_GEN_MON", mon_to_scb_mbx);
      scb = new(coverage, "IMM_GEN_SCB", mon_to_scb_mbx);
    endfunction
  endclass

  /*=============================== CHILD TESTS ==================================*/

  //default test: exercises all instruction formats with constrained random values
  //(see the generator for full details on randomization)
  class imm_gen_default_test extends imm_gen_base_test #(imm_gen_default_gen);
    function new(virtual imm_gen_intf vif, tb_imm_gen_coverage coverage);
      super.new(vif, coverage, "IMM_GEN_DEFAULT_TEST");
    endfunction
  endclass

endpackage
