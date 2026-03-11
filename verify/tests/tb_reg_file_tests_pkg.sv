package tb_reg_file_tests_pkg;
  import base_test_pkg::*;
  import tb_reg_file_transaction_pkg::*;
  import tb_reg_file_generator_pkg::*;
  import tb_reg_file_driver_pkg::*;
  import tb_reg_file_monitor_pkg::*;
  import tb_reg_file_scoreboard_pkg::*;
  import tb_reg_file_coverage_pkg::*;

  /*=============================== BASE TEST ==================================*/
  virtual class reg_file_base_test #(type GEN_T) extends base_test #(
      reg_file_trans, GEN_T, reg_file_driver, reg_file_monitor, reg_file_scoreboard);

    protected function new(virtual reg_file_intf vif, tb_reg_file_coverage coverage, string tag = "REG_FILE_BASE_TEST");
      super.new(tag);

      gen = new(gen_to_drv_mbx);
      drv = new(vif, "REG_FILE_DRV", gen_to_drv_mbx);
      mon = new(vif, "REG_FILE_MON", mon_to_scb_mbx);
      scb = new(coverage, "REG_FILE_SCB", mon_to_scb_mbx);
    endfunction
  endclass

  /*=============================== CHILD TESTS ==================================*/

  //test all inputs randomly
  //(see the generator for full details on randomization)
  class reg_file_full_rand_test extends reg_file_base_test #(reg_file_full_rand_gen);
    function new(virtual reg_file_intf vif, tb_reg_file_coverage coverage);
      super.new(vif, coverage, "REG_FILE_FULL_RAND_TEST");
    endfunction
  endclass

endpackage
