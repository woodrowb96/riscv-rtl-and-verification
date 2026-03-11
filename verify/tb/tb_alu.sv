import tb_alu_tests_pkg::*;
import tb_alu_coverage_pkg::*;

module tb_alu();
  localparam CLK_PERIOD = 10;

  /*********** CLK *************/
  //alu is purely comb, but I use a clk to sync testing
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  alu_intf intf(.clk);

  /*********** DUT *************/
  alu dut(.alu_op(intf.alu_op),
          .in_a(intf.in_a),
          .in_b(intf.in_b),
          .result(intf.result), 
          .zero(intf.zero) 
          );

  /*********** BIND ASSERTIONS *************/
  bind tb_alu.dut alu_assert dut_assert(.tb_clk(tb_alu.clk),
                                        .alu_op(alu_op),
                                        .in_a(in_a),
                                        .in_b(in_b),
                                        .result(result),
                                        .zero(zero)
                                        );

  /************ COVERAGE *******************/
  alu_coverage coverage;

  // task test_invalid_op(alu_trans trans);
  //   trans.alu_op = alu_op_t'(4'b1111);    //make it invalid
  //   drive(trans);
  //   @(posedge clk);
  //   monitor(trans);
  //   score(trans);
  //   coverage.sample();
  // endtask


  /**************  TESTING ***************************/
  alu_full_rand_test       test_full_rand;
  alu_add_corner_walk_test test_add_corner_walk;
  alu_sub_corner_walk_test test_sub_corner_walk;
  alu_invalid_op_test      test_invalid_op;

  initial begin
    coverage = new();

    test_full_rand       = new(intf, coverage);
    test_add_corner_walk = new(intf, coverage);
    test_sub_corner_walk = new(intf, coverage);
    test_invalid_op      = new(intf, coverage);

    test_full_rand.run(1000);

    test_add_corner_walk.run();

    test_sub_corner_walk.run();

    test_invalid_op.run(10);

    test_full_rand.print_results();
    test_add_corner_walk.print_results();
    test_sub_corner_walk.print_results();
    test_invalid_op.print_results();

    $stop(1);
  end
endmodule
