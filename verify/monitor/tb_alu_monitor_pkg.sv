package tb_alu_monitor_pkg;
  import base_monitor_pkg::*;
  import tb_alu_transaction_pkg::*;

  class alu_monitor extends base_monitor #(alu_trans);
    virtual alu_intf vif;

    //NOTE:
    //  - alu is purely combinatorial, but the testing is synced to the tb's
    //    clock through the interface. Using the interfaces cb_mon clocking
    //    block ensures we are sampling slightly before the next drives get
    //    driven. It also gives the previous drives inputs time to propagate
    //    to the outputs for sampling.
    task monitor(output alu_trans trans);
      @(vif.cb_mon);
      trans = new();
      trans.alu_op = vif.cb_mon.alu_op;
      trans.in_a = vif.cb_mon.in_a;
      trans.in_b = vif.cb_mon.in_b;
      trans.result = vif.cb_mon.result;
      trans.zero = vif.cb_mon.zero;
    endtask

    function new(virtual alu_intf vif, string tag, mailbox_t mon_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx);
      this.vif = vif;
    endfunction
  endclass

endpackage
