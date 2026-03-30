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
  class if_stage_base_reset extends base_reset;
    virtual if_stage_intf vif;

    int count = 0;

    function new(virtual if_stage_intf vif, string tag = "IF_STAGE_BASE_RESET");
      super.new(tag);
      this.vif = vif;
    endfunction

    task pre_run();
      @(vif.cb_drv);
      vif.cb_drv.reset_n <= 0;
    endtask

    task post_run();
      @(vif.cb_drv);
      vif.cb_drv.reset_n <= 0;
    endtask

    task assert_rst();
      @(vif.cb_drv)                     //make sure reset is deasserted
      vif.cb_drv.reset_n <= 1;

      if(count < 3) begin
        repeat(10) @(vif.cb_drv);
        vif.cb_drv.reset_n <= 0;
        count++;
      end
      else begin
        wait(0);
      end
    endtask;

    task deassert_rst();
      //Nothing we dont use this task to deasert the reset
      //The if_stages pc will start incrementing on the first clk cycle after
      //rst is deasserted. To make sure re resetart testing at pc = 0, not pc = 4
      //we will just let this task fall through and use the start of
      //rst_assert to deassert the reset.
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
      gen.reset_state();
      pred.ref_if_stage.reset();
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
