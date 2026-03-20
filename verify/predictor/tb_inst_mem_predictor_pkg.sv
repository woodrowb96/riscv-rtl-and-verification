package tb_inst_mem_predictor_pkg;
  import tb_inst_mem_transaction_pkg::*;
  import base_predictor_pkg::*;
  import inst_mem_ref_model_pkg::*;

  class inst_mem_predictor extends base_predictor #(inst_mem_trans);
    virtual inst_mem_intf vif;

    inst_mem_ref_model ref_inst_mem;

    function new(virtual inst_mem_intf vif,
                string program_file,
                string tag,
                mailbox_t pred_to_scb_mbx
    );
      super.new(tag, pred_to_scb_mbx);
      this.vif = vif;
      ref_inst_mem = new(program_file);
    endfunction

    task predict(output inst_mem_trans trans);
      @(vif.cb_mon);
      //sample the DUT input
      trans = new();
      trans.inst_addr = vif.cb_mon.inst_addr;

      //predict the expected DUT output
      trans.inst = ref_inst_mem.read(trans.inst_addr);
    endtask
  endclass

endpackage
