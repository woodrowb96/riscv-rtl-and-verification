package tb_lut_ram_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_lut_ram_transaction_pkg::*;
  import tb_lut_ram_coverage_pkg::*;

  class lut_ram_scoreboard #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
  ) extends base_scoreboard #(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH));

    tb_lut_ram_coverage #(LUT_WIDTH, LUT_DEPTH) coverage;   //we are collecting coverage in this component

    function new(
      tb_lut_ram_coverage #(LUT_WIDTH, LUT_DEPTH) coverage,
      string tag,
      mailbox_t mon_to_scb_mbx,
      mailbox_t pred_to_scb_mbx
    );
      super.new(tag, mon_to_scb_mbx, pred_to_scb_mbx);
      this.coverage = coverage;
    endfunction

    task score(input lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) actual,
              input lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) expected,
              output bit passed);
      //test
      passed = expected.compare(actual);

      //handle pass/fail
      if(passed) begin
        coverage.sample(actual);
      end
      else begin
        print_fail(actual, expected);
      end
    endtask
  endclass

endpackage
