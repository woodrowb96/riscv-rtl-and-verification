package tb_alu_predictor_pkg;
  import tb_alu_transaction_pkg::*;
  import base_predictor_pkg::*;
  import alu_ref_model_pkg::*;

  class alu_predictor extends base_predictor #(alu_trans);
    virtual alu_intf vif;

    alu_ref_model ref_alu;

    function new(virtual alu_intf vif,
                string tag,
                mailbox_t pred_to_scb_mbx
    );
      super.new(tag, pred_to_scb_mbx);
      this.vif = vif;
      ref_alu = new();
    endfunction

    task run();
      alu_out_t expected_out;
      alu_trans trans;

      @(vif.cb_mon)
      if(vif.cb_mon.valid) begin //we only want to send predictions of valid trans to the scoreboard
        //sample the DUT inputs
        trans = new();
        trans.alu_op = vif.cb_mon.alu_op;
        trans.in_a   = vif.cb_mon.in_a;
        trans.in_b   = vif.cb_mon.in_b;
        //predict the expected DUT outputs
        expected_out = ref_alu.compute(trans.alu_op, trans.in_a, trans.in_b);
        trans.result = expected_out.result;
        trans.zero   = expected_out.zero;
        //send prediction the scoreboard
        pred_to_scb_mbx.put(trans);
      end
    endtask
  endclass

endpackage
