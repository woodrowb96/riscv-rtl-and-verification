package tb_if_stage_driver_pkg;
  import tb_if_stage_transaction_pkg::*;
  import base_driver_pkg::*;

  class if_stage_driver extends base_driver #(if_stage_trans);
    virtual if_stage_intf vif;

    function new(virtual if_stage_intf vif, string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.vif = vif;
    endfunction

    //perform the active low, synchronous reset
    task reset();
      //don't use .cb_drv for the reset assertion,
      //we want to drive directly onto the interface before the 1st clk edge
      vif.reset_n       <= 0;
      vif.branch        <= 0;
      vif.branch_target <= 0;
      @(posedge vif.clk);

      //NOTE: This is a bit of a weird way to reset. I don't deassert the reset
      //      signal here and leave it to drive to bring us out of reset.
      //      The problem with deasserting here is that the PC will start
      //      incrementing on the first clk of the drive before any of the
      //      .cb_drv signals actually get driven in. So basically the first
      //      transaction will happen at pc = 4, not pc = 0. We want testing
      //      to start at pc = 0, so we will hold the reset until testing
      //      actually starts.
      //
      //      The main problem this causes is the reference model is getting
      //      out of sync with the rtl. So one option is making modifications
      //      to the library architecture (add a base_predictor that runs
      //      concurrently and runs the ref_model off the interface) but for
      //      now I'm gonna continue with verification with the reset like this.
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
