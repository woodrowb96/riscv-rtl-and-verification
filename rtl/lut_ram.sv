/*
  Generic lut ram module

Control:
  wr_en:    active high write enable signal

Input:
  wr_reg:   adress we are writting to   (syncronous)
  rd_reg:   adress we are reading from  (asyncronous)

  wr_data:  write data, clocked in @(posedge clk)

Output:
  rd_data:  read data, read out asyncrounously
*/
module lut_ram #(
  parameter LUT_WIDTH = 32,
  parameter LUT_DEPTH = 256
  )(
  //clock
  input logic clk,

  //control
  input logic wr_en,

  //input
  input logic [$clog2(LUT_DEPTH)-1:0] wr_addr,
  input logic [$clog2(LUT_DEPTH)-1:0] rd_addr,

  input logic [LUT_WIDTH-1:0] wr_data,

  //output
  output logic [LUT_WIDTH-1:0] rd_data
);
  //our ram array
  reg [LUT_WIDTH-1:0] ram [0:LUT_DEPTH-1];

  //syncronous writes
  always_ff @(posedge clk) begin
    if(wr_en) begin
      ram[wr_addr] <= wr_data;
    end
  end

  //asyncronous reads
  assign rd_data = ram[rd_addr];
endmodule
