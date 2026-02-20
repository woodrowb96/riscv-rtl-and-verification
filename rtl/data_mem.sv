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
  //Signals to hook up the 4 lut_rams
  typedef logic [$clog2(DATA_MEM_DEPTH)-1:0] lut_addr_t;
  lut_addr_t byte_0_addr, byte_1_addr, byte_2_addr, byte_3_addr;
  byte_t     byte_0_rd, byte_1_rd, byte_2_rd, byte_3_rd;
  byte_t     byte_0_wr, byte_1_wr, byte_2_wr, byte_3_wr;
  byte_sel_t lut_ram_wr_en;

  always_comb begin

    //look at the byte offset and:
    //  - calculate the correct line in memory each byte should come from
    //  - route the rd_data, wr_data and wr_sel signals to the proper bytes
    case(addr[1:0])

      /*** offset 0 — rd/wr_data: {byte_3, byte_2, byte_1, byte_0} ***/
      2'b00: begin
        byte_3_addr = addr[XLEN-1:2];
        byte_2_addr = addr[XLEN-1:2];
        byte_1_addr = addr[XLEN-1:2];
        byte_0_addr = addr[XLEN-1:2];

        //everything is aligned with the words stored in memory
        //so we dont need to shift the wr_sel over
        lut_ram_wr_en = {wr_sel[3], wr_sel[2], wr_sel[1], wr_sel[0]};

        rd_data = {byte_3_rd, byte_2_rd, byte_1_rd, byte_0_rd};
        {byte_3_wr, byte_2_wr, byte_1_wr, byte_0_wr} = wr_data;
      end

      /*** offset 1 — rd/wr_data: {byte_0, byte_3, byte_2, byte_1} ***/
      2'b01: begin
        //we are shifted over by 1 byte,
        //so byte 0 gets bumped to the next line in memory
        byte_3_addr = addr[XLEN-1:2];
        byte_2_addr = addr[XLEN-1:2];
        byte_1_addr = addr[XLEN-1:2];
        byte_0_addr = addr[XLEN-1:2] + 'd1;

        //we are reading starting at byte 1 now,
        //so we need to rotate the wr_sel one to the left
        lut_ram_wr_en = {wr_sel[2], wr_sel[1], wr_sel[0], wr_sel[3]};

        rd_data = {byte_0_rd, byte_3_rd, byte_2_rd, byte_1_rd};
        {byte_0_wr, byte_3_wr, byte_2_wr, byte_1_wr} = wr_data;
      end

      /*** offset 2 — rd/wr_data: {byte_1, byte_0, byte_3, byte_2} ***/
      2'b10: begin
        //bytes 0 and 1 spill over to the next line in mem
        byte_3_addr = addr[XLEN-1:2];
        byte_2_addr = addr[XLEN-1:2];
        byte_1_addr = addr[XLEN-1:2] + 'd1;
        byte_0_addr = addr[XLEN-1:2] + 'd1;

        //shift the wr_sel signal over by two
        lut_ram_wr_en = {wr_sel[1], wr_sel[0], wr_sel[3], wr_sel[2]};

        rd_data = {byte_1_rd, byte_0_rd, byte_3_rd, byte_2_rd};
        {byte_1_wr, byte_0_wr, byte_3_wr, byte_2_wr} = wr_data;
      end

      /*** offset 3 — rd/wr_data: {byte_2, byte_1, byte_0, byte_3} ***/
      2'b11: begin
        //bytes 0,1,2 spill over to the next line in mem
        byte_3_addr = addr[XLEN-1:2];
        byte_2_addr = addr[XLEN-1:2] + 'd1;
        byte_1_addr = addr[XLEN-1:2] + 'd1;
        byte_0_addr = addr[XLEN-1:2] + 'd1;

        //shift the wr_sel signal over by three
        lut_ram_wr_en = {wr_sel[0], wr_sel[3], wr_sel[2], wr_sel[1]};

        rd_data = {byte_2_rd, byte_1_rd, byte_0_rd, byte_3_rd};
        {byte_2_wr, byte_1_wr, byte_0_wr, byte_3_wr} = wr_data;
      end
    endcase
  end

  //Data memory is a word wide, but we can acess it by byte, so we give each
  //byte lane its own memory.
  //A word length line in memory is (from most significant byte, to least significant byte):
  //  {byte_3, byte_2, byte_1, byte_0}
  lut_ram #(.LUT_DEPTH(DATA_MEM_DEPTH), .LUT_WIDTH(BYTE_LEN))
    byte_3 (.clk(clk), .wr_en(lut_ram_wr_en[3]), .wr_addr(byte_3_addr), .rd_addr(byte_3_addr), .wr_data(byte_3_wr), .rd_data(byte_3_rd));
  lut_ram #(.LUT_DEPTH(DATA_MEM_DEPTH), .LUT_WIDTH(BYTE_LEN))
    byte_2 (.clk(clk), .wr_en(lut_ram_wr_en[2]), .wr_addr(byte_2_addr), .rd_addr(byte_2_addr), .wr_data(byte_2_wr), .rd_data(byte_2_rd));
  lut_ram #(.LUT_DEPTH(DATA_MEM_DEPTH), .LUT_WIDTH(BYTE_LEN))
    byte_1 (.clk(clk), .wr_en(lut_ram_wr_en[1]), .wr_addr(byte_1_addr), .rd_addr(byte_1_addr), .wr_data(byte_1_wr), .rd_data(byte_1_rd));
  lut_ram #(.LUT_DEPTH(DATA_MEM_DEPTH), .LUT_WIDTH(BYTE_LEN))
    byte_0 (.clk(clk), .wr_en(lut_ram_wr_en[0]), .wr_addr(byte_0_addr), .rd_addr(byte_0_addr), .wr_data(byte_0_wr), .rd_data(byte_0_rd));
endmodule
