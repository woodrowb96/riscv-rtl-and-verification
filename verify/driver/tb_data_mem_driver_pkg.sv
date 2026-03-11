package tb_data_mem_driver_pkg;
  import base_driver_pkg::*;
  import tb_data_mem_transaction_pkg::*;

  class data_mem_driver extends base_driver #(data_mem_trans);
    virtual data_mem_intf vif;

    function new(virtual data_mem_intf vif, string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.vif = vif;
    endfunction

    task drive(input data_mem_trans trans);
      @(vif.cb_drv)
      vif.cb_drv.wr_sel  <= trans.wr_sel;
      vif.cb_drv.addr    <= trans.addr;
      vif.cb_drv.wr_data <= trans.wr_data;
    endtask
  endclass

endpackage
