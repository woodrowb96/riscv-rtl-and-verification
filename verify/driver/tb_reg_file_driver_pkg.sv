package tb_reg_file_driver_pkg;
  import base_driver_pkg::*;
  import tb_reg_file_transaction_pkg::*;

  class reg_file_driver extends base_driver #(reg_file_trans);
    virtual reg_file_intf vif;

    function new(virtual reg_file_intf vif, string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.vif = vif;
    endfunction

    task drive(input reg_file_trans trans);
      @(vif.cb_drv)
      vif.cb_drv.wr_en    <= trans.wr_en;
      vif.cb_drv.wr_reg   <= trans.wr_reg;
      vif.cb_drv.wr_data  <= trans.wr_data;
      vif.cb_drv.rd_reg_1 <= trans.rd_reg_1;
      vif.cb_drv.rd_reg_2 <= trans.rd_reg_2;
    endtask
  endclass

endpackage
