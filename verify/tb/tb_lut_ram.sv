import riscv_32i_defs_pkg::*;
import tb_lut_ram_stimulus_pkg::*;
import lut_ram_ref_model_pkg::*;
import tb_lut_ram_coverage_pkg::*;

module tb_lut_ram();
  localparam CLK_PERIOD = 10;
  localparam MEM_DEPTH = 256;
  localparam MEM_WIDTH = XLEN;
  typedef lut_ram_trans #(MEM_WIDTH, MEM_DEPTH) trans_t;

  //clk
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /************ INTERFACE ***********/
  lut_ram_intf #(.LUT_WIDTH(MEM_WIDTH), .LUT_DEPTH(MEM_DEPTH)) intf(clk);

  /**********  DUT ***************/
  lut_ram #(.LUT_WIDTH(MEM_WIDTH), .LUT_DEPTH(MEM_DEPTH)) dut (.clk(intf.clk),
                                                                .wr_en(intf.wr_en),
                                                                .wr_addr(intf.wr_addr),
                                                                .rd_addr(intf.rd_addr),
                                                                .wr_data(intf.wr_data),
                                                                .rd_data(intf.rd_data)
                                                              );
  /********  COVERAGE **************************/
  tb_lut_ram_coverage #(MEM_WIDTH, MEM_DEPTH) coverage;

  /*********  LUT REFERENCE MODEL ***************/
  lut_ram_ref_model #(MEM_WIDTH, MEM_DEPTH) ref_lut_ram;

  /********** TASKS ***********/

  task drive(trans_t trans);
    intf.wr_en <= trans.wr_en;
    intf.wr_addr <= trans.wr_addr;
    intf.rd_addr <= trans.rd_addr;
    intf.wr_data <= trans.wr_data;
  endtask

  task monitor(trans_t trans);
    trans.rd_data = intf.rd_data;
  endtask

  int num_tests = 0;
  int num_fails = 0;

  function automatic void score(trans_t actual);
    trans_t expected = new();
    expected.wr_en = actual.wr_en;
    expected.wr_addr = actual.wr_addr;
    expected.rd_addr = actual.rd_addr;
    expected.wr_data = actual.wr_data;

    expected.rd_data = ref_lut_ram.read(actual.rd_addr);

    if(!expected.compare(actual)) begin
      $display("----------------");
      $error("LUT_RAM_TB: test fail");
      expected.print("EXPECTED");
      actual.print("ACTUAL");
      num_fails++;
    end

    num_tests++;
  endfunction

  //test with same cycle reads.
  //Output is monitored BEFORE wr_data has been clocked into the dut
  task test_monitor_before_write(trans_t trans);
    drive(trans);               //drive the inputs
    #1                          //let rd_addr propogate to rd_data
    monitor(trans);             //monitor and score the combinatorial reads, before next clk edge
    score(trans);
    @(posedge clk)              //clk the wr_data into memory, update the reference model with the new writes
    ref_lut_ram.update(trans);
  endtask

  //test with next cycle reads.
  //Output is monitored AFTER wr_data has been clocked into the dut
  task test_monitor_after_write(trans_t trans);
    drive(trans);                //drive the inputs
    @(posedge clk)               //clk the wr_data into memory, update the reference model with the new writes
    ref_lut_ram.update(trans);
    #1                           //let the combinatorial outputs settle
    monitor(trans);              //monitor and score the combinatorial reads AFTER the writes were written in
    score(trans);
  endtask

  function void print_test_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %0d", num_tests);
    $display("Total tests failed: %0d", num_fails);
    $display("----------------");
  endfunction

  /************  TESTING ********/
  trans_t trans;

  initial begin
    ref_lut_ram = new();
    coverage = new(intf.monitor);
    trans = new();

    coverage.start();

    for(int i = 0; i < 1000; i++) begin
      assert(trans.randomize());
      test_monitor_before_write(trans);
    end

    coverage.stop();

    print_test_results();

    $stop(1);
  end
endmodule
