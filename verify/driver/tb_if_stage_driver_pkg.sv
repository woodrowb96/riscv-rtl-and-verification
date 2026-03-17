package tb_if_stage_driver_pkg;
  import tb_if_stage_transaction_pkg::*;
  import base_driver_pkg::*;

  class if_stage_driver extends base_driver #(if_stage_trans);
    virtual if_stage_intf vif;

    function new(virtual if_stage_intf vif, string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.vif = vif;
    endfunction

    //perform the active low, syncronous reset
    task reset();
      //dont use .cb_drv for the reset assertion,
      //we want to drive directly onto the interface before the 1st clk edge
      vif.reset_n       <= 0;
      vif.branch        <= 0;
      vif.branch_target <= 0;
      @(vif.cb_drv);
      //then after the reset assertion is clocked in
      //we can go back to using the cb_drv to deassert the reset
      vif.cb_drv.reset_n <= 1;
    endtask

    task drive(input if_stage_trans trans);
      @(vif.cb_drv)
      vif.cb_drv.branch        <= trans.branch;
      vif.cb_drv.branch_target <= trans.branch_target;
    endtask
  endclass

endpackage
