/*
  Generic lut ram module

Control:
  wr_en: active high write enable signal

Input:
  wr_addr: address we are writing to
            - synchronous
  rd_addr: address we are reading from
            - asynchronous

  wr_data: write data
            - synchronous
            - clocked in @(posedge clk)

Output:
  rd_data: read data
            - read out asynchronously

NOTE: OUT OF BOUNDS ACCESS
  - Out of bounds access is undefined behavior for this module.
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
  input logic [LUT_WIDTH-1:0]         wr_data,

  input logic [$clog2(LUT_DEPTH)-1:0] rd_addr,

  //output
  output logic [LUT_WIDTH-1:0] rd_data
);
  /***************** MEMORY ARRAY *************************/
  logic [LUT_WIDTH-1:0] mem [0:LUT_DEPTH-1];

  /***************** SYNCHRONOUS WRITES *******************/
  always_ff @(posedge clk) begin
    if(wr_en) begin
      mem[wr_addr] <= wr_data;
    end
  end

  /**************** ASYNCHRONOUS READS *******************/
  assign rd_data = mem[rd_addr];

endmodule
