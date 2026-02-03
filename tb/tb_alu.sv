import tb_alu_coverage_pkg::*;
import tb_alu_stimulus_pkg::*;
import alu_ref_model_pkg::*;
// `timescale 1ns / 1ns

module tb_alu();
  alu_intf intf();

  //Drive transaction into dut
  task drive(general_trans trans);
    intf.alu_op = trans.alu_op;
    intf.in_a = trans.in_a;
    intf.in_b = trans.in_b;
  endtask

  //Score the test
  int num_tests = 0;
  int num_fails = 0;

  alu_ref_model ref_alu;

  task automatic score_test();

    bit test_fail = 0;
    expected_output expected = ref_alu.expected(intf.alu_op, intf.in_a, intf.in_b);

    if(intf.result != expected.result) begin
      $error("FAIL\nIncorect Result\nExpected: %h",expected.result);
      test_fail = 1;
    end

    if(intf.zero != expected.zero) begin
      $error("Zero flag incorect\nexpected: %b", expected.zero);
      test_fail = 1;
    end

    if(test_fail) begin
      num_fails++;
      intf.print_state();
    end

    num_tests++;
  endtask

  task print_test_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %d", num_tests);
    $display("Total tests failed: %d", num_fails);
    $display("----------------");
  endtask

  //connect the dut to interface
  alu dut(.alu_op(intf.alu_op),
          .in_a(intf.in_a),
          .in_b(intf.in_b),
          .result(intf.result),
          .zero(intf.zero)
          );

  //bind assertions to the dut
  bind tb_alu.dut alu_assert dut_assert(intf.assertion);

  //coverage
  tb_alu_coverage coverage;

  //we are going to need these kinds of transactions for our tests
  logical_op_trans logical_trans;
  add_op_trans add_trans;
  sub_op_trans sub_trans;
  general_trans gen_trans;

  initial begin
    //create coverage and connect it to the interface
    coverage = new(intf.coverage);

    //create the referance alu
    ref_alu = new();

    //create our transactions
    logical_trans = new();
    add_trans = new();
    sub_trans = new();
    gen_trans = new();

    /*************  TEST AND ***************/
    for(int i = 0; i < 1000; i++) begin
      assert(logical_trans.randomize() with { alu_op == 4'b0000; })
      drive(logical_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    /************   TEST OR *****************/
    for(int i = 0; i < 1000; i++) begin
      assert(logical_trans.randomize() with { alu_op == 4'b0001; });
      drive(logical_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    /*****************  TEST ADD **************/
    for(int i = 0; i < 1000; i++) begin
      assert(add_trans.randomize());
      drive(add_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    /************ TEST SUB ****************/
    for(int i = 0; i < 1000; i++) begin
      assert(sub_trans.randomize());
      drive(sub_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    /************ TEST EVERYTHING WITH COMP RAND ****************/
    for(int i = 0; i < 1000; i++) begin
      assert(gen_trans.randomize());
      drive(gen_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    /************ TEST INVALID OP ****************/
    gen_trans.inc_inv_ops = TRUE;
    for(int i = 0; i < 10; i++) begin
      assert(gen_trans.randomize() with { alu_op inside {4'b1111, 4'b1100, 4'b1010}; });
      drive(gen_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    print_test_results();

    $stop(1);
  end
endmodule
