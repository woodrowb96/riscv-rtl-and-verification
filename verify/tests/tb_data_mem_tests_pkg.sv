package tb_data_mem_tests_pkg;
  import base_test_pkg::*;
  import tb_data_mem_transaction_pkg::*;
  import tb_data_mem_generator_pkg::*;
  import tb_data_mem_driver_pkg::*;
  import tb_data_mem_monitor_pkg::*;
  import tb_data_mem_scoreboard_pkg::*;
  import tb_data_mem_coverage_pkg::*;

  /*=============================== BASE TEST ==================================*/
  virtual class data_mem_base_test #(type GEN_T) extends base_test #(
      data_mem_trans, GEN_T, data_mem_driver, data_mem_monitor, data_mem_scoreboard);

    protected function new(virtual data_mem_intf vif, tb_data_mem_coverage coverage, string tag = "DATA_MEM_BASE_TEST");
      super.new(tag);

      gen = new(gen_to_drv_mbx);
      drv = new(vif, "DATA_MEM_DRV", gen_to_drv_mbx);
      mon = new(vif, "DATA_MEM_MON", mon_to_scb_mbx);
      scb = new(coverage, "DATA_MEM_SCB", mon_to_scb_mbx);
    endfunction
  endclass

  /*=============================== CHILD TESTS ==================================*/

  //default test: exercises all inputs with constrained random values
  //(see the generator for full details on randomization)
  class data_mem_default_test extends data_mem_base_test #(data_mem_default_gen);
    function new(virtual data_mem_intf vif, tb_data_mem_coverage coverage);
      super.new(vif, coverage, "DATA_MEM_DEFAULT_TEST");
    endfunction
  endclass

endpackage
