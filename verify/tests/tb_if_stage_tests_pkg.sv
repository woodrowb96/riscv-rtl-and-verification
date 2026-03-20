package tb_if_stage_tests_pkg;
  import base_test_pkg::*;
  import tb_if_stage_transaction_pkg::*;
  import tb_if_stage_driver_pkg::*;
  import tb_if_stage_monitor_pkg::*;
  import tb_if_stage_generator_pkg::*;
  import tb_if_stage_scoreboard_pkg::*;
  import tb_if_stage_coverage_pkg::*;

  /*=============================== BASE TEST ==================================*/

  virtual class if_stage_base_test #(type GEN_T) extends base_test #(
    if_stage_trans, GEN_T, if_stage_driver, if_stage_monitor, if_stage_scoreboard);

    protected function new(virtual if_stage_intf vif,
                           tb_if_stage_coverage coverage,
                           string program_file,
                           string tag = "IF_STAGE_BASE_TEST"
    );
      super.new(tag);
      gen = new(gen_to_drv_mbx);
      drv = new(vif, "IF_STAGE_DRV", gen_to_drv_mbx);
      mon = new(vif, "IF_STAGE_MON", mon_to_scb_mbx);
      scb = new(coverage, program_file, "IF_STAGE_SCB", mon_to_scb_mbx);
    endfunction
  endclass


  /*=============================== CHILD TESTS ==================================*/
  //See the tb_if_stage_generator_pkg.sv for full details on what sequences
  //are generated for each test

  //Fully_random branch_targets. Branch is slightly weighted toward not taking.
  class if_stage_main_test extends if_stage_base_test #(if_stage_main_test_gen);
    function new(virtual if_stage_intf vif, tb_if_stage_coverage coverage, string program_file);
      super.new(vif, coverage, program_file, "IF_STAGE_MAIN_TEST");
    endfunction
  endclass

  //hit the branch_target corners
  class if_stage_branch_corners_test extends if_stage_base_test #(if_stage_branch_corners_gen);
    function new(virtual if_stage_intf vif, tb_if_stage_coverage coverage, string program_file);
      super.new(vif, coverage, program_file, "IF_STAGE_BRANCH_CORNERS_TEST");
    endfunction
  endclass

  //test OOB and misaligned PC/branch_targets
  class if_stage_oob_misaligned_test extends if_stage_base_test #(if_stage_oob_misaligned_gen);
    function new(virtual if_stage_intf vif, tb_if_stage_coverage coverage, string program_file);
      super.new(vif, coverage, program_file, "IF_STAGE_OOB_MISALIGNED_TEST");
    endfunction
  endclass

endpackage
