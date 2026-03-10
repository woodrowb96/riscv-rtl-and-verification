package tb_alu_monitor_pkg;
  import base_monitor_pkg::*;
  import tb_alu_transaction_pkg::*;

  class alu_monitor extends base_monitor #(alu_trans);
    virtual alu_intf vif;
    event drv_done;

    task monitor(output alu_trans trans);
      @(drv_done);    //wait till the drive
      @(vif.cb_mon);  //then monitor with the input skew before the next clk
      trans = new();
      trans.alu_op = vif.cb_mon.alu_op;
      trans.in_a = vif.cb_mon.in_a;
      trans.in_b = vif.cb_mon.in_b;
      trans.result = vif.cb_mon.result;
      trans.zero = vif.cb_mon.zero;
    endtask

    function new(virtual alu_intf vif, mailbox_t mon_to_scb_mbx);
      super.new(mon_to_scb_mbx);
      this.vif = vif;
    endfunction
  endclass

endpackage
