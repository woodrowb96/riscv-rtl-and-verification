import riscv_32i_defs_pkg::*;
import riscv_32i_config_pkg::*;
import riscv_32i_control_pkg::*;
import tb_data_mem_transaction_pkg::*;

module tb_data_mem();
  localparam int CLK_PERIOD = 10;

  //clk
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /************** INTERFACE *********/
  data_men_interface intf(clk);

  /********* DUT ***********/
  data_mem dut(.clk(clk),
                .wr_sel(intf.wr_sel),
                .addr(intf.addr),
                .wr_data(intf.wr_data),
                .rd_data(intf.rd_data)
              );

  initial begin
  end

endmodule

