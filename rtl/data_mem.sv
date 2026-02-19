/*
  Data memory module for a riscv rv32i implementation

Control:
  wr_sel: 4bit byte sensitive write enable signal.
          - We can enable and disable individual bytes in a word to write to, ie:
              4'b0000 -> no write
              4'b0010 -> write to the second to last byte
              4'b1111 -> write the whole word

Input:
  addr: Address we are writing and reading to.
        - Memory is byte addressable, so we can start our reads and writes from any byte.

  wr_data:  32bit write data
            - clocked in @(posedge clk)
            - Memory is byte addressable, but we can write in up to a word of data
            - Use wr_sel to select which bytes in the word are getting written

Output:
  rd_data:  32bit read data
            - read out combinatorially
            - Byte addressable
            - No sub byte control (so no rd_sel like we do for writes).
              We always read out a whole word of data and
              leave the sub byte selection to the datapath.
*/
import riscv_32i_defs_pkg::*;
import riscv_32i_config_pkg::*;
import riscv_32i_control_pkg::*;

module data_mem (
  //clk
  input logic clk,

  //control
  input byte_sel_t wr_sel,

  //input
  input word_t addr,
  input word_t wr_data,

  //output
  output word_t rd_data
);



endmodule
