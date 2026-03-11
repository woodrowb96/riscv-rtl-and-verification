import rv32i_defs_pkg::*;
import rv32i_config_pkg::*;
import rv32i_control_pkg::*;
import tb_data_mem_tests_pkg::*;
import tb_data_mem_coverage_pkg::*;

module tb_data_mem();
  localparam CLK_PERIOD = 10;

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  data_mem_intf intf(.clk);

  /*********** DUT *************/
  data_mem dut(.clk(clk),
               .wr_sel(intf.wr_sel),
               .addr(intf.addr),
               .wr_data(intf.wr_data),
               .rd_data(intf.rd_data)
               );

  /*********** BIND ASSERTIONS *************/
  bind tb_data_mem.dut data_mem_assert dut_assert(.*);

  /************ COVERAGE *******************/
  tb_data_mem_coverage coverage;

  /**************  TESTING ***************************/
  data_mem_default_test test_default;

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
