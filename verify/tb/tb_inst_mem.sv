import riscv_32i_defs_pkg::*;
import verify_config_pkg::*;
import tb_inst_mem_transaction_pkg::*;
import inst_mem_ref_model_pkg::*;
import tb_inst_mem_generator_pkg::*;

module tb_inst_mem();
  localparam CLK_PERIOD = 10;
  localparam PROPOGATION_DELAY = 1;

  //clk
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /******* INTERFACE ***********/
  inst_mem_intf intf();

  /******  DUT *************/
  inst_mem #(INST_MEM_TEST_0) dut(.inst_addr(intf.inst_addr), .inst(intf.inst));
  
  /****** REF_MODEL *********/

  inst_mem_ref_model ref_inst_mem;

  /********* TASKS ***********/
  task drive(inst_mem_trans trans);
    intf.inst_addr = trans.inst_addr;
  endtask

  task monitor(inst_mem_trans trans);
    trans.inst = intf.inst;
  endtask

  int num_tests = 0;
  int num_fails = 0;

  function automatic void score(inst_mem_trans actual);
    inst_mem_trans expected = new();
    expected.inst_addr = actual.inst_addr;

    expected.inst = ref_inst_mem.read(actual.inst_addr);

    if(!expected.compare(actual)) begin
      $display("----------------");
      $error("INST_MEM_TB: test fail");
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

  task test(inst_mem_trans trans);
    drive(trans);
    #PROPOGATION_DELAY
    monitor(trans);
    score(trans);
    @(posedge clk);
  endtask

  /*********** TESTING **************/
  tb_inst_mem_generator gen;

  initial begin
    gen = new();

    ref_inst_mem = new(INST_MEM_TEST_0);

    repeat(1000) begin
      test(gen.gen_trans());
    end

    print_test_results();

    $stop(1);
  end


endmodule
