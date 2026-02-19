import tb_alu_coverage_pkg::*;
import tb_alu_transaction_pkg::*;
import tb_alu_generator_pkg::*;
import alu_ref_model_pkg::*;
import riscv_32i_control_pkg::*;

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

  /****************  ALU REFERENCE MODEL **************/
  alu_ref_model ref_alu;

  /*********** TASKS *************/
  task drive(alu_trans trans);
    intf.alu_op = trans.alu_op;
    intf.in_a = trans.in_a;
    intf.in_b = trans.in_b;
  endtask

  task monitor(alu_trans trans);
    trans.result = intf.result;
    trans.zero = intf.zero;
  endtask


  int num_tests = 0;
  int num_fails = 0;

  task automatic score(alu_trans actual);
    ref_alu_output prediction;

    alu_trans expected = new();
    expected.alu_op = actual.alu_op;
    expected.in_a = actual.in_a;
    expected.in_b = actual.in_b;

    prediction = ref_alu.predict(actual);
    expected.result = prediction.result;
    expected.zero = prediction.zero;

    if(!expected.compare(actual)) begin
      $display("----------------");
      $error("ALU_TB: test fail");
      expected.print("EXPECTED");
      actual.print("ACTUAL");
      num_fails++;
    end

    num_tests++;
  endtask

  task test(alu_trans trans);
      @(posedge clk);
      drive(trans);
      #1;                       //let the input propogate to the output
      monitor(trans);
      coverage.sample();
      score(trans);
  endtask

  task print_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %0d", num_tests);
    $display("Total tests failed: %0d", num_fails);
    $display("----------------");
  endtask

  /**************  TESTING ***************************/
  tb_alu_generator generator;
  alu_trans trans;

  initial begin
    coverage = new(intf.coverage);
    ref_alu = new();
    generator = new();
    trans = new();

    repeat(1500) begin
      test(generator.gen_trans());
    end

    //sub has alot of corner cases to hit
    //so we just loop and gen only sub transactions
    repeat(3500) begin
      test(generator.gen_sub_trans());
    end

    //test the ouput of an invalid trans is correct (result == 0, and zero ==0)
    assert(trans.randomize()) else
      $fatal(1, "ALU_TB: trans randomization failed");
    trans.alu_op = alu_op_t'(4'b1111);
    test(trans);

    print_results();

    $stop(1);
  end
endmodule
