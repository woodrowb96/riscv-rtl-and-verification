package tb_if_stage_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_if_stage_transaction_pkg::*;
  import tb_if_stage_coverage_pkg::*;

  class if_stage_scoreboard extends base_scoreboard #(if_stage_trans);

    tb_if_stage_coverage coverage;    //we are collecting coverage in this component

    function new(tb_if_stage_coverage coverage,
                 string tag,
                 mailbox_t mon_to_scb_mbx,
                 mailbox_t pred_to_scb_mbx
    );
      super.new(tag, mon_to_scb_mbx, pred_to_scb_mbx);
      this.coverage = coverage;
    endfunction

    task score(input if_stage_trans actual, input if_stage_trans expected, output bit passed);
      //test
      passed = actual.compare(expected);

      //handle pass/fail
      if(passed) begin
        coverage.sample(actual); //only cover the passing transactions
      end
      else begin
        print_fail(actual, expected);
      end
    endtask
  endclass

endpackage
