import tb_reg_file_tests_pkg::*;
import tb_reg_file_coverage_pkg::*;

module tb_reg_file();
  localparam CLK_PERIOD = 10;

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  reg_file_intf intf(.clk);

  /*********** DUT *************/
  reg_file dut(.clk(clk),
              .wr_en(intf.wr_en),
              .rd_reg_1(intf.rd_reg_1),
              .rd_reg_2(intf.rd_reg_2),
              .wr_reg(intf.wr_reg),
              .wr_data(intf.wr_data),
              .rd_data_1(intf.rd_data_1),
              .rd_data_2(intf.rd_data_2)
              );

  /*********** BIND ASSERTIONS *************/
  bind tb_reg_file.dut reg_file_assert dut_assert(.*);

  /************ COVERAGE *******************/
  tb_reg_file_coverage coverage;

  /**************  TESTING ***************************/
  //test all inputs randomly, with some constraints to hit coverage
  reg_file_default_test test_default;

  initial begin
    coverage = new();

    test_default = new(intf, coverage);

    //run tests
    test_default.run(2000);

    //print results
    test_default.print_results();

    $stop(1);
  end
endmodule
