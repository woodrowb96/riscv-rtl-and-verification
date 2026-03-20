package tb_inst_mem_tests_pkg;
  import base_test_pkg::*;
  import tb_inst_mem_transaction_pkg::*;
  import tb_inst_mem_generator_pkg::*;
  import tb_inst_mem_driver_pkg::*;
  import tb_inst_mem_monitor_pkg::*;
  import tb_inst_mem_scoreboard_pkg::*;
  import tb_inst_mem_coverage_pkg::*;
  import tb_inst_mem_predictor_pkg::*;

  /*=============================== BASE TEST ==================================*/
  virtual class inst_mem_base_test #(type GEN_T) extends base_test #(
      inst_mem_trans, GEN_T, inst_mem_driver, inst_mem_monitor, inst_mem_predictor, inst_mem_scoreboard);

    protected function new(virtual inst_mem_intf vif, tb_inst_mem_coverage coverage,
                           string program_file, string tag = "INST_MEM_BASE_TEST");
      super.new(tag);

      gen  = new(gen_to_drv_mbx);
      drv  = new(vif, "INST_MEM_DRV", gen_to_drv_mbx);
      mon  = new(vif, "INST_MEM_MON", mon_to_scb_mbx);
      pred = new(vif, program_file, "INST_MEM_PRED", pred_to_scb_mbx);
      scb  = new(coverage, "INST_MEM_SCB", mon_to_scb_mbx, pred_to_scb_mbx);
    endfunction
  endclass

  /*=============================== CHILD TESTS ==================================*/

  //default test: exercises aligned, in-bound addresses with constrained random values
  //(see the generator for full details on randomization)
  class inst_mem_default_test extends inst_mem_base_test #(inst_mem_default_gen);
    function new(virtual inst_mem_intf vif, tb_inst_mem_coverage coverage, string program_file);
      super.new(vif, coverage, program_file, "INST_MEM_DEFAULT_TEST");
    endfunction
  endclass

  //test misaligned addresses (non-zero byte offset)
  class inst_mem_misaligned_test extends inst_mem_base_test #(inst_mem_misaligned_gen);
    function new(virtual inst_mem_intf vif, tb_inst_mem_coverage coverage, string program_file);
      super.new(vif, coverage, program_file, "INST_MEM_MISALIGNED_TEST");
    endfunction
  endclass

  //test out of bounds addresses
  class inst_mem_oob_test extends inst_mem_base_test #(inst_mem_oob_gen);
    function new(virtual inst_mem_intf vif, tb_inst_mem_coverage coverage, string program_file);
      super.new(vif, coverage, program_file, "INST_MEM_OOB_TEST");
    endfunction
  endclass

endpackage
