package tb_imm_gen_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_imm_gen_transaction_pkg::*;
  import imm_gen_ref_model_pkg::*;
  import tb_imm_gen_coverage_pkg::*;

  class imm_gen_scoreboard extends base_scoreboard #(imm_gen_trans);
    imm_gen_ref_model ref_imm_gen;

    tb_imm_gen_coverage coverage;

    function new(tb_imm_gen_coverage coverage, string tag, mailbox_t mon_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx);
      this.coverage = coverage;
      ref_imm_gen = new();
    endfunction

    function bit score(input imm_gen_trans actual);
      bit passed = 1;

      //copy DUT inputs into the expected
      imm_gen_trans expected = new();
      expected.inst = actual.inst;

      //calc expected DUT output from ref model
      expected.imm = ref_imm_gen.compute(actual.inst);

      //test
      passed = expected.compare(actual);

      //handle pass/fail
      if(passed) begin
        coverage.sample(actual);
      end
      else begin
        print_fail(actual, expected);
      end

      return passed;
    endfunction
  endclass

endpackage
