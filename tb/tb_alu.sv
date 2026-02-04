import tb_alu_coverage_pkg::*;
import tb_alu_stimulus_pkg::*;
import alu_ref_model_pkg::*;

module tb_alu();
  bit clk;
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  //interface
  alu_intf intf();

  //dut
  alu dut(.alu_op(intf.alu_op),
          .in_a(intf.in_a),
          .in_b(intf.in_b),
          .result(intf.result), 
          .zero(intf.zero) 
          );

  //bind assertions to the dut
  bind tb_alu.dut alu_assert dut_assert(intf.assertion);

  //we will be collecting coverage
  tb_alu_coverage coverage;

  //reference alu used to score tests
  alu_ref_model ref_alu;

  //Drive transaction into dut
  task drive(general_trans trans);
    intf.alu_op = trans.alu_op;
    intf.in_a = trans.in_a;
    intf.in_b = trans.in_b;
  endtask

  task monitor(general_trans trans);
    trans.result = intf.result;
    trans.zero = intf.zero;
  endtask

  //keep track of how many tests, and how many failed
  int num_tests = 0;
  int num_fails = 0;

  task automatic score(general_trans trans);

    bit test_fail = 0;
    expected_output expected = ref_alu.expected(trans.alu_op, trans.in_a, trans.in_b);

    if(trans.result != expected.result) begin
      $error("FAIL\nIncorect Result\nExpected: %h",expected.result);
      test_fail = 1;
    end

    if(trans.zero != expected.zero) begin
      $error("Zero flag incorect\nexpected: %b", expected.zero);
      test_fail = 1;
    end

    if(test_fail) begin
      num_fails++;
      trans.print();
    end

    num_tests++;
  endtask

  task test(general_trans trans);
      @(posedge clk);
      drive(trans);
      #1;
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
    repeat(1000) begin
      assert(logical_trans.randomize() with { alu_op == 4'b0000; })
      test(logical_trans);
    end

    /************   TEST OR *****************/
    repeat(1000) begin
      assert(logical_trans.randomize() with { alu_op == 4'b0001; });
      test(logical_trans);
    end

    /*****************  TEST ADD **************/
    repeat(1000) begin
      assert(add_trans.randomize());
      test(add_trans);
    end

    /************ TEST SUB ****************/
    repeat(1000) begin
      assert(sub_trans.randomize());
      test(sub_trans);
    end

    /************ TEST EVERYTHING COMPLETELY RANDOMIZED ****************/
    repeat(1000) begin
      assert(gen_trans.randomize());
      test(gen_trans);
    end

    /************ TEST INVALID OP ****************/
    gen_trans.inc_inv_ops = TRUE;
    repeat(10) begin
      assert(gen_trans.randomize() with { alu_op inside {4'b1111, 4'b1100, 4'b1010}; });
      test(gen_trans);
    end

    print_test_results();

    $stop(1);
  end
endmodule
