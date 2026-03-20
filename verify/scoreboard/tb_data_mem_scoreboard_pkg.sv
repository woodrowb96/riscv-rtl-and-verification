package tb_data_mem_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_data_mem_transaction_pkg::*;
  import data_mem_ref_model_pkg::*;
  import tb_data_mem_coverage_pkg::*;

  class data_mem_scoreboard extends base_scoreboard #(data_mem_trans);
    data_mem_ref_model ref_data_mem;

    tb_data_mem_coverage coverage;   //we are collecting coverage in the scoreboard

    function new(tb_data_mem_coverage coverage, string tag, mailbox_t mon_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx);
      this.coverage = coverage;
      ref_data_mem = new();
    endfunction

    task score(input data_mem_trans actual, output bit passed);
      //copy DUT inputs into the expected
      data_mem_trans expected = new();
      expected.wr_sel  = actual.wr_sel;
      expected.addr    = actual.addr;
      expected.wr_data = actual.wr_data;

      //calc expected DUT output from ref model
      expected.rd_data = ref_data_mem.read(actual.addr);

      //test
      passed = expected.compare(actual);

      //handle pass/fail
      if(passed) begin
        coverage.sample(actual);  //only collect coverage on passed transactions
      end
      else begin
        print_fail(actual, expected);
      end

      //update ref model for next cycle
      ref_data_mem.update(actual);
    endtask
  endclass

endpackage
