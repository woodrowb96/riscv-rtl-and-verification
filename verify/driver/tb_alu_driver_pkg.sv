package tb_alu_driver_pkg;
  import base_driver_pkg::*;
  import tb_alu_transaction_pkg::*;

  class alu_driver extends base_driver #(alu_trans);
    virtual alu_intf vif;

    //used to help sync driving and monitoring
    //(its mostly there so we dont monitor the first driven transaction until
    // after the first drive has occurred)
    event drv_done;

    function new(virtual alu_intf vif, string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.vif = vif;
    endfunction

    task drive(input alu_trans trans);
      //drive
      @(vif.cb_drv)
      vif.cb_drv.alu_op <= trans.alu_op;
      vif.cb_drv.in_a <= trans.in_a;
      vif.cb_drv.in_b <= trans.in_b;

      //tell monitor the drive is done
      ->drv_done;
    endtask

  endclass

endpackage
