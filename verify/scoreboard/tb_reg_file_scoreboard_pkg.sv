package tb_reg_file_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_reg_file_transaction_pkg::*;
  import reg_file_ref_model_pkg::*;
  import tb_reg_file_coverage_pkg::*;

  class reg_file_scoreboard extends base_scoreboard #(reg_file_trans);
    reg_file_ref_model ref_reg_file;

    tb_reg_file_coverage coverage;    //we are collecting coverage

    function new(tb_reg_file_coverage coverage, string tag, mailbox_t mon_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx);
      this.coverage = coverage;
      ref_reg_file = new();
    endfunction

    task score(input reg_file_trans actual, output bit passed);
      //copy DUT inputs into the expected
      reg_file_trans expected = new();
      expected.wr_en    = actual.wr_en;
      expected.wr_reg   = actual.wr_reg;
      expected.wr_data  = actual.wr_data;
      expected.rd_reg_1 = actual.rd_reg_1;
      expected.rd_reg_2 = actual.rd_reg_2;

      //calc expected DUT outputs from ref model
      expected.rd_data_1 = ref_reg_file.read(actual.rd_reg_1);
      expected.rd_data_2 = ref_reg_file.read(actual.rd_reg_2);

      //test
      passed = expected.compare(actual);

      //handle pass/fail
      if(passed) begin
        coverage.sample(actual);  //collect coverage on ONLY passing transactions
      end
      else begin
        print_fail(actual, expected);
      end

      //update ref model for next cycle
      ref_reg_file.update(actual);
    endtask
  endclass

endpackage
