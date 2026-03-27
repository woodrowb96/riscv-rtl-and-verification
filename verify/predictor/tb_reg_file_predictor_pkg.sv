package tb_reg_file_predictor_pkg;
  import tb_reg_file_transaction_pkg::*;
  import base_predictor_pkg::*;
  import reg_file_ref_model_pkg::*;

  class reg_file_predictor extends base_predictor #(reg_file_trans);
    virtual reg_file_intf vif;

    reg_file_ref_model ref_reg_file;

    function new(virtual reg_file_intf vif,
                string tag,
                mailbox_t pred_to_scb_mbx
    );
      super.new(tag, pred_to_scb_mbx);
      this.vif = vif;
      ref_reg_file = new();
    endfunction

    task run();
      reg_file_trans trans;

      @(vif.cb_mon)
      if(vif.cb_mon.valid) begin
        trans = new();

        //sample the DUT inputs
        trans.wr_en    = vif.cb_mon.wr_en;
        trans.wr_reg   = vif.cb_mon.wr_reg;
        trans.wr_data  = vif.cb_mon.wr_data;
        trans.rd_reg_1 = vif.cb_mon.rd_reg_1;
        trans.rd_reg_2 = vif.cb_mon.rd_reg_2;

        //predict the expected DUT outputs
        trans.rd_data_1 = ref_reg_file.read(trans.rd_reg_1);
        trans.rd_data_2 = ref_reg_file.read(trans.rd_reg_2);

        //update the ref model
        ref_reg_file.update(trans);

        //send the transactions to the scoreboard
        pred_to_scb_mbx.put(trans);
      end
    endtask
  endclass

endpackage
