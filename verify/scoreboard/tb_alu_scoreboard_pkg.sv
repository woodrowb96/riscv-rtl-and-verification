package tb_alu_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_alu_transaction_pkg::*;
  import alu_ref_model_pkg::*;

  class alu_scoreboard extends base_scoreboard #(alu_trans);
    alu_ref_model ref_alu;

    function new(mailbox_t mon_to_scb_mbx);
      super.new(mon_to_scb_mbx);
      ref_alu = new();
    endfunction

    function bit compare(input alu_trans actual);
      alu_out_t expected_out;
      bit passed = 1;
      alu_trans expected = new();

      //copy DUT INPUTS
      expected.alu_op = actual.alu_op;
      expected.in_a = actual.in_a;
      expected.in_b = actual.in_b;

      //calc expeced out
      expected_out = ref_alu.compute(actual.alu_op, actual.in_a, actual.in_b);
      expected.result = expected_out.result;
      expected.zero = expected_out.zero;

      //calc test result and return
      if(!expected.compare(actual)) begin   //the test fails if expected != actual
        passed = 0;
        print_fail(actual, expected, "ALU_SCOREBOARD");
      end
      // expected.print("EXPECTED");
      return passed;
    endfunction

  endclass

endpackage
