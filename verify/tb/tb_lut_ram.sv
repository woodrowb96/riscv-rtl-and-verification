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
  //control
  logic wr_en;
  //input
  lut_addr_t wr_addr;
  lut_addr_t rd_addr;
  word_t wr_data;
  //output
  word_t rd_data;

  /**********  DUT ***************/
  lut_ram dut(.*);

  initial begin
    wr_en <= '0;
    wr_addr <= 'd1;
    rd_addr <= 'd1;
    wr_data <= '0;

    for(int i = 0; i < 10; i++) begin
      @(posedge clk)
      wr_data <= wr_data + 'd1;
      wr_en <= ~wr_en;
      wr_addr <= i * 10;
      rd_addr <= i * 10;
      @(posedge clk)
      #1
      $display("wr_en: %b\n wr_addr: %d, wr_data: %h\nrd_addr: %d, rd_data: %h\n",
                wr_en, wr_addr, wr_data, rd_addr, rd_data);

    end

    $stop(1);
  end

endmodule
