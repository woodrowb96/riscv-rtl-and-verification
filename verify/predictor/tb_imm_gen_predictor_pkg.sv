package tb_imm_gen_predictor_pkg;
  import tb_imm_gen_transaction_pkg::*;
  import base_predictor_pkg::*;
  import imm_gen_ref_model_pkg::*;

  class imm_gen_predictor extends base_predictor #(imm_gen_trans);
    virtual imm_gen_intf vif;

    imm_gen_ref_model ref_imm_gen;

    function new(virtual imm_gen_intf vif,
                string tag,
                mailbox_t pred_to_scb_mbx
    );
      super.new(tag, pred_to_scb_mbx);
      this.vif = vif;
      ref_imm_gen = new();
    endfunction

    task run();
      imm_gen_trans trans;

      @(vif.cb_mon)
      if(vif.cb_mon.valid) begin
        trans = new();
        //sample the DUT input
        trans.inst = vif.cb_mon.inst;

        //predict the expected DUT output
        trans.imm = ref_imm_gen.compute(trans.inst);

        //send the transaction to the scoreboard
        pred_to_scb_mbx.put(trans);
      end
    endtask
  endclass

endpackage
