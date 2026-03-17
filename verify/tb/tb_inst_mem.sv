import rv32i_defs_pkg::*;
import verify_config_pkg::*;
import tb_inst_mem_tests_pkg::*;
import tb_inst_mem_coverage_pkg::*;

module tb_inst_mem();
  localparam CLK_PERIOD = 10;
  localparam DUT_TEST_MEM = INST_MEM_TEST_1;

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  inst_mem_intf intf(.clk);

  /*********** DUT *************/
  inst_mem #(DUT_TEST_MEM) dut(.inst_addr(intf.inst_addr), .inst(intf.inst));

  /*********** BIND ASSERTIONS *************/
  bind tb_inst_mem.dut inst_mem_assert dut_assert(.clk(tb_inst_mem.clk),
                                                  .inst_addr(inst_addr),
                                                  .inst(inst)
                                                  );

  /************ COVERAGE *******************/
  tb_inst_mem_coverage coverage;

  /**************  TESTING ***************************/
  inst_mem_default_test    test_default;    //randomized inst_addr with constraints to hit coverage
  inst_mem_misaligned_test test_misaligned; //test misaligned addresses
  inst_mem_oob_test        test_oob;        //test out of bounds addresses

  initial begin
    coverage = new();

    test_default    = new(intf, coverage, DUT_TEST_MEM);
    test_misaligned = new(intf, coverage, DUT_TEST_MEM);
    test_oob        = new(intf, coverage, DUT_TEST_MEM);

    //run tests
    test_default.run(1000);
    test_misaligned.run(10);
    test_oob.run(10);

    //print results
    test_default.print_results();
    test_misaligned.print_results();
    test_oob.print_results();

    $stop(1);
  end
endmodule
