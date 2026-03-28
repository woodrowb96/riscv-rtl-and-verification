package tb_if_stage_predictor_pkg;
  import tb_if_stage_transaction_pkg::*;
  import base_predictor_pkg::*;
  import if_stage_ref_model_pkg::*;

  class if_stage_predictor extends base_predictor #(if_stage_trans);
    virtual if_stage_intf vif;

    if_stage_ref_model ref_if_stage;

    function new(virtual if_stage_intf vif,
                string program_file,
                string tag,
                mailbox_t pred_to_scb_mbx
    );
      super.new(tag, pred_to_scb_mbx);
      this.vif = vif;
      ref_if_stage = new(program_file);
    endfunction

    task run();
      if_stage_trans trans;

      @(vif.cb_mon)
      if(vif.cb_mon.valid && vif.cb_mon.reset_n) begin
        trans = new();
        //sample the DUT input
        trans.branch        = vif.cb_mon.branch;
        trans.branch_target = vif.cb_mon.branch_target;

        //predict the expected DUT output
        trans.pc   = ref_if_stage.pc;
        trans.inst = ref_if_stage.fetch_inst();

        //update the ref_model
        ref_if_stage.update(trans);

        //send the transaction to the scoreboard
        pred_to_scb_mbx.put(trans);
      end
    endtask
  endclass

endpackage
