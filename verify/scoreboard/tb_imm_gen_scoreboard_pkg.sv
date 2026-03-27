package tb_imm_gen_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_imm_gen_transaction_pkg::*;
  import tb_imm_gen_coverage_pkg::*;

  class imm_gen_scoreboard extends base_scoreboard #(imm_gen_trans);

    tb_imm_gen_coverage coverage;

    function new(tb_imm_gen_coverage coverage, string tag, mailbox_t mon_to_scb_mbx, mailbox_t pred_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx, pred_to_scb_mbx);
      this.coverage = coverage;
    endfunction

    task run();
      imm_gen_trans actual, expected;

      bit passed = 0;

      mon_to_scb_mbx.get(actual);
      pred_to_scb_mbx.get(expected);

      //test
      passed = expected.compare(actual);

      //handle pass/fail
      if(passed) begin
        coverage.sample(actual);
      end
      else begin
        print_fail(actual, expected);
        num_fails++;
      end
    endtask
  endclass

endpackage
