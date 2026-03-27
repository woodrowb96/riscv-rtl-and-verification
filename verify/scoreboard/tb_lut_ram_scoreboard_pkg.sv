package tb_lut_ram_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_lut_ram_transaction_pkg::*;
  import tb_lut_ram_coverage_pkg::*;

  class lut_ram_scoreboard #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
  ) extends base_scoreboard #(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH));

    tb_lut_ram_coverage #(LUT_WIDTH, LUT_DEPTH) coverage;   //we are collecting coverage

    function new(
      tb_lut_ram_coverage #(LUT_WIDTH, LUT_DEPTH) coverage,
      string tag,
      mailbox_t mon_to_scb_mbx,
      mailbox_t pred_to_scb_mbx
    );
      super.new(tag, mon_to_scb_mbx, pred_to_scb_mbx);
      this.coverage = coverage;
    endfunction

    task run();
      lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) actual, expected;

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
