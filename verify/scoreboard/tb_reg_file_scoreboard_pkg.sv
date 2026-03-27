package tb_reg_file_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_reg_file_transaction_pkg::*;
  import tb_reg_file_coverage_pkg::*;

  class reg_file_scoreboard extends base_scoreboard #(reg_file_trans);

    tb_reg_file_coverage coverage;    //we are collecting coverage

    function new(tb_reg_file_coverage coverage, string tag, mailbox_t mon_to_scb_mbx, mailbox_t pred_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx, pred_to_scb_mbx);
      this.coverage = coverage;
    endfunction

    task run();
      reg_file_trans actual, expected;

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
        print_fail(actual, expected);
        num_fails++;
      end
    endtask

  endclass

endpackage
