package tb_lut_ram_predictor_pkg;
  import tb_lut_ram_transaction_pkg::*;
  import base_predictor_pkg::*;
  import lut_ram_ref_model_pkg::*;

  class lut_ram_predictor #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
  ) extends base_predictor #(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH));

    virtual lut_ram_intf #(LUT_WIDTH, LUT_DEPTH) vif;

    lut_ram_ref_model #(LUT_WIDTH, LUT_DEPTH) ref_lut_ram;

    function new(
      virtual lut_ram_intf #(LUT_WIDTH, LUT_DEPTH) vif,
      string tag,
      mailbox_t pred_to_scb_mbx
    );
      super.new(tag, pred_to_scb_mbx);
      this.vif = vif;
      ref_lut_ram = new();
    endfunction

    task predict(output lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) trans);
      @(vif.cb_mon);
      //sample the DUT inputs
      trans = new();
      trans.wr_en   = vif.cb_mon.wr_en;
      trans.wr_addr = vif.cb_mon.wr_addr;
      trans.rd_addr = vif.cb_mon.rd_addr;
      trans.wr_data = vif.cb_mon.wr_data;

      //predict the expected DUT output
      trans.rd_data = ref_lut_ram.read(trans.rd_addr);

      //update the ref model
      ref_lut_ram.update(trans);
    endtask
  endclass

endpackage
