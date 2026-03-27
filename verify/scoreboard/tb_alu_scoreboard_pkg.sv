package tb_alu_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_alu_transaction_pkg::*;
  import tb_alu_coverage_pkg::*;

  class alu_scoreboard extends base_scoreboard #(alu_trans);

    alu_coverage coverage;  //we are collecting coverage

    function new(alu_coverage coverage, string tag, mailbox_t mon_to_scb_mbx, mailbox_t pred_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx, pred_to_scb_mbx);
      this.coverage = coverage;
    endfunction

    task run();
      alu_trans actual, expected;

      bit passed = 0;

      mon_to_scb_mbx.get(actual);
      pred_to_scb_mbx.get(expected);

      //test
      passed = expected.compare(actual);

      //handle pass/fail
      if(passed) begin
        coverage.sample(actual);  //only collect coverage on passing transactions
      end
      else begin
        num_fails++;
        print_fail(actual, expected);
      end
    endtask

  endclass

endpackage
