import rv32i_defs_pkg::*;
import tb_imm_gen_transaction_pkg::*;

module tb_imm_gen();
  localparam CLK_PERIOD = 10;

  /********* CLK ********/
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /********** INTERFACE ********/
  imm_gen_intf intf();

  /******* DUT ***********/
  imm_gen dut(.inst(intf.inst), .imm(intf.imm));

  /************* TASKS *************/

  task drive(imm_gen_trans trans);
    intf.inst = trans.inst;
  endtask

  task monitor(imm_gen_trans trans);
    trans.imm = intf.imm;
  endtask

  int num_tests = 0;
  int num_fails = 0;

  function automatic void score(imm_gen_trans actual);
    imm_gen_trans expected = new();
    expected.inst = actual.inst;

    // TO DO:
    //   Havent written the ref_model yet, so cant get expected.imm
    //   Will just print the actual trans to examine for now
    actual.print("ACTUAL");

    // if(!expected.compare(actual)) begin
    //   $display("----------------");
    //   $error("IMM_GEN_TB: test fail");
    //   expected.print("EXPECTED");
    //   actual.print("ACTUAL");
    //   num_fails++;
    // end
    //

    num_tests++;
  endfunction

  task test(imm_gen_trans trans);
    drive(trans);
    @(posedge clk);    //wait till clk edge, to sync the tests and let output settle
    monitor(trans);
    score(trans);
  endtask

  function void print_test_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %0d", num_tests);
    $display("Total tests failed: %0d", num_fails);
    $display("----------------");
  endfunction

  /**************  TESTS **************/
  imm_gen_trans trans;

  initial begin
    trans = new();

    repeat(10) begin
      assert(trans.randomize());
      test(trans);
    end

    print_test_results();

    $stop(1);
  end

endmodule
