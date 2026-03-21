package tb_if_stage_tests_pkg;
  import base_test_pkg::*;
  import base_reset_detector_pkg::*;
  import tb_if_stage_transaction_pkg::*;
  import tb_if_stage_driver_pkg::*;
  import tb_if_stage_monitor_pkg::*;
  import tb_if_stage_generator_pkg::*;
  import tb_if_stage_scoreboard_pkg::*;
  import tb_if_stage_coverage_pkg::*;
  import tb_if_stage_predictor_pkg::*;

  /*=========================== MID TEST RESET DETECTION ======================*/
  //We are going to be doing mid-test reseting so we need to add detection to the tests

  class if_stage_reset_detector extends base_reset_detector;
    virtual if_stage_intf vif;

    function new(virtual if_stage_intf vif);
      super.new("IF_STAGE_RST_DETECTOR");
      this.vif = vif;
    endfunction

    task detect_reset_assert();
      //keep checking the clock, block until we see asserted reset on a clk edge
      @(posedge vif.clk iff !vif.reset_n);
    endtask

    task detect_reset_deassert();
      //keep checking the clock, block until we see deasserted reset on a clk edge
      @(posedge vif.clk iff vif.reset_n);
    endtask
  endclass


  /*=============================== BASE TEST ==================================*/

  virtual class if_stage_base_test #(type GEN_T) extends base_test #(
    if_stage_trans, GEN_T, if_stage_driver, if_stage_monitor, if_stage_predictor, if_stage_scoreboard);

    virtual if_stage_intf vif;

    protected function new(virtual if_stage_intf vif,
                           tb_if_stage_coverage coverage,
                           string program_file,
                           string tag = "IF_STAGE_BASE_TEST"
    );
      if_stage_reset_detector det;

      super.new(tag);
      gen  = new(gen_to_drv_mbx);
      drv  = new(vif, "IF_STAGE_DRV", gen_to_drv_mbx);
      mon  = new(vif, "IF_STAGE_MON", mon_to_scb_mbx);
      pred = new(vif, program_file, "IF_STAGE_PRED", pred_to_scb_mbx);
      scb  = new(coverage, "IF_STAGE_SCB", mon_to_scb_mbx, pred_to_scb_mbx);

      det = new(vif);
      rst_detect = det;

      this.vif = vif;
    endfunction

    task inject_reset();
      repeat(56) begin
        @(posedge vif.clk);
      end

      @(posedge vif.clk);
      vif.reset_n <= 0;
      @(posedge vif.clk);
      vif.reset_n <= 1;
    endtask

    task handle_reset();
      $display("THIS IS A RESET");
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
