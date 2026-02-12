/*
Register file module for single cycle rv32i partial implementation.

Control:
  wr_en:    active high write enable signal

Input:
  rd_reg_1: address for read data 1
  rd_reg_2: address for read data 2

  wr_reg:   adress we are writting to
  wr_data:  write data, writen into wr_reg on rising clk edg

Output:
  rd_data_1:  read data read out from rd_reg_1
  rd_data_2:  read data read out from rd_reg_2

Note:
  Register x0 (reg_file[0]) always returns '0
*/
import riscv_32i_defs_pkg::*;

module reg_file (
  input logic clk,

  //control
  input logic wr_en,

  //input
  input rf_addr_t rd_reg_1,
  input rf_addr_t rd_reg_2,

  input rf_addr_t wr_reg,
  input word_t wr_data,

  //output
  output word_t rd_data_1,
  output word_t rd_data_2
);
  //32 x 32'b registers, x0 initialized to 0
  word_t reg_file [0:RF_DEPTH-1];
  initial reg_file[X0] = '0;

  //writting into reg file
  always_ff @(posedge clk) begin
    if(wr_en && (wr_reg != X0)) begin   //if wr_en and not writting to x0, then write
      reg_file[wr_reg] <= wr_data;
    end
  end

  //reading from reg file
  always_comb begin
    //output 0 out from x0, else output data stored in register
    rd_data_1 = (rd_reg_1 == X0) ? '0 : reg_file[rd_reg_1];
    rd_data_2 = (rd_reg_2 == X0) ? '0 : reg_file[rd_reg_2];
  end
endmodule
