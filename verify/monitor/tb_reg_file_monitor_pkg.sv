package tb_reg_file_monitor_pkg;
  import base_monitor_pkg::*;
  import tb_reg_file_transaction_pkg::*;

  class reg_file_monitor extends base_monitor #(reg_file_trans);
    virtual reg_file_intf vif;

    function new(virtual reg_file_intf vif, string tag, mailbox_t mon_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx);
      this.vif = vif;
    endfunction

    //NOTE:
    //  - DUT output is purely combinatorial
    //    We use the clocking block to sync reads out.
    //    This also ensures the DUT inputs had time to propagate to the
    //    outputs
    task monitor(output reg_file_trans trans);
      @(vif.cb_mon);
      trans = new();
      //sample DUT input
      trans.wr_en    = vif.cb_mon.wr_en;
      trans.wr_reg   = vif.cb_mon.wr_reg;
      trans.wr_data  = vif.cb_mon.wr_data;
      trans.rd_reg_1 = vif.cb_mon.rd_reg_1;
      trans.rd_reg_2 = vif.cb_mon.rd_reg_2;
      //sample DUT output
      trans.rd_data_1 = vif.cb_mon.rd_data_1;
      trans.rd_data_2 = vif.cb_mon.rd_data_2;
    endtask
  endclass

endpackage
