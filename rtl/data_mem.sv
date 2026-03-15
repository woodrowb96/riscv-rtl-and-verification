/*
  Data memory module for a riscv rv32i implementation

Control:
  wr_sel: 4bit byte sensitive write enable signal.
          - We can enable and disable individual bytes in a word to write to, ie:
              4'b0000 -> no write
              4'b0001 -> write to the least significant byte
              4'b0110 -> write to the middle two bytes
              4'b1000 -> write to the most significant byte
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

NOTE:  OUT_OF_BOUND ACCESS
  Out of bound access silently wraps around to the start of memory.
  This module doesnt throw a flag or error and leaves that to other parts of the implementation.
*/
import rv32i_defs_pkg::*;
import rv32i_config_pkg::*;
import rv32i_control_pkg::*;

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
  typedef logic [$clog2(DATA_MEM_DEPTH)-1:0] lut_addr_t;

  //lut ram ports
  lut_addr_t   byte_0_addr, byte_1_addr, byte_2_addr, byte_3_addr;
  byte_t [3:0] lut_ram_rd_data;
  byte_t [3:0] lut_ram_wr_data;
  byte_sel_t   lut_ram_wr_en;

  //spilt out wr_data bytes
  byte_t wr_data_byte_3, wr_data_byte_2, wr_data_byte_1, wr_data_byte_0;
  assign wr_data_byte_3 = wr_data[31:24];
  assign wr_data_byte_2 = wr_data[23:16];
  assign wr_data_byte_1 = wr_data[15:8];
  assign wr_data_byte_0 = wr_data[7:0];

  /*************** ENFORCE POWER OF 2 DEPTH *************************/
  //Depth needs to be a power of 2, so addresses wrap properly
  /******************************************************************/
  initial assert((DATA_MEM_DEPTH & (DATA_MEM_DEPTH - 1)) == 0) else
    $fatal("DATA_MEM_DEPTH must be power of 2");


  /**************************** MEMORY ********************************/
  // Data Memory is a word wide but we need byte addressing, so we give
  // each byte in memory its own memory element.
  //
  // A word-aligned read is formed from the byte lanes as:
  //    {byte_lane_3, byte_lane_2, byte_lane_1, byte_lane_0}
  /********************************************************************/

  //byte lane 3 (Word-aligned Most Sig Byte)
  lut_ram #(.LUT_DEPTH(DATA_MEM_DEPTH), .LUT_WIDTH(BYTE_LEN))
    u_byte_3 (.clk(clk), .wr_en(lut_ram_wr_en[3]), .wr_addr(byte_3_addr),
              .rd_addr(byte_3_addr), .wr_data(lut_ram_wr_data[3]), .rd_data(lut_ram_rd_data[3]));

  //byte lane 2
  lut_ram #(.LUT_DEPTH(DATA_MEM_DEPTH), .LUT_WIDTH(BYTE_LEN))
    u_byte_2 (.clk(clk), .wr_en(lut_ram_wr_en[2]), .wr_addr(byte_2_addr),
              .rd_addr(byte_2_addr), .wr_data(lut_ram_wr_data[2]), .rd_data(lut_ram_rd_data[2]));

  //byte lane 1
  lut_ram #(.LUT_DEPTH(DATA_MEM_DEPTH), .LUT_WIDTH(BYTE_LEN))
    u_byte_1 (.clk(clk), .wr_en(lut_ram_wr_en[1]), .wr_addr(byte_1_addr),
              .rd_addr(byte_1_addr), .wr_data(lut_ram_wr_data[1]), .rd_data(lut_ram_rd_data[1]));

  //byte lane 0 (Word-aligned Least Sig Byte)
  lut_ram #(.LUT_DEPTH(DATA_MEM_DEPTH), .LUT_WIDTH(BYTE_LEN))
    u_byte_0 (.clk(clk), .wr_en(lut_ram_wr_en[0]), .wr_addr(byte_0_addr),
              .rd_addr(byte_0_addr), .wr_data(lut_ram_wr_data[0]), .rd_data(lut_ram_rd_data[0]));


  /********************** SIGNAL ROUTING ******************************/
  //look at the byte offset and:
  //  - calc the correct line in memory each byte_lane should point to
  //  - route wr_data bytes and wr_sel bits to the proper byte_lanes
  //  - route byte_lane output bytes to form the correct rd_data
  /*******************************************************************/

  always_comb begin
    unique case(addr[1:0])

      /******* offset 0 ******/
      //We are word aligned
      // - Byte_lane 0 is the LSB
      // - Byte_lane 3 is the MSB
      // - wr_sel/data routed to: {byte_lane_3, byte_lane_2, byte_lane_1, byte_lane_0}
      // - rd_data formed from:   {byte_lane_3, byte_lane_2, byte_lane_1, byte_lane_0}
      2'b00: begin
        byte_3_addr = addr[XLEN-1:2]; //most significant byte
        byte_2_addr = addr[XLEN-1:2];
        byte_1_addr = addr[XLEN-1:2];
        byte_0_addr = addr[XLEN-1:2]; //least significant byte

        lut_ram_wr_en   = {wr_sel[3], wr_sel[2], wr_sel[1], wr_sel[0]};
        lut_ram_wr_data = {wr_data_byte_3, wr_data_byte_2, wr_data_byte_1, wr_data_byte_0};

        rd_data = {lut_ram_rd_data[3], lut_ram_rd_data[2], lut_ram_rd_data[1], lut_ram_rd_data[0]};
      end

      /******* offset 1 ******/
      //We are shifted over a byte
      // - Byte_lane 1 is now the LSB
      // - Byte_lane 0 is now the MSB and gets bumped to the next line
      // - wr_sel/data routed to: {byte_lane_2, byte_lane_1, byte_lane_0, byte_lane_3}
      // - rd_data formed from:   {byte_lane_0, byte_lane_3, byte_lane_2, byte_lane_1}
      2'b01: begin
        byte_0_addr = addr[XLEN-1:2] + 'd1; //MSB
        byte_3_addr = addr[XLEN-1:2];
        byte_2_addr = addr[XLEN-1:2];
        byte_1_addr = addr[XLEN-1:2];       //LSB

        lut_ram_wr_en   = {wr_sel[2], wr_sel[1], wr_sel[0], wr_sel[3]};
        lut_ram_wr_data = {wr_data_byte_2, wr_data_byte_1, wr_data_byte_0, wr_data_byte_3};

        rd_data = {lut_ram_rd_data[0], lut_ram_rd_data[3], lut_ram_rd_data[2], lut_ram_rd_data[1]};
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - Byte_lane 2 is now the LSB
      // - Byte_lane 1 is now the MSB and gets bumped to the next line
      // - wr_sel/data routed to: {byte_lane_1, byte_lane_0, byte_lane_3, byte_lane_2}
      // - rd_data formed from:   {byte_lane_1, byte_lane_0, byte_lane_3, byte_lane_2}
      2'b10: begin
        byte_1_addr = addr[XLEN-1:2] + 'd1;   //MSB
        byte_0_addr = addr[XLEN-1:2] + 'd1;
        byte_3_addr = addr[XLEN-1:2];
        byte_2_addr = addr[XLEN-1:2];         //LSB

        lut_ram_wr_en   = {wr_sel[1], wr_sel[0], wr_sel[3], wr_sel[2]};
        lut_ram_wr_data = {wr_data_byte_1, wr_data_byte_0, wr_data_byte_3, wr_data_byte_2};

        rd_data = {lut_ram_rd_data[1], lut_ram_rd_data[0], lut_ram_rd_data[3], lut_ram_rd_data[2]};
      end

      /******* offset 3 ******/
      //We are shifted over three bytes
      // - Byte_lane 3 is now the LSB
      // - Byte_lane 2 is now the MSB and gets bumped to the next line
      // - wr_sel/data routed to: {byte_lane_0, byte_lane_3, byte_lane_2, byte_lane_1}
      // - rd_data formed from:   {byte_lane_2, byte_lane_1, byte_lane_0, byte_lane_3}
      2'b11: begin
        byte_2_addr = addr[XLEN-1:2] + 'd1;    //MSB
        byte_1_addr = addr[XLEN-1:2] + 'd1;
        byte_0_addr = addr[XLEN-1:2] + 'd1;
        byte_3_addr = addr[XLEN-1:2];          //LSB

        lut_ram_wr_en   = {wr_sel[0], wr_sel[3], wr_sel[2], wr_sel[1]};
        lut_ram_wr_data = {wr_data_byte_0, wr_data_byte_3, wr_data_byte_2, wr_data_byte_1};

        rd_data = {lut_ram_rd_data[2], lut_ram_rd_data[1], lut_ram_rd_data[0], lut_ram_rd_data[3]};
      end
    endcase
  end
endmodule
