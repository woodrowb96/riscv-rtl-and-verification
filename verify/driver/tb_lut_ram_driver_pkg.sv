package tb_lut_ram_driver_pkg;
  import base_driver_pkg::*;
  import tb_lut_ram_transaction_pkg::*;

  class lut_ram_driver #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
  ) extends base_driver #(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH));

    virtual lut_ram_intf #(LUT_WIDTH, LUT_DEPTH) vif;

    function new(
      virtual lut_ram_intf #(LUT_WIDTH, LUT_DEPTH) vif,
      string tag,
      mailbox_t gen_to_drv_mbx
    );
      super.new(tag, gen_to_drv_mbx);
      this.vif = vif;
    endfunction

    task drive(input lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) trans);
      @(vif.cb_drv)
      vif.cb_drv.wr_en   <= trans.wr_en;
      vif.cb_drv.wr_addr <= trans.wr_addr;
      vif.cb_drv.rd_addr <= trans.rd_addr;
      vif.cb_drv.wr_data <= trans.wr_data;
    endtask
  endclass

endpackage
