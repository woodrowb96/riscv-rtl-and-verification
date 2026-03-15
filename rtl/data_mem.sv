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

  lut_addr_t byte_0_addr, byte_1_addr, byte_2_addr, byte_3_addr;
  byte_t     byte_0_rd, byte_1_rd, byte_2_rd, byte_3_rd;
  byte_t     byte_0_wr, byte_1_wr, byte_2_wr, byte_3_wr;
  byte_sel_t lut_ram_wr_en;

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
    u_byte_3 (.clk(clk), .wr_en(lut_ram_wr_en[3]), .wr_addr(byte_3_addr), .rd_addr(byte_3_addr), .wr_data(byte_3_wr), .rd_data(byte_3_rd));

  //byte lane 2
  lut_ram #(.LUT_DEPTH(DATA_MEM_DEPTH), .LUT_WIDTH(BYTE_LEN))
    u_byte_2 (.clk(clk), .wr_en(lut_ram_wr_en[2]), .wr_addr(byte_2_addr), .rd_addr(byte_2_addr), .wr_data(byte_2_wr), .rd_data(byte_2_rd));

  //byte lane 1
  lut_ram #(.LUT_DEPTH(DATA_MEM_DEPTH), .LUT_WIDTH(BYTE_LEN))
    u_byte_1 (.clk(clk), .wr_en(lut_ram_wr_en[1]), .wr_addr(byte_1_addr), .rd_addr(byte_1_addr), .wr_data(byte_1_wr), .rd_data(byte_1_rd));

  //byte lane 0 (Word-aligned Least Sig Byte)
  lut_ram #(.LUT_DEPTH(DATA_MEM_DEPTH), .LUT_WIDTH(BYTE_LEN))
    u_byte_0 (.clk(clk), .wr_en(lut_ram_wr_en[0]), .wr_addr(byte_0_addr), .rd_addr(byte_0_addr), .wr_data(byte_0_wr), .rd_data(byte_0_rd));


  /********************** SIGNAL ROUTING ******************************/
  //look at the byte offset and:
  //  - calc the correct line in memory each byte_lane should point to
  //  - route wr_data bytes and wr_sel bits to the proper byte_lanes
  //  - route byte_lane output bytes to form the correct rd_data
  /*******************************************************************/
  always_comb begin
    case(addr[1:0])

      /******* offset 0 ******/
      //We are word aligned
      // - Byte_lane 0 is the LSB
      // - Byte_lane 3 is the MSB
      // - wr_sel     : {byte_lane_3, byte_lane_2, byte_lane_1, byte_lane_0}
      // - wr/rd_data : {byte_lane_3, byte_lane_2, byte_lane_1, byte_lane_0}
      2'b00: begin
        byte_3_addr = addr[XLEN-1:2]; //most significant byte
        byte_2_addr = addr[XLEN-1:2];
        byte_1_addr = addr[XLEN-1:2];
        byte_0_addr = addr[XLEN-1:2]; //least significant byte

        lut_ram_wr_en = {wr_sel[3], wr_sel[2], wr_sel[1], wr_sel[0]};
        {byte_3_wr, byte_2_wr, byte_1_wr, byte_0_wr} = wr_data;

        rd_data = {byte_3_rd, byte_2_rd, byte_1_rd, byte_0_rd};
      end

      /******* offset 1 ******/
      //We are shifted over a byte
      // - Byte_lane 1 is now the LSB
      // - Byte_lane 0 is now the MSB and gets bumped to the next line
      // - wr_sel     : {byte_lane_2, byte_lane_1, byte_lane_0, byte_lane_3}
      // - wr/rd_data : {byte_lane_0, byte_lane_3, byte_lane_2, byte_lane_1}
      2'b01: begin
        byte_0_addr = addr[XLEN-1:2] + 'd1; //MSB
        byte_3_addr = addr[XLEN-1:2];
        byte_2_addr = addr[XLEN-1:2];
        byte_1_addr = addr[XLEN-1:2];       //LSB

        lut_ram_wr_en = {wr_sel[2], wr_sel[1], wr_sel[0], wr_sel[3]};

        rd_data = {byte_0_rd, byte_3_rd, byte_2_rd, byte_1_rd};
        {byte_0_wr, byte_3_wr, byte_2_wr, byte_1_wr} = wr_data;
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - Byte_lane 2 is now the LSB
      // - Byte_lane 1 is now the MSB and gets bumped to the next line
      // - wr_sel     : {byte_lane_1, byte_lane_0, byte_lane_3, byte_lane_2}
      // - wr/rd_data : {byte_lane_1, byte_lane_0, byte_lane_3, byte_lane_2}
      2'b10: begin
        byte_1_addr = addr[XLEN-1:2] + 'd1;   //MSB
        byte_0_addr = addr[XLEN-1:2] + 'd1;
        byte_3_addr = addr[XLEN-1:2];
        byte_2_addr = addr[XLEN-1:2];         //LSB

        lut_ram_wr_en = {wr_sel[1], wr_sel[0], wr_sel[3], wr_sel[2]};

        rd_data = {byte_1_rd, byte_0_rd, byte_3_rd, byte_2_rd};
        {byte_1_wr, byte_0_wr, byte_3_wr, byte_2_wr} = wr_data;
      end

      /******* offset 3 ******/
      //We are shifted over three bytes
      // - Byte_lane 3 is now the LSB
      // - Byte_lane 2 is now the MSB and gets bumped to the next line
      // - wr_sel     : {byte_lane_0, byte_lane_3, byte_lane_2, byte_lane_1}
      // - wr/rd_data : {byte_lane_2, byte_lane_1, byte_lane_0, byte_lane_3}
      2'b11: begin
        byte_2_addr = addr[XLEN-1:2] + 'd1;    //MSB
        byte_1_addr = addr[XLEN-1:2] + 'd1;
        byte_0_addr = addr[XLEN-1:2] + 'd1;
        byte_3_addr = addr[XLEN-1:2];          //LSB

        lut_ram_wr_en = {wr_sel[0], wr_sel[3], wr_sel[2], wr_sel[1]};

        rd_data = {byte_2_rd, byte_1_rd, byte_0_rd, byte_3_rd};
        {byte_2_wr, byte_1_wr, byte_0_wr, byte_3_wr} = wr_data;
      end
    endcase
  end
endmodule
