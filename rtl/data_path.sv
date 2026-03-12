/*
    The Data Path module for a riscv rv32i implementation (Curently single cycle).

CLK:

  - The current implementation is a single cycle one. So the whole data path operates
    over the duration of one clk cycle synced to the rising edge of the clk.

Reset:

  - reset_n: syncronous active low reset signal.
      - resets all necesary signals in the data_path on the posedge of the clk

      - pc: reset to 0

Control:
  ALU_CONTROL:

  - alu_op:
      - used to select the current alu operation
      - See ./package/rv32i_control_pkg.sv and ./alu.sv for full details

  WRITE ENABLES:

  - rf_wr_en (1 bit): active high write enable for the reg_file
      - 1: write
      - 0: no write

  - mem_wr_sel (4 bits): write select mode for the data memory
      - Used to select which bytes in a word are being written to
      - 4'b0000 -> no write
      - 4'b0010 -> write to the second to last byte
      - 4'b1111 -> write the whole word
*/
import rv32i_control_pkg::*;

module data_path #(parameter string PROGRAM = "NO_INST_MEM_PROGRAM_SPECIFIED")(
  //clock
  input logic clk,

  //reset
  input logic reset_n,

  //Control
  //ALU
  input alu_op_t      alu_op,
  //Write Enable
  input logic         rf_wr_en,
  input byte_sel_t    mem_wr_sel,
  //Data Flow
  input logic         branch,
  input alu_src_sel_t alu_src_sel,
  input wb_sel_t      wb_sel
);

  /*=================================================================================*/
  /*--------------------------- INSTRUCTION FETCH -----------------------------------*/
  /*=================================================================================*/

  // /******* PC ********/
  // always_ff @(posedge clk) begin
  //   if(~reset_n) begin
  //     p
  //   end
  // end


endmodule
