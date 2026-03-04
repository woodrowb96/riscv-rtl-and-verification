import riscv_32i_defs_pkg::*;
import verify_config_pkg::*;
import tb_inst_mem_transaction_pkg::*;
import inst_mem_ref_model_pkg::*;
import tb_inst_mem_generator_pkg::*;
import tb_inst_mem_coverage_pkg::*;

module tb_inst_mem();
  localparam CLK_PERIOD = 10;
  localparam DUT_TEST_MEM = INST_MEM_TEST_1;

  //clk
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /******* INTERFACE ***********/
  inst_mem_intf intf();

  /******  DUT *************/
  inst_mem #(DUT_TEST_MEM) dut(.inst_addr(intf.inst_addr), .inst(intf.inst));

  /***** BIND ASSERTIONS *****/
  //hook up the testbench clk to the clk, then connect the rest of dut ports
  bind tb_inst_mem.dut inst_mem_assert dut_assert(.clk(tb_inst_mem.clk),
                                                  .inst_addr(inst_addr),
                                                  .inst(inst)
                                                  );
  /******* COVERAGE ************/
  tb_inst_mem_coverage coverage;

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
    @(posedge clk);
    monitor(trans);
    score(trans);
    coverage.sample();
  endtask

  /*********** TESTING **************/
  tb_inst_mem_generator gen;

  initial begin
    coverage = new(intf.monitor);
    gen = new();

    ref_inst_mem = new(DUT_TEST_MEM);

    //run the main test
    repeat(1000) begin
      test(gen.gen_trans());
    end

    //test misaligned addresses (so addresses with non-zero byte offset)
    repeat(10) begin
      test(gen.gen_misaligned_trans());
    end

    //test out of bounds addresses
    repeat(10) begin
      test(gen.gen_oob_trans());
    end

    print_test_results();

    $stop(1);
  end


endmodule
