import riscv_32i_defs_pkg::*;
import lut_ram_verify_pkg::*;

module tb_lut_ram();
  localparam CLK_PERIOD = 10;

  //clk
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /************ INTERFACE ***********/
  lut_ram_intf intf(clk);

  /**********  DUT ***************/
  lut_ram dut(.clk(intf.clk),
              .wr_en(intf.wr_en),
              .wr_addr(intf.wr_addr),
              .rd_addr(intf.rd_addr),
              .wr_data(intf.wr_data),
              .rd_data(intf.rd_data)
              );

  initial begin
    intf.wr_en <= '0;
    intf.wr_addr <= 'd1;
    intf.rd_addr <= 'd1;
    intf.wr_data <= '0;

    for(int i = 0; i < 10; i++) begin
      @(posedge intf.clk)
      intf.wr_data <= intf.wr_data + 'd1;
      intf.wr_en <= ~intf.wr_en;
      intf.wr_addr <= i * 10;
      intf.rd_addr <= i * 10;
      @(posedge intf.clk)
      #1
      $display("wr_en: %b\n wr_addr: %d, wr_data: %h\nrd_addr: %d, rd_data: %h\n",
                intf.wr_en, intf.wr_addr, intf.wr_data, intf.rd_addr, intf.rd_data);
    end

    $stop(1);
  end

endmodule
