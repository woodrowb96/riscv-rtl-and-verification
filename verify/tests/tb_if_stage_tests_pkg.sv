package tb_if_stage_tests_pkg;
  import base_test_pkg::*;
  import tb_if_stage_transaction_pkg::*;
  import tb_if_stage_driver_pkg::*;
  import tb_if_stage_monitor_pkg::*;
  import tb_if_stage_generator_pkg::*;
  import tb_if_stage_scoreboard_pkg::*;

  /*=============================== BASE TEST ==================================*/

  virtual class if_stage_base_test #(type GEN_T) extends base_test #(
    if_stage_trans, GEN_T, if_stage_driver, if_stage_monitor, if_stage_scoreboard);

    protected function new(virtual if_stage_intf vif,
                           string program_file,
                           string tag = "IF_STAGE_BASE_TEST"
    );
      super.new(tag);
      gen = new(gen_to_drv_mbx);
      drv = new(vif, "IF_STAGE_DRV", gen_to_drv_mbx);
      mon = new(vif, "IF_STAGE_MON", mon_to_scb_mbx);
      scb = new(program_file, "IF_STAGE_SCB", mon_to_scb_mbx);
    endfunction
  endclass


  /*=============================== CHILD TESTS ==================================*/

  class if_stage_default_test extends if_stage_base_test #(if_stage_default_gen);
    function new(virtual if_stage_intf vif, string program_file);
      super.new(vif, program_file, "IF_STAGE_DEFAULT_TEST");
    endfunction
  endclass

endpackage
