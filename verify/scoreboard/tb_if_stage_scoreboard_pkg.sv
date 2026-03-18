package tb_if_stage_scoreboard_pkg;
  import base_scoreboard_pkg::*;
  import tb_if_stage_transaction_pkg::*;
  import if_stage_ref_model_pkg::*;

  class if_stage_scoreboard extends base_scoreboard #(if_stage_trans);
    if_stage_ref_model ref_if_stage;

    function new(string program_file,
                 string tag,
                 mailbox_t mon_to_scb_mbx
    );
      super.new(tag, mon_to_scb_mbx);
      ref_if_stage = new(program_file);
    endfunction

    function bit score(input if_stage_trans actual);
      bit passed = 1;

      //build the expected DUT inputs
      if_stage_trans expected = new();
      expected.branch        = actual.branch;
      expected.branch_target = actual.branch_target;

      //calc expected DUT output
      expected.pc   = ref_if_stage.pc;
      expected.inst = ref_if_stage.fetch_inst();

      //test
      passed = actuall.compare(expected);

      //handle pass/fail
      if(passed) begin
        //eventually we will sample coverage here
      end
      else begin
        print_fail(actual, expected);
      end

      //update the ref_model
      ref_if_stage.update(actual);

      return passed;
    endfunction
  endclass

endpackage
