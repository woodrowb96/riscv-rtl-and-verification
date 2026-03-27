package tb_inst_mem_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_inst_mem_transaction_pkg::*;
  import tb_inst_mem_coverage_pkg::*;

  class inst_mem_scoreboard extends base_scoreboard #(inst_mem_trans);

    tb_inst_mem_coverage coverage;  //we are collecting coverage in this element

    function new(tb_inst_mem_coverage coverage,
                string tag,
                mailbox_t mon_to_scb_mbx,
                mailbox_t pred_to_scb_mbx
    );
      super.new(tag, mon_to_scb_mbx, pred_to_scb_mbx);
      this.coverage = coverage;
    endfunction

    task run();
      inst_mem_trans actual, expected;

      bit passed = 0;

      mon_to_scb_mbx.get(actual);
      pred_to_scb_mbx.get(expected);

      //test
      passed = expected.compare(actual);

      //handle pass/fail
      if(passed) begin
        coverage.sample(actual);    //only collect coverage on passing transactions
      end
      else begin
        print_fail(actual, expected);
        num_fails++;
      end
    endtask

  endclass

endpackage
