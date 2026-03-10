import tb_alu_tests_pkg::*;
// import tb_alu_coverage_pkg::*;

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
  // tb_alu_coverage coverage;

  // task test_invalid_op(alu_trans trans);
  //   trans.alu_op = alu_op_t'(4'b1111);    //make it invalid
  //   drive(trans);
  //   @(posedge clk);
  //   monitor(trans);
  //   score(trans);
  //   coverage.sample();
  // endtask


  /**************  TESTING ***************************/
  alu_full_rand_test full_rand_test;

  initial begin
    full_rand_test = new(intf);

    // full_rand_test.mon.drv_done = full_rand_test.drv.drv_done;

    full_rand_test.run(1000);

    //single directed test to test invalid op behavior
    // test_invalid_op(generator.gen_trans());

    full_rand_test.print_results();

    $stop(1);
  end
endmodule
