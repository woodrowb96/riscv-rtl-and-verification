import rv32i_defs_pkg::*;
import rv32i_config_pkg::*;
import rv32i_control_pkg::*;
import tb_data_mem_transaction_pkg::*;
import data_mem_ref_model_pkg::*;
import tb_data_mem_coverage_pkg::*;
import tb_data_mem_generator_pkg::*;

module tb_data_mem();
  localparam int CLK_PERIOD = 10;
  localparam int PROPOGATION_DELAY = 3;

  //clk
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /************** INTERFACE *********/
  data_mem_intf intf(clk);

  /********* DUT ***********/
  data_mem dut(.clk(clk),
                .wr_sel(intf.wr_sel),
                .addr(intf.addr),
                .wr_data(intf.wr_data),
                .rd_data(intf.rd_data)
              );

  /********** BIND ASSERTIONS ****************/
  bind tb_data_mem.dut data_mem_assert dut_assert(.*);

  /***********  COVERAGE *********************/
  tb_data_mem_coverage coverage;

  /********* DATA MEM REFERENCE MODEL *********/
  data_mem_ref_model ref_data_mem;

  /*************  TASKS *********************/
  task drive(data_mem_trans trans);
    intf.wr_sel <= trans.wr_sel;
    intf.addr <= trans.addr;
    intf.wr_data <= trans.wr_data;
  endtask

  task monitor(data_mem_trans trans);
    trans.rd_data = intf.rd_data;
  endtask

  task test(data_mem_trans trans);
    drive(trans);
    #PROPOGATION_DELAY
    monitor(trans);
    score(trans);

    //clk the writes into mem, and update the referance
    @(posedge clk);
    ref_data_mem.update(trans);
  endtask


  int num_tests = 0;
  int num_fails = 0;

  function automatic void score(data_mem_trans actual);
    data_mem_trans expected = new();
    expected.wr_sel = actual.wr_sel;
    expected.addr = actual.addr;
    expected.wr_data = actual.wr_data;

    expected.rd_data = ref_data_mem.read(actual.addr);

    if(!expected.compare(actual)) begin
      $display("----------------");
      $error("DATA_MEM_TB: test fail");
      expected.print("EXPECTED");
      actual.print("ACTUAL");
      num_fails++;
    end

    num_tests++;
  endfunction

  function void print_test_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %0d", num_tests);
    $display("Total tests failed: %0d", num_fails);
    $display("----------------");
  endfunction

  /************* TESTING ***************/
  tb_data_mem_generator generator;

  initial begin
    coverage = new(intf.monitor);
    ref_data_mem = new();
    generator = new();

    coverage.start();

    repeat(1000) begin
      test(generator.gen_trans());
    end

    coverage.stop();

    print_test_results();

    $stop(1);
  end

endmodule

