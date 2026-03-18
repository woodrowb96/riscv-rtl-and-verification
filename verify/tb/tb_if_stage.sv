import tb_if_stage_tests_pkg::*;
import verify_config_pkg::*;
import tb_if_stage_coverage_pkg::*;

module tb_if_stage();
  localparam CLK_PERIOD = 10;
  localparam DEFAULT_TEST_MEM = INST_MEM_TEST_1;

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /********* INTERFACE *********/
  if_stage_intf intf(clk);

  /*********** DUT ***********/
  if_stage #(DEFAULT_TEST_MEM) dut(.clk(clk),
                                   .reset_n(intf.reset_n),
                                   .branch(intf.branch),
                                   .branch_target(intf.branch_target),
                                   .pc(intf.pc),
                                   .inst(intf.inst)
  );

  /******* COVERAGE *************/
  tb_if_stage_coverage  coverage;

  /********** TESTING ********************/
  if_stage_default_test test_default;

  initial begin
    coverage = new();

    test_default = new(intf, coverage, DEFAULT_TEST_MEM);

    //run tests
    test_default.drv.reset();
    test_default.run(1000);

    //print results
    test_default.print_results();

    $stop(1);
  end
endmodule
