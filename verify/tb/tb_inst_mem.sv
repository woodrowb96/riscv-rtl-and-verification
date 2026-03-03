import riscv_32i_defs_pkg::*;
import verify_config_pkg::*;
import tb_inst_mem_transaction_pkg::*;

module tb_inst_mem();
  localparam CLK_PERIOD = 10;
  localparam PROPOGATION_DELAY = 1;

  //clk
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /******* INTERFACE ***********/
  inst_mem_intf intf();

  /******  DUT *************/
  inst_mem #(INST_MEM_TEST_0) dut(.inst_addr(intf.inst_addr), .inst(intf.inst));

  /********* TASKS ***********/
  task drive(inst_mem_trans trans);
    intf.inst_addr = trans.inst_addr;
  endtask

  task monitor(inst_mem_trans trans);
    trans.inst = intf.inst;
  endtask

  /*********** TESTING **************/
  inst_mem_trans trans;

  initial begin
    trans = new();
    trans.inst_addr = '0;
    trans.inst = '0;

    for(int i = 0; i < 10; i++) begin
      @(posedge clk)
      trans.inst_addr = 4 * i;
      drive(trans);
      #PROPOGATION_DELAY
      monitor(trans);
      trans.print();
    end

    $stop(1);
  end


endmodule
