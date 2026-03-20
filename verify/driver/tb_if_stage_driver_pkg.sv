package tb_if_stage_driver_pkg;
  import tb_if_stage_transaction_pkg::*;
  import base_driver_pkg::*;

  class if_stage_driver extends base_driver #(if_stage_trans);
    virtual if_stage_intf vif;

    function new(virtual if_stage_intf vif, string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.vif = vif;
    endfunction


    //assert and hold the reset signal to prepare the DUT for testing
    //   - NOTE: We dont deassert the reset. We want to hold the DUT in the
    //           reset state until testing starts. This is to make sure the PC
    //           doesnt start incrementing before the first drive. We will
    //           deasert the reset during drive()
    task pre_run();
      vif.reset_n       <= 0;
      vif.branch        <= 0;
      vif.branch_target <= 0;
      @(posedge vif.clk);
    endtask

    //After the test has run assert and hold the reaset. We want to leave the
    //DUT in the reset state, so the PC doesnt increment between tests.
    //(This isnt too big of a deal because we reset during pre_run(), but well
    // do it just to make sure PC isnt incrementing when we dont want it too)
    task post_run();
      vif.reset_n       <= 0;
      vif.branch        <= 0;
      vif.branch_target <= 0;
      @(posedge vif.clk);
    endtask

    //NOTE:
    //  - I don't drive the reset through the clocking block. There are issues
    //  driving the same signal from multiple sources (and the sim treats
    //  a direct drive and a drive through the CB as separate). So we have
    //  driver conflicts on the reset signal, if it's driven from two separate
    //  sources.
    task drive(input if_stage_trans trans);
      @(vif.cb_drv)
      vif.reset_n              <= 1;
      vif.cb_drv.branch        <= trans.branch;
      vif.cb_drv.branch_target <= trans.branch_target;
    endtask
  endclass

endpackage
