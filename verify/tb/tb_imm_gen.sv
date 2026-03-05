import rv32i_defs_pkg::*;

module tb_imm_gen();
  localparam CLK_PERIOD = 10;

  /********* CLK ********/
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /********** INTERFACE ********/
  imm_gen_intf intf;

  /******* DUT ***********/
  imm_gen dut(.*);

endmodule
