package tb_if_stage_monitor_pkg;
  import tb_if_stage_transaction_pkg::*;
  import base_monitor_pkg::*;

  class if_stage_monitor extends base_monitor #(if_stage_trans);
    virtual if_stage_intf vif;

    function new(virtual if_stage_intf vif, string tag, mailbox_t mon_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx);
      this.vif = vif;
    endfunction

    task run();
      if_stage_trans trans;

      @(vif.cb_mon)
      if(vif.cb_mon.valid && vif.cb_mon.reset_n) begin
        trans = new();

        //sample DUT input
        trans.branch        = vif.cb_mon.branch;
        trans.branch_target = vif.cb_mon.branch_target;

        //sample DUT output
        trans.pc            = vif.cb_mon.pc;
        trans.inst          = vif.cb_mon.inst;

        //send the transaction to the scoreboard
        mon_to_scb_mbx.put(trans);
      end
    endtask
  endclass

endpackage
