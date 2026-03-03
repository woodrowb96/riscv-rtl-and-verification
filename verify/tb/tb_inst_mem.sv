module tb_inst_mem();
  import riscv_32i_defs_pkg::*;

  localparam string TEST_0 = "../../verify/programs/test_0.txt";
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
  inst_mem #(.PROGRAM(TEST_0)) dut(.inst_addr(intf.inst_addr), .inst(intf.inst));

  /********* TASKS ***********/
  task drive(word_t inst_addr);
    intf.inst_addr = inst_addr;
  endtask

  task monitor(output word_t inst);
    inst = intf.inst;
  endtask

  /*********** TESTING **************/
  word_t inst_addr;
  word_t inst;

  initial begin
    inst_addr = '0;
    inst = '0;

    for(int i = 0; i < 10; i++) begin
      @(posedge clk)
      inst_addr = 4 * i;
      drive(inst_addr);
      #PROPOGATION_DELAY
      monitor(inst);
      $display("inst_addr: %0d, inst: %h", inst_addr, inst);
    end

    $stop(1);
  end


endmodule
