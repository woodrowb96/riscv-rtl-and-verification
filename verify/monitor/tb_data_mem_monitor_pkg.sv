package tb_data_mem_monitor_pkg;
  import base_monitor_pkg::*;
  import tb_data_mem_transaction_pkg::*;

  class data_mem_monitor extends base_monitor #(data_mem_trans);
    virtual data_mem_intf vif;

    function new(virtual data_mem_intf vif, string tag, mailbox_t mon_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx);
      this.vif = vif;
    endfunction

    //NOTE:
    //  - DUT reads are combinatorial (rd_data is async).
    //    We are syncing sampling to the clk through the cb_mon block, so
    //    the output we are reading corresponds to the inputs driven at the
    //    previous clk (with cb_drv in the driver)
    task monitor(output data_mem_trans trans);
      @(vif.cb_mon);
      trans = new();
      //sample DUT inputs
      trans.wr_sel  = vif.cb_mon.wr_sel;
      trans.addr    = vif.cb_mon.addr;
      trans.wr_data = vif.cb_mon.wr_data;
      //sample DUT output
      trans.rd_data = vif.cb_mon.rd_data;
    endtask
  endclass

endpackage
