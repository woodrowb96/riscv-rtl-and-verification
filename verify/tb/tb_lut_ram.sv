import rv32i_defs_pkg::*;
import tb_lut_ram_tests_pkg::*;
import tb_lut_ram_coverage_pkg::*;

module tb_lut_ram();
  localparam CLK_PERIOD = 10;
  localparam MEM_DEPTH = 1000;
  localparam MEM_WIDTH = XLEN;

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  lut_ram_intf #(.LUT_WIDTH(MEM_WIDTH), .LUT_DEPTH(MEM_DEPTH)) intf(.clk);

  /*********** DUT *************/
  lut_ram #(.LUT_WIDTH(MEM_WIDTH), .LUT_DEPTH(MEM_DEPTH)) dut (
    .clk(clk),
    .wr_en(intf.wr_en),
    .wr_addr(intf.wr_addr),
    .rd_addr(intf.rd_addr),
    .wr_data(intf.wr_data),
    .rd_data(intf.rd_data)
  );

  /*********** BIND ASSERTIONS *************/
  bind tb_lut_ram.dut lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) dut_assert(.*);

  /************ COVERAGE *******************/
  tb_lut_ram_coverage #(MEM_WIDTH, MEM_DEPTH) coverage;

  /**************  TESTING ***************************/
  lut_ram_default_test #(MEM_WIDTH, MEM_DEPTH) test_default; //test all inputs randomly, with some constraints to hit coverage

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
