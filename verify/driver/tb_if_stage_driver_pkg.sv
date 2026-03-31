package tb_if_stage_driver_pkg;
  import tb_if_stage_transaction_pkg::*;
  import base_driver_pkg::*;

  class if_stage_driver extends base_driver #(if_stage_trans);
    virtual if_stage_intf vif;

    function new(virtual if_stage_intf vif, string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.vif = vif;
    endfunction


    //drive some initial signals onto the DUT
    //  - NOTE: This is happening at the same time if_stage_reset is asserting
    //          the reset in its pre_run() task
    task pre_run();
      @(vif.cb_drv);
      vif.cb_drv.branch        <= 0;
      vif.cb_drv.branch_target <= '1;
      vif.cb_drv.valid <= 0;
    endtask

    //leave the DUT driven with some known signals
    //  - NOTE: This is happening at the same time if_stage_reset is asserting
    //          the reset in its post_run() task, so the DUT is left in
    //          a reset state after testing
    task post_run();
      @(vif.cb_drv);
      vif.cb_drv.branch        <= 0;
      vif.cb_drv.branch_target <= '1;
      vif.cb_drv.valid <= 0;
    endtask

    task run();
      if_stage_trans trans;

      @(vif.cb_drv)
      if(gen_to_drv_mbx.try_get(trans)) begin
        vif.cb_drv.valid         <= 1;                    //If we are driving a new trans from the mailbox, then its valid
        vif.cb_drv.branch        <= trans.branch;
        vif.cb_drv.branch_target <= trans.branch_target;
      end
      else begin
        vif.cb_drv.valid         <= 0;                    //If mbx was empty, then we are driving old data which is not valid
      end
    endtask
  endclass

endpackage
