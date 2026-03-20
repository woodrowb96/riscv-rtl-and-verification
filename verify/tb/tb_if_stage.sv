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
  //See the test and generator packages for full details
  if_stage_main_test           test_main;             //fully random branch_targets
  if_stage_branch_corners_test test_branch_corners;   //branch_targets hit corner addresses
  if_stage_oob_misaligned_test test_oob_misaligned;   //test misaligned and OOB PC/branch_targets

  initial begin
    coverage = new();

    test_main           = new(intf, coverage, DEFAULT_TEST_MEM);
    test_branch_corners = new(intf, coverage, DEFAULT_TEST_MEM);
    test_oob_misaligned = new(intf, coverage, DEFAULT_TEST_MEM);

    /********* RUN TESTS ***********/
    // test_main.drv.reset();
    test_main.run(1000);

    // test_branch_corners.drv.reset();
    test_branch_corners.run(500);

    // test_oob_misaligned.drv.reset();
    test_oob_misaligned.run(250);


    /********* PRINT RESULTS ***********/
    test_main.print_results();
    test_branch_corners.print_results();
    test_oob_misaligned.print_results();

    $stop(1);
  end
endmodule
