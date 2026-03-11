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

  /**************  TESTING ***************************/

  alu_default_test       test_default;            //default test: test all ops with some contraits to target coverage
  alu_add_corner_walk_test test_add_corner_walk;  //walk through all combos of add corners and add
  alu_sub_corner_walk_test test_sub_corner_walk;  //walk through all combos of sub corners and sub
  alu_invalid_op_test      test_invalid_op;       //test invalid operations

  initial begin
    coverage = new();

    test_default       = new(intf, coverage);
    test_add_corner_walk = new(intf, coverage);
    test_sub_corner_walk = new(intf, coverage);
    test_invalid_op      = new(intf, coverage);

    //run tests
    test_default.run(1000);
    test_add_corner_walk.run();
    test_sub_corner_walk.run();
    test_invalid_op.run(10);

    //print results
    test_default.print_results();
    test_add_corner_walk.print_results();
    test_sub_corner_walk.print_results();
    test_invalid_op.print_results();

    $stop(1);
  end
endmodule
