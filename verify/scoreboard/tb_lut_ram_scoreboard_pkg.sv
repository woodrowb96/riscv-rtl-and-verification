package tb_lut_ram_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_lut_ram_transaction_pkg::*;
  import lut_ram_ref_model_pkg::*;
  import tb_lut_ram_coverage_pkg::*;

  class lut_ram_scoreboard #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
  ) extends base_scoreboard #(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH));

    lut_ram_ref_model #(LUT_WIDTH, LUT_DEPTH) ref_lut_ram;

    tb_lut_ram_coverage #(LUT_WIDTH, LUT_DEPTH) coverage;   //we are collecting coverage in this component

    function new(
      tb_lut_ram_coverage #(LUT_WIDTH, LUT_DEPTH) coverage,
      string tag,
      mailbox_t mon_to_scb_mbx
    );
      super.new(tag, mon_to_scb_mbx);
      this.coverage = coverage;
      ref_lut_ram = new();
    endfunction

    function bit score(input lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) actual);
      bit passed = 1;

      //copy DUT inputs into the expected
      lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) expected = new();
      expected.wr_en   = actual.wr_en;
      expected.wr_addr = actual.wr_addr;
      expected.rd_addr = actual.rd_addr;
      expected.wr_data = actual.wr_data;

      //calc expected DUT output from ref model
      expected.rd_data = ref_lut_ram.read(actual.rd_addr);

      //test
      passed = expected.compare(actual);

      //handle pass/fail
      if(passed) begin
        coverage.sample(actual);
      end
      else begin
        print_fail(actual, expected);
      end

      //update ref model for next cycle
      ref_lut_ram.update(actual);

      return passed;
    endfunction
  endclass

endpackage
