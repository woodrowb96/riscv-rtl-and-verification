package tb_if_stage_tests_pkg;
  import base_test_pkg::*;
  import base_reset_pkg::*;
  import tb_if_stage_transaction_pkg::*;
  import tb_if_stage_driver_pkg::*;
  import tb_if_stage_monitor_pkg::*;
  import tb_if_stage_generator_pkg::*;
  import tb_if_stage_scoreboard_pkg::*;
  import tb_if_stage_coverage_pkg::*;
  import tb_if_stage_predictor_pkg::*;

  /*============================ RESET ================================*/

  //This is the base reset class that most tests will use. This class will
  //just reset the DUT before and after testing, but will not assert any reset
  //mid-testing.
  class if_stage_base_reset extends base_reset;
    virtual if_stage_intf vif;

    function new(virtual if_stage_intf vif, string tag = "IF_STAGE_BASE_RESET");
      super.new(tag);
      this.vif = vif;
    endfunction

    //NOTE:
    //  - PC will start incrementing as soon as reset is deaserted. If we
    //  deasserted the reset in pre_run, the PC would start incrementing
    //  before the first transaction of testing is driven. This means testing
    //  would start at PC = 4, not PC = 0. To make sure we dont start
    //  incrementing early, we wait to deassert the reset until the first clk
    //  of testing (see assert_rst())
    task pre_run();
      @(vif.cb_drv);
      vif.cb_drv.reset_n <= 0;
    endtask

    task post_run();
      @(vif.cb_drv);
      vif.cb_drv.reset_n <= 0;
    endtask

    task assert_rst();
      @(vif.cb_drv)              //Bring the DUT out of reset at the start of testing
      vif.cb_drv.reset_n <= 1;
      wait(0);                   //then block the rest of testing, we dont want any mid-test resets
    endtask;

    task deassert_rst();
      //Empty we dont assert any mid-test resets so we dont need to deassert any
    endtask
  endclass

  /*=============================== BASE TEST ==================================*/

  virtual class if_stage_base_test #(type GEN_T) extends base_test #(
    if_stage_trans, GEN_T, if_stage_driver, if_stage_monitor, if_stage_predictor, if_stage_scoreboard);

    protected function new(virtual if_stage_intf vif,
                           tb_if_stage_coverage coverage,
                           string program_file,
                           string tag = "IF_STAGE_BASE_TEST"
    );
      if_stage_base_reset if_stage_rst;

      super.new(tag);
      gen  = new(gen_to_drv_mbx);
      drv  = new(vif, "IF_STAGE_DRV", gen_to_drv_mbx);
      mon  = new(vif, "IF_STAGE_MON", mon_to_scb_mbx);
      pred = new(vif, program_file, "IF_STAGE_PRED", pred_to_scb_mbx);
      scb  = new(coverage, "IF_STAGE_SCB", mon_to_scb_mbx, pred_to_scb_mbx);

      if_stage_rst = new(vif);
      rst = if_stage_rst;
    endfunction

    task handle_reset();
      $display("RESET DETECTED");
      gen.reset_state();            //Reset the generator state
      pred.ref_if_stage.reset();    //Reset the ref_model
    endtask

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
