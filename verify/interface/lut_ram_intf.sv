interface lut_ram_intf #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
)(input logic clk);

  logic wr_en;
  logic [$clog2(LUT_DEPTH)-1:0] wr_addr;
  logic [$clog2(LUT_DEPTH)-1:0] rd_addr;
  logic [LUT_WIDTH-1:0] wr_data;
  logic [LUT_WIDTH-1:0] rd_data;

  modport monitor(input clk, wr_en, wr_addr, rd_addr, wr_data, rd_data);

  function void print(string msg = "");
    $display("[%s] t=%0t wr_en:%b wr_addr:%0d rd_addr:%0d wr_data:%h rd_data:%h",
             msg, $time, wr_en, wr_addr, rd_addr, wr_data, rd_data);
  endfunction
endinterface
