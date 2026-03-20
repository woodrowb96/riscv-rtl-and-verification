package tb_inst_mem_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_inst_mem_transaction_pkg::*;
  import inst_mem_ref_model_pkg::*;
  import tb_inst_mem_coverage_pkg::*;

  class inst_mem_scoreboard extends base_scoreboard #(inst_mem_trans);
    inst_mem_ref_model ref_inst_mem;

    tb_inst_mem_coverage coverage;  //we are collecting coverage in this element

    function new(tb_inst_mem_coverage coverage,
                string program_file,
                string tag,
                mailbox_t mon_to_scb_mbx
    );
      super.new(tag, mon_to_scb_mbx);
      this.coverage = coverage;
      ref_inst_mem = new(program_file);
    endfunction

    task score(input inst_mem_trans actual, output bit passed);
      //copy DUT inputs into the expected
      inst_mem_trans expected = new();
      expected.inst_addr = actual.inst_addr;

      //calc expected DUT output from ref model
      expected.inst = ref_inst_mem.read(actual.inst_addr);

      //test
      passed = expected.compare(actual);

      //handle pass/fail
      if(passed) begin
        coverage.sample(actual);    //only collect coverage on passing transactions
      end
      else begin
        print_fail(actual, expected);
      end
    endtask

  endclass

endpackage
