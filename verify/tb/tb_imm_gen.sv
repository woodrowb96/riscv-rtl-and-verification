import rv32i_defs_pkg::*;
import tb_imm_gen_tests_pkg::*;
import tb_imm_gen_coverage_pkg::*;

module tb_imm_gen();
  localparam CLK_PERIOD = 10;

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  imm_gen_intf intf(.clk);

  /*********** DUT *************/
  imm_gen dut(.inst(intf.inst), .imm(intf.imm));

  /*********** BIND ASSERTIONS *************/
  bind tb_imm_gen.dut imm_gen_assert dut_assert(.tb_clk(tb_imm_gen.clk),
                                                .inst(inst),
                                                .imm(imm)
                                                );

  /************ COVERAGE *******************/
  tb_imm_gen_coverage coverage;

  /**************  TESTING ***************************/
  imm_gen_default_test test_default;

  initial begin
    coverage = new();

    test_default = new(intf, coverage);

    //run tests
    test_default.run(1000);

    //print results
    test_default.print_results();

    $stop(1);
  end
endmodule
