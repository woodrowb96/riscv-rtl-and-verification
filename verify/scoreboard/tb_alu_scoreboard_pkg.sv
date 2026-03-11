package tb_alu_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_alu_transaction_pkg::*;
  import alu_ref_model_pkg::*;
  import tb_alu_coverage_pkg::*;

  class alu_scoreboard extends base_scoreboard #(alu_trans);
    //ref model
    alu_ref_model ref_alu;
    //coverage
    alu_coverage coverage;

    function new(alu_coverage coverage, string tag, mailbox_t mon_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx);
      this.coverage = coverage;
      ref_alu = new();
    endfunction

    function bit score(input alu_trans actual);
      alu_out_t expected_out;
      bit passed = 1;

      //Copy DUT inputs into the expected
      alu_trans expected = new();
      expected.alu_op = actual.alu_op;
      expected.in_a = actual.in_a;
      expected.in_b = actual.in_b;

      //calc expected DUT outputs
      expected_out = ref_alu.compute(actual.alu_op, actual.in_a, actual.in_b);
      expected.result = expected_out.result;
      expected.zero = expected_out.zero;

      //test
      passed = expected.compare(actual);

      //handle pass/fail
      if(passed) begin   //if test passed, add the actual trans to coverage
        coverage.sample(actual);
      end
      else begin                          //if test failed
        print_fail(actual, expected);
      end

      return passed;
    endfunction

  endclass

endpackage
