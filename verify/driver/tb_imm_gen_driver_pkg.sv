package tb_imm_gen_driver_pkg;
  import base_driver_pkg::*;
  import tb_imm_gen_transaction_pkg::*;

  class imm_gen_driver extends base_driver #(imm_gen_trans);
    virtual imm_gen_intf vif;

    function new(virtual imm_gen_intf vif, string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.vif = vif;
    endfunction

    task pre_run();
      @(vif.cb_drv)
      vif.cb_drv.valid <= 0;
    endtask

    task run();
      imm_gen_trans trans;

      @(vif.cb_drv)
      if(gen_to_drv_mbx.try_get(trans)) begin
        vif.cb_drv.valid <= 1;
        vif.cb_drv.inst  <= trans.inst;
      end
      else begin
        vif.cb_drv.valid <= 0;
      end
    endtask

    task post_run();
      @(vif.cb_drv)
      vif.cb_drv.valid <= 0;
    endtask
  endclass

endpackage
