package tb_inst_mem_driver_pkg;
  import base_driver_pkg::*;
  import tb_inst_mem_transaction_pkg::*;

  class inst_mem_driver extends base_driver #(inst_mem_trans);
    virtual inst_mem_intf vif;

    function new(virtual inst_mem_intf vif, string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.vif = vif;
    endfunction

    task pre_run();
      @(vif.cb_drv)
      vif.cb_drv.valid <= 0;
    endtask

    task run();
      inst_mem_trans trans;

      @(vif.cb_drv)
      if(gen_to_drv_mbx.try_get(trans)) begin
        vif.cb_drv.valid     <= 1;
        vif.cb_drv.inst_addr <= trans.inst_addr;
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
