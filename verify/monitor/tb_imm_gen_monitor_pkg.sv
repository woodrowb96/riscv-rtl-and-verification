package tb_imm_gen_monitor_pkg;
  import base_monitor_pkg::*;
  import tb_imm_gen_transaction_pkg::*;

  class imm_gen_monitor extends base_monitor #(imm_gen_trans);
    virtual imm_gen_intf vif;

    function new(virtual imm_gen_intf vif, string tag, mailbox_t mon_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx);
      this.vif = vif;
    endfunction

    //NOTE:
    //  - DUT is purely combinatorial (immediate extraction from instruction).
    //    We are syncing sampling to the clk through the cb_mon block, so
    //    the output we are reading corresponds to the inputs driven at the
    //    previous clk (with cb_drv in the driver)
    task monitor(output imm_gen_trans trans);
      @(vif.cb_mon);
      trans = new();
      //sample DUT input
      trans.inst = vif.cb_mon.inst;
      //sample DUT output
      trans.imm = vif.cb_mon.imm;
    endtask
  endclass

endpackage
