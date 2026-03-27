package tb_lut_ram_monitor_pkg;
  import base_monitor_pkg::*;
  import tb_lut_ram_transaction_pkg::*;

  class lut_ram_monitor #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
  ) extends base_monitor #(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH));

    virtual lut_ram_intf #(LUT_WIDTH, LUT_DEPTH) vif;

    function new(
      virtual lut_ram_intf #(LUT_WIDTH, LUT_DEPTH) vif,
      string tag,
      mailbox_t mon_to_scb_mbx
    );
      super.new(tag, mon_to_scb_mbx);
      this.vif = vif;
    endfunction

    //NOTE:
    //  - DUT reads are combinatorial (rd_data = mem[rd_addr]).
    //    We are syncing sampling to the clk through the cb_mon block, so
    //    the output we are reading corresponds to the inputs driven at the
    //    previous clk (with cb_drv in the driver)
    task run();
      lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) trans;

      @(vif.cb_mon)
      if(vif.cb_mon.valid) begin
        trans = new();
        //sample DUT inputs
        trans.wr_en   = vif.cb_mon.wr_en;
        trans.wr_addr = vif.cb_mon.wr_addr;
        trans.rd_addr = vif.cb_mon.rd_addr;
        trans.wr_data = vif.cb_mon.wr_data;
        //sample DUT output
        trans.rd_data = vif.cb_mon.rd_data;
        //send the transaction to the scoreboard
        mon_to_scb_mbx.put(trans);
      end
    endtask
  endclass

endpackage
