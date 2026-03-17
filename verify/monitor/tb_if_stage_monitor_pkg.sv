package tb_if_stage_monitor_pkg;
  import tb_if_stage_transaction_pkg::*;
  import base_monitor_pkg::*;

  class if_stage_monitor extends base_monitor #(if_stage_trans);
    virtual if_stage_intf vif;

    function new(virtual if_stage_intf vif, string tag, mailbox_t mon_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx);
      this.vif = vif;
    endfunction

    task monitor(output if_stage_trans trans);
      @(vif.cb_mon);
      trans = new();
      //sample DUT input
      trans.branch        = vif.cb_mon.branch;
      trans.branch_target = vif.cb_mon.branch_target;
      //sample DUT output
      trans.pc            = vif.cb_mon.pc;    //pc is a syncrounous signal
      trans.inst          = vif.cb_mon.inst;  //inst is a combinatorial output of u_inst_mem
    endtask
  endclass

endpackage
