import tb_reg_file_stimulus_pkg::*;
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

  //test scoring
  int num_tests = 0;
  int num_fails = 0;

  //reference reg file, to score tests
  reg_file_ref_model ref_reg_file;

  //score test by making sure rd_data matches expected values
  task automatic score(reg_file_trans trans);
    bit test_fail = 0;

    //update the reference model, and get the expected output
    reg_file_output exp;
    exp = ref_reg_file.process_trans(trans);

    //check our reads
    if(trans.rd_data_1 != exp.rd_data_1) begin
      $error("FAIL:Incorrect rd_data_1\n",
              "rd_reg_1: %d, Expected: %h, Actual: %h",
              trans.rd_reg_1, exp.rd_data_1, trans.rd_data_1);
      test_fail = 1;
    end
    if(trans.rd_data_2 != exp.rd_data_2) begin
      $error("FAIL:Incorrect rd_data_2\n",
              "rd_reg_2: %d, Expected: %h, Actual: %h",
              trans.rd_reg_2, exp.rd_data_2, trans.rd_data_2);
      test_fail = 1;
    end

    //handle failed test
    if(test_fail) begin
      num_fails++;
    end

    num_tests++;
  endtask

  task test(reg_file_trans trans);
    @(posedge clk);
    drive(trans);
    #PROPOGATION_DELAY      //wait so the combinatorial reads can propogate
    monitor(trans);
    score(trans);
    coverage.sample();
  endtask

  task print_test_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %d", num_tests);
    $display("Total tests failed: %d", num_fails);
    $display("----------------");
  endtask

  /*********** TESTING ******************/
  reg_file_trans trans;
  initial begin

    coverage = new(intf.monitor);
    ref_reg_file = new();
    trans = new();

    //drive initial values
    intf.wr_en <= '0;             //start out not writing
    intf.wr_reg <= X0;           //pointing wr_reg to x0
    intf.wr_data <= '1; //driving wr_data to all 1s
    intf.rd_reg_1 <= '0;          //reading from x0
    intf.rd_reg_2 <= '0;

    repeat(1000) begin
      trans.randomize();
      test(trans);
    end

    //print results and end simulation
    print_test_results();
    $stop(1);
  end
endmodule
