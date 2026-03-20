package tb_lut_ram_tests_pkg;
  import base_test_pkg::*;
  import tb_lut_ram_transaction_pkg::*;
  import tb_lut_ram_generator_pkg::*;
  import tb_lut_ram_driver_pkg::*;
  import tb_lut_ram_monitor_pkg::*;
  import tb_lut_ram_scoreboard_pkg::*;
  import tb_lut_ram_coverage_pkg::*;
  import tb_lut_ram_predictor_pkg::*;

  /*=============================== BASE TEST ==================================*/
  virtual class lut_ram_base_test #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256,
    type GEN_T
  ) extends base_test #(
      lut_ram_trans      #(LUT_WIDTH, LUT_DEPTH),
      GEN_T,
      lut_ram_driver     #(LUT_WIDTH, LUT_DEPTH),
      lut_ram_monitor    #(LUT_WIDTH, LUT_DEPTH),
      lut_ram_predictor  #(LUT_WIDTH, LUT_DEPTH),
      lut_ram_scoreboard #(LUT_WIDTH, LUT_DEPTH)
  );

    protected function new(
        virtual lut_ram_intf #(LUT_WIDTH, LUT_DEPTH) vif,
        tb_lut_ram_coverage  #(LUT_WIDTH, LUT_DEPTH) coverage,
        string tag = "LUT_RAM_BASE_TEST"
    );
      super.new(tag);

      gen  = new(gen_to_drv_mbx);
      drv  = new(vif, "LUT_RAM_DRV", gen_to_drv_mbx);
      mon  = new(vif, "LUT_RAM_MON", mon_to_scb_mbx);
      pred = new(vif, "LUT_RAM_PRED", pred_to_scb_mbx);
      scb  = new(coverage, "LUT_RAM_SCB", mon_to_scb_mbx, pred_to_scb_mbx);
    endfunction
  endclass

  /*=============================== CHILD TESTS ==================================*/

  //default test: exercises all inputs with constrained random values
  //(see the generator for full details on randomization)
  class lut_ram_default_test #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
  ) extends lut_ram_base_test #(
    LUT_WIDTH,
    LUT_DEPTH,
    lut_ram_default_gen #(LUT_WIDTH, LUT_DEPTH)
  );

    function new(
      virtual lut_ram_intf #(LUT_WIDTH, LUT_DEPTH) vif,
      tb_lut_ram_coverage #(LUT_WIDTH, LUT_DEPTH) coverage
    );
      super.new(vif, coverage, "LUT_RAM_DEFAULT_TEST");
    endfunction
  endclass

endpackage
