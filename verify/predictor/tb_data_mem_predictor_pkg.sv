package tb_data_mem_predictor_pkg;
  import tb_data_mem_transaction_pkg::*;
  import base_predictor_pkg::*;
  import data_mem_ref_model_pkg::*;

  class data_mem_predictor extends base_predictor #(data_mem_trans);
    virtual data_mem_intf vif;

    data_mem_ref_model ref_data_mem;

    function new(virtual data_mem_intf vif,
                string tag,
                mailbox_t pred_to_scb_mbx
    );
      super.new(tag, pred_to_scb_mbx);
      this.vif = vif;
      ref_data_mem = new();
    endfunction

    task run();
      data_mem_trans trans;

      @(vif.cb_mon)
      if(vif.cb_mon.valid) begin
        trans = new();
        //sample the DUT inputs
        trans.wr_sel  = vif.cb_mon.wr_sel;
        trans.addr    = vif.cb_mon.addr;
        trans.wr_data = vif.cb_mon.wr_data;

        //predict the expected DUT output
        trans.rd_data = ref_data_mem.read(trans.addr);

        //update the ref model
        ref_data_mem.update(trans);

        //send the transaction to the scoreboard
        pred_to_scb_mbx.put(trans);
      end
    endtask
  endclass

endpackage
