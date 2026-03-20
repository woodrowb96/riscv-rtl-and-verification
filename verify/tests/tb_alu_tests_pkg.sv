package tb_alu_tests_pkg;
  import base_test_pkg::*;
  import tb_alu_transaction_pkg::*;
  import tb_alu_generator_pkg::*;
  import tb_alu_driver_pkg::*;
  import tb_alu_monitor_pkg::*;
  import tb_alu_scoreboard_pkg::*;
  import tb_alu_coverage_pkg::*;
  import tb_alu_predictor_pkg::*;

  /*=============================== BASE TEST ==================================*/
  virtual class alu_base_test #(type GEN_T) extends base_test #(
      alu_trans, GEN_T, alu_driver, alu_monitor, alu_predictor, alu_scoreboard);

    protected function new(virtual alu_intf vif, alu_coverage coverage, string tag = "ALU_BASE_TEST");
      super.new(tag);

      gen  = new(gen_to_drv_mbx);
      drv  = new(vif, "ALU_DRV", gen_to_drv_mbx);
      mon  = new(vif, "ALU_MON", mon_to_scb_mbx);
      pred = new(vif, "ALU_PRED", pred_to_scb_mbx);
      scb  = new(coverage, "ALU_SCB", mon_to_scb_mbx, pred_to_scb_mbx);
    endfunction
  endclass

  /*=============================== CHILD TESTS ==================================*/

  //default test: exercises all operations with constrained random inputs
  //(see the generator for full details on randomization)
  class alu_default_test extends alu_base_test #(alu_default_gen);
    function new(virtual alu_intf vif, alu_coverage coverage);
      super.new(vif, coverage, "ALU_DEFAULT_TEST");
    endfunction
  endclass

  //walk through all combos of corners and do the operation
  class alu_add_corner_walk_test extends alu_base_test #(alu_add_corner_walk_gen);
    function new(virtual alu_intf vif, alu_coverage coverage);
      super.new(vif, coverage, "ALU_ADD_CORNER_WALK_TEST");
    endfunction
  endclass

  //walk through all combos of corners and do the operation
  class alu_sub_corner_walk_test extends alu_base_test #(alu_sub_corner_walk_gen);
    function new(virtual alu_intf vif, alu_coverage coverage);
      super.new(vif, coverage, "ALU_SUB_CORNER_WALK_TEST");
    endfunction
  endclass

  //gen only invalid ops and test
  class alu_invalid_op_test extends alu_base_test #(alu_invalid_op_gen);
    function new(virtual alu_intf vif, alu_coverage coverage);
      super.new(vif, coverage, "ALU_INVALID_OP_TEST");
    endfunction
  endclass

endpackage
