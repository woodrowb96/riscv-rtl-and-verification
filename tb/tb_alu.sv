import tb_alu_coverage_pkg::*;
import tb_alu_stimulus_pkg::*;
import alu_ref_model_pkg::*;
import riscv_32i_defs_pkg::*;

module tb_alu();
  /*********** CLK *************/
  //alu is purely comb, but I use a clk to sync testing
  bit clk;
  initial begin
    clk = 0;
    forever #5 clk = ~clk;    //period of #10
  end

  /*********** INTERFACE *************/
  alu_intf intf();

  /*********** DUT *************/
  alu dut(.alu_op(intf.alu_op),
          .in_a(intf.in_a),
          .in_b(intf.in_b),
          .result(intf.result), 
          .zero(intf.zero) 
          );

  /*********** BIND ASSERTIONS *************/
  bind tb_alu.dut alu_assert dut_assert(intf.assertion);

  /*********** COVERAGE *************/
  tb_alu_coverage coverage;

  /*********** TASKS *************/
  task drive(alu_general_trans trans);
    intf.alu_op = trans.alu_op;
    intf.in_a = trans.in_a;
    intf.in_b = trans.in_b;
  endtask

  task monitor(alu_general_trans trans);
    trans.result = intf.result;
    trans.zero = intf.zero;
  endtask

  //reference alu used to score tests
  alu_ref_model ref_alu;

  //keep track of how many tests weve scored, and how many failed
  int num_tests = 0;
  int num_fails = 0;

  //Use the reference model to score a transaction
  task automatic score(alu_general_trans trans);
    bit test_fail = 0;

    //use trans inputs to calc expected values
    expected_output expected = ref_alu.expected(trans.alu_op, trans.in_a, trans.in_b);

    //score out trans outputs
    if(trans.result != expected.result) begin
      $error("FAIL\nIncorect Result\nExpected: %h",expected.result);
      test_fail = 1;
    end
    if(trans.zero != expected.zero) begin
      $error("Zero flag incorect\nexpected: %b", expected.zero);
      test_fail = 1;
    end

    //handle failed tests
    if(test_fail) begin
      num_fails++;
      trans.print();
    end

    num_tests++;
  endtask

  task test(alu_general_trans trans);
      @(posedge clk);
      drive(trans);
      //wait for the inputs to propogate to the outputs
      #1;
      monitor(trans);
      score(trans);
      //collect our coverage
      coverage.sample();
  endtask

  task print_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %d", num_tests);
    $display("Total tests failed: %d", num_fails);
    $display("----------------");
  endtask

  /**************  TESTING ***************************/
  //we are going to need these kinds of transactions for our tests
  alu_logical_op_trans logical_trans;
  alu_add_op_trans add_trans;
  alu_sub_op_trans sub_trans;
  alu_general_trans unconstrained_trans;

  initial begin
    //create coverage and connect it to the interface
    coverage = new(intf.coverage);

    //create the referance alu
    ref_alu = new();

    //create our transactions
    logical_trans = new();
    add_trans = new();
    sub_trans = new();
    unconstrained_trans = new();

    /*************  TEST AND ***************/
    repeat(1000) begin
      assert(logical_trans.randomize() with { alu_op == ALU_AND; });
      test(logical_trans);
    end

    /************   TEST OR *****************/
    repeat(1000) begin
      assert(logical_trans.randomize() with { alu_op == ALU_OR; });
      test(logical_trans);
    end

    /*****************  TEST ADD **************/
    repeat(1000) begin
      assert(add_trans.randomize());
      test(add_trans);
    end

    /************ TEST SUB ****************/
    repeat(1500) begin
      assert(sub_trans.randomize());
      test(sub_trans);
    end

    /************ TEST EVERYTHING COMPLETELY RANDOMIZED ****************/
    repeat(1000) begin
      assert(unconstrained_trans.randomize());
      test(unconstrained_trans);
    end

    /************ TEST INVALID OP ****************/
    assert(unconstrained_trans.randomize());
    unconstrained_trans.alu_op = alu_op_t'(4'b1111);
    test(unconstrained_trans);

    print_results();

    $stop(1);
  end
endmodule
