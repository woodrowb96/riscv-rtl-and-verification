package tb_imm_gen_driver_pkg;
  import base_driver_pkg::*;
  import tb_imm_gen_transaction_pkg::*;

  class imm_gen_driver extends base_driver #(imm_gen_trans);
    virtual imm_gen_intf vif;

    function new(virtual imm_gen_intf vif, string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.vif = vif;
    endfunction

    task drive(input imm_gen_trans trans);
      @(vif.cb_drv)
      vif.cb_drv.inst <= trans.inst;
    endtask
  endclass

endpackage
