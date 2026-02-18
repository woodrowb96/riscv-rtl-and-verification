import tb_reg_file_transaction_pkg::*;
import reg_file_ref_model_pkg::*;
import tb_reg_file_coverage_pkg::*;
import riscv_32i_defs_pkg::*;
// `timescale 1ns / 10ps

module tb_reg_file();
  localparam CLK_PERIOD = 10;
  localparam PROPOGATION_DELAY = 3;
  //clock
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /************  INTERFACE ************/
  reg_file_intf intf(clk);

  /************  DUT ************/
  reg_file dut(.clk(clk),
                    .wr_en(intf.wr_en),
                    .rd_reg_1(intf.rd_reg_1),
                    .rd_reg_2(intf.rd_reg_2),
                    .wr_reg(intf.wr_reg),
                    .wr_data(intf.wr_data),
                    .rd_data_1(intf.rd_data_1),
                    .rd_data_2(intf.rd_data_2)
                    );

  /************  BIND ASSERTIONS ************/
  bind tb_reg_file.dut reg_file_assert dut_assert(tb_reg_file.intf);

  /************  COVERAGE ************/
  tb_reg_file_coverage coverage;

  /************  REFERENCE REG_FILE ************/
  reg_file_ref_model ref_reg_file;

  /************  TASKS ************/

  task drive(reg_file_trans trans);
    intf.wr_en <= trans.wr_en;
    intf.wr_reg <= trans.wr_reg;
    intf.wr_data <= trans.wr_data;
    intf.rd_reg_1 <= trans.rd_reg_1;
    intf.rd_reg_2 <= trans.rd_reg_2;
  endtask

  task monitor(reg_file_trans trans);
    trans.rd_data_1 = intf.rd_data_1;
    trans.rd_data_2 = intf.rd_data_2;
  endtask

  int num_tests = 0;
  int num_fails = 0;

  //score test by making sure rd_data matches expected values
  function automatic void score(reg_file_trans actual);
    reg_file_trans expected = new();
    expected.wr_en = actual.wr_en;
    expected.wr_reg = actual.wr_reg;
    expected.wr_data = actual.wr_data;
    expected.rd_reg_1 = actual.rd_reg_1;
    expected.rd_reg_2 = actual.rd_reg_2;

    expected.rd_data_1 = ref_reg_file.read(actual.rd_reg_1);
    expected.rd_data_2 = ref_reg_file.read(actual.rd_reg_2);

    if(!expected.compare(actual)) begin
      $display("----------------");
      $error("REG_FILE_TB: test fail");
      expected.print("EXPECTED");
      actual.print("ACTUAL");
      num_fails++;
    end

    num_tests++;
  endfunction

  task test(reg_file_trans trans);
    drive(trans);
    #PROPOGATION_DELAY      //let the combinatorial reads propogate
    monitor(trans);
    coverage.sample();
    score(trans);

    //clk the writes in and update the ref_model
    @(posedge clk);
    ref_reg_file.update(trans);
  endtask

  task print_test_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %0d", num_tests);
    $display("Total tests failed: %0d", num_fails);
    $display("----------------");
  endtask

  /*********** TESTING ******************/
  reg_file_trans trans;
  initial begin

    coverage = new(intf.monitor);
    ref_reg_file = new();
    trans = new();

    repeat(1000) begin
      assert(trans.randomize());
      test(trans);
    end

    //print results and end simulation
    print_test_results();
    $stop(1);
  end
endmodule
