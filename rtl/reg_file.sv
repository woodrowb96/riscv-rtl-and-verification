/*
  Register file module for a riscv rv32i implementation.

Control:
  wr_en: active high write enable signal

Input:
  wr_reg:  register index we are writing to
  wr_data: write data
            - synchronous writes
            - written into wr_reg @(posedge clk)

  rd_reg_1: index we are reading rd_data_1 from
  rd_reg_2: index we are reading rd_data_2 from

Output:
  rd_data_1: data read from rd_reg_1
  rd_data_2: data read from rd_reg_2
              - asynchronous reads

NOTE:
     - Register x0 (reg_file[0]) always returns '0
*/
import rv32i_defs_pkg::*;

module reg_file (
  //clk
  input logic clk,

  //control
  input logic wr_en,

  //input
  input rf_addr_t wr_reg,
  input word_t wr_data,

  input rf_addr_t rd_reg_1,
  input rf_addr_t rd_reg_2,

  //output
  output word_t rd_data_1,
  output word_t rd_data_2
);
  /************ REGISTER FILE ***********************/
  word_t reg_file [0:RF_DEPTH-1];
  initial reg_file[X0] = '0; //for sim, to help make assertions easier to write

  /************ SYNCHRONOUS WRITES *******************/
  always_ff @(posedge clk) begin
    if(wr_en && (wr_reg != X0)) begin //make sure we dont write to x0
      reg_file[wr_reg] <= wr_data;
    end
  end

  /************ ASYNCHRONOUS READS *******************/
  always_comb begin
    rd_data_1 = (rd_reg_1 == X0) ? '0 : reg_file[rd_reg_1];
    rd_data_2 = (rd_reg_2 == X0) ? '0 : reg_file[rd_reg_2];
  end
endmodule
