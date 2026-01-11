/*
Register file module for single cycle rv32i partial implementation.

Control:
  wr_en:    active high write enable signal

Input:
  rd_reg_1: 5 bit read reg number
  rd_reg_2: 5 bit read reg number

  wr_reg:   5 bit write reg number
  wr_data:  32 bit write reg data, writen into wr_reg on rising clk edge

Output:
  rd_data_1:  32 bits of read data read out from rd_reg_1
  rd_data_2:  32 bits of read data read out from rd_reg_2

Note:
  Register x0 (reg_file[0]) always returns '0
*/
module register_file (
  input logic clk,

  //control
  input logic wr_en,

  //input
  input logic [4:0] rd_reg_1,
  input logic [4:0] rd_reg_2,

  input logic [4:0] wr_reg,
  input logic [31:0] wr_data,

  //output
  output logic [31:0] rd_data_1,
  output logic [31:0] rd_data_2
);

  //32 x 32'b registers
  logic [31:0] reg_file [0:31];

  //writting into reg file
  always_ff @(posedge clk) begin
    if(wr_en && (wr_reg != '0)) begin   //if wr_en and not writting to x0, then write
      reg_file[wr_reg] <= wr_data;
    end
  end

  //reading from reg file
  always_comb begin
    //output 0 out from x0, else output data stored in regesiter
    rd_data_1 = (rd_reg_1 == '0) ? '0 : reg_file[rd_reg_1];
    rd_data_2 = (rd_reg_2 == '0) ? '0 : reg_file[rd_reg_2];
  end

endmodule
