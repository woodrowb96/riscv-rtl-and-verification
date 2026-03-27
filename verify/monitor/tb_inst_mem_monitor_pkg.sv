package tb_inst_mem_monitor_pkg;
  import base_monitor_pkg::*;
  import tb_inst_mem_transaction_pkg::*;

  class inst_mem_monitor extends base_monitor #(inst_mem_trans);
    virtual inst_mem_intf vif;

    function new(virtual inst_mem_intf vif, string tag, mailbox_t mon_to_scb_mbx);
      super.new(tag, mon_to_scb_mbx);
      this.vif = vif;
    endfunction

    //NOTE:
    //  - DUT is purely combinatorial (ROM lookup).
    //    We are syncing sampling to the clk through the cb_mon block, so
    //    the output we are reading corresponds to the inputs driven at the
    //    previous clk (with cb_drv in the driver)
    task run();
      inst_mem_trans trans;

      @(vif.cb_mon)
      if(vif.cb_mon.valid) begin
        trans = new();
        //sample DUT input
        trans.inst_addr = vif.cb_mon.inst_addr;
        //sample DUT output
        trans.inst = vif.cb_mon.inst;
        //send the transaction to the scoreboard
        mon_to_scb_mbx.put(trans);
      end
    endtask
  endclass

endpackage
