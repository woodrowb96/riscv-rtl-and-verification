/*
  The SVA concurrent property versions of all assertions are commented out at the
  bottom of this file. I decided to leave them in so anyone can see what I
  intended to do if the tool worked. They are replaced with immediate assertions
  wrapped in always @(posedge clk) blocks above them.

  VIVADO BUG:
    xsim crashes with a FATAL_ERROR ("Vivado Simulator kernel has discovered
    an exceptional condition from which it cannot recover") when evaluating
    concurrent SVA properties that use hierarchical references
    (e.g. data_mem.byte_0_addr) passed as property arguments.

*/

import rv32i_defs_pkg::*;
import rv32i_control_pkg::*;

module data_mem_assert(
  input logic clk,
  input byte_sel_t wr_sel,
  input word_t addr,
  input word_t wr_data,
  input word_t rd_data
);
  typedef logic [$clog2(DATA_MEM_DEPTH)-1:0] lut_addr_t;

  /*=============================================================================*/
  /*------------------------ LUT_RAM ASSERTIONS ---------------------------------*/
  /*=============================================================================*/

  //lut ram assertions will provide the write and read assertions directly touching memory
  bind data_mem.u_byte_0 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);
  bind data_mem.u_byte_1 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);
  bind data_mem.u_byte_2 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);
  bind data_mem.u_byte_3 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);

  /*=============================================================================*/
  /*------------------------ ADDRESS CALC CHECK ---------------------------------*/
  /*=============================================================================*/

  //We need to look at the offset and make sure each lut_ram's address is
  //getting calculated correctly
  always @(posedge clk) begin
    #0
    unique case(addr[1:0])

      /******* offset 0 ******/
      //We are word aligned
      // - Each lut_ram pulls from the same line in memory
      2'b00: begin
        assert(data_mem.byte_3_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_3: offset=00 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_3_addr);

        assert(data_mem.byte_2_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_2: offset=00 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_2_addr);

        assert(data_mem.byte_1_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_1: offset=00 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_1_addr);

        assert(data_mem.byte_0_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_0: offset=00 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_0_addr);
      end

      /******* offset 1 ******/
      //We are shifted over a byte
      // - byte_0 gets bumped to the next line in memory
      2'b01: begin
        assert(data_mem.byte_3_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_3: offset=01 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_3_addr);

        assert(data_mem.byte_2_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_2: offset=01 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_2_addr);

        assert(data_mem.byte_1_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_1: offset=01 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_1_addr);

        assert(data_mem.byte_0_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_0: offset=01 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr);
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - byte_1 gets bumped to the next line in memory
      2'b10: begin
        assert(data_mem.byte_3_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_3: offset=10 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_3_addr);

        assert(data_mem.byte_2_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_2: offset=10 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_2_addr);

        assert(data_mem.byte_1_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_1: offset=10 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_1_addr);

        assert(data_mem.byte_0_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_0: offset=10 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr);
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - byte_2 gets bumped to the next line in memory
      2'b11: begin
        assert(data_mem.byte_3_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_3: offset=11 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_3_addr);

        assert(data_mem.byte_2_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_2: offset=11 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_2_addr);

        assert(data_mem.byte_1_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_1: offset=11 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_1_addr);

        assert(data_mem.byte_0_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_0: offset=11 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr);
      end

      default: begin end
    endcase
  end

  /*=============================================================================*/
  /*------------------------ WR_SEL ROUTE CHECK ---------------------------------*/
  /*=============================================================================*/
  byte_sel_t lut_ram_wr_en_exp;

  //look at the byte offset and make sure wr_sel is routed correctly
  always @(posedge clk) begin
    #0
    unique case(addr[1:0])

      /******* offset 0 ******/
      //We are word aligned
      // - wr_sel routed to: {u_byte_3, u_byte_2, u_byte_1, u_byte_0}
      2'b00: begin
        lut_ram_wr_en_exp = {wr_sel[3], wr_sel[2], wr_sel[1], wr_sel[0]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] wr_sel route failed: offset=00 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end

      /******* offset 1 ******/
      //We are shifted over a byte
      // - wr_sel routed to: {u_byte_2, u_byte_1, u_byte_0, u_byte_3}
      2'b01: begin
        lut_ram_wr_en_exp = {wr_sel[2], wr_sel[1], wr_sel[0], wr_sel[3]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] wr_sel route failed: offset=01 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - wr_sel routed to: {u_byte_1, u_byte_0, u_byte_3, u_byte_2}
      2'b10: begin
        lut_ram_wr_en_exp = {wr_sel[1], wr_sel[0], wr_sel[3], wr_sel[2]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] wr_sel route failed: offset=10 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end

      /******* offset 3 ******/
      //We are shifted over three bytes
      // - wr_sel routed to: {u_byte_0, u_byte_3, u_byte_2, u_byte_1}
      2'b11: begin
        lut_ram_wr_en_exp = {wr_sel[0], wr_sel[3], wr_sel[2], wr_sel[1]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] wr_sel route failed: offset=11 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end

      default: begin end
    endcase
  end

  /*=============================================================================*/
  /*------------------------ WR_DATA ROUTE CHECK --------------------------------*/
  /*=============================================================================*/
  word_t wr_data_actual;

  //make sure we are routing the right wr_data based on byte offset
  always @(posedge clk) begin
    #0
    unique case(addr[1:0])

      /******* offset 0 ******/
      //We are word aligned
      // - wr_data routed to: {u_byte_3, u_byte_2, u_byte_1, u_byte_0}
      2'b00: begin
        wr_data_actual = { {data_mem.u_byte_3.wr_data,
                            data_mem.u_byte_2.wr_data,
                            data_mem.u_byte_1.wr_data,
                            data_mem.u_byte_0.wr_data} };

        assert(wr_data === wr_data_actual) else
          $error("[DATA_MEM_ASSERT] wr_data route failed: offset=00 addr=%0h, expected=%0h, actual=%0h",
                  addr, wr_data, wr_data_actual);
      end

      /******* offset 1 ******/
      //We are shifted over a byte
      // - wr_data routed to: {u_byte_0, u_byte_3, u_byte_2, u_byte_1}
      2'b01: begin
        wr_data_actual = { {data_mem.u_byte_0.wr_data,
                            data_mem.u_byte_3.wr_data,
                            data_mem.u_byte_2.wr_data,
                            data_mem.u_byte_1.wr_data} };

        assert(wr_data === wr_data_actual) else
          $error("[DATA_MEM_ASSERT] wr_data route failed: offset=01 addr=%0h, expected=%0h, actual=%0h",
                  addr, wr_data, wr_data_actual);
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - wr_data routed to: {u_byte_1, u_byte_0, u_byte_3, u_byte_2}
      2'b10: begin
        wr_data_actual = { {data_mem.u_byte_1.wr_data,
                            data_mem.u_byte_0.wr_data,
                            data_mem.u_byte_3.wr_data,
                            data_mem.u_byte_2.wr_data} };

        assert(wr_data === wr_data_actual) else
          $error("[DATA_MEM_ASSERT] wr_data route failed: offset=10 addr=%0h, expected=%0h, actual=%0h",
                  addr, wr_data, wr_data_actual);
      end

      /******* offset 3 ******/
      //We are shifted over three bytes
      // - wr_data routed to: {u_byte_2, u_byte_1, u_byte_0, u_byte_3}
      2'b11: begin
        wr_data_actual = { {data_mem.u_byte_2.wr_data,
                            data_mem.u_byte_1.wr_data,
                            data_mem.u_byte_0.wr_data,
                            data_mem.u_byte_3.wr_data} };

        assert(wr_data === wr_data_actual) else
          $error("[DATA_MEM_ASSERT] wr_data route failed: offset=11 addr=%0h, expected=%0h, actual=%0h",
                  addr, wr_data, wr_data_actual);
      end

      default: begin end
    endcase
  end

  /*=============================================================================*/
  /*------------------------ RD_DATA ROUTE CHECK --------------------------------*/
  /*=============================================================================*/
  word_t rd_data_exp;

  //Look at the byte offset, construct the expected word directly from the
  //byte lane memories, and compare it to the actual rd_data
  always @(posedge clk) begin
    #0
    unique case(addr[1:0])

      /******* offset 0 ******/
      //We are word aligned
      // - rd_data formed from: {u_byte_3, u_byte_2, u_byte_1, u_byte_0}
      2'b00: begin
        rd_data_exp = {data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(rd_data === rd_data_exp) else
          $error("[DATA_MEM_ASSERT] rd_data route failed: offset=00 addr=%0h, expected=%0h, actual=%0h",
                  addr, rd_data_exp, rd_data);
      end

      /******* offset 1 ******/
      //We are shifted over a byte
      // - rd_data formed from: {u_byte_0(+1), u_byte_3, u_byte_2, u_byte_1}
      2'b01: begin
        rd_data_exp = {data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(rd_data === rd_data_exp) else
          $error("[DATA_MEM_ASSERT] rd_data route failed: offset=01 addr=%0h, expected=%0h, actual=%0h",
                  addr, rd_data_exp, rd_data);
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - rd_data formed from: {u_byte_1(+1), u_byte_0(+1), u_byte_3, u_byte_2}
      2'b10: begin
        rd_data_exp = {data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(rd_data === rd_data_exp) else
          $error("[DATA_MEM_ASSERT] rd_data route failed: offset=10 addr=%0h, expected=%0h, actual=%0h",
                  addr, rd_data_exp, rd_data);
      end

      /******* offset 3 ******/
      //We are shifted over three bytes
      // - rd_data formed from: {u_byte_2(+1), u_byte_1(+1), u_byte_0(+1), u_byte_3}
      2'b11: begin
        rd_data_exp = {data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(rd_data === rd_data_exp) else
          $error("[DATA_MEM_ASSERT] rd_data route failed: offset=11 addr=%0h, expected=%0h, actual=%0h",
                  addr, rd_data_exp, rd_data);
      end

      default: begin end
    endcase
  end

//  /*=============================================================================*/
//  /*------------------------ ADDRESS CALC CHECK ---------------------------------*/
//  /*=============================================================================*/
//
//  //look at the byte_offset and make sure the address calc is correct
//  property addr_calc_prop(logic[1:0] byte_offset, lut_addr_t expected_addr, lut_addr_t actual_addr);
//    @(posedge clk)
//    (data_mem.addr[1:0] === byte_offset) |-> (expected_addr === actual_addr);
//  endproperty
//
//  /******* offset 00 ******/
//  //We are word aligned
//  // - Each lut_ram pulls from the same line in memory
//
//  addr_calc_byte_0_offset_00_assert:
//    assert property(addr_calc_prop(2'b00, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_0_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_0_offset_00: byte_offset:%b, addr expected:%h actual:%h",
//              2'b00, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_0_addr);
//
//  addr_calc_byte_1_offset_00_assert:
//    assert property(addr_calc_prop(2'b00, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_1_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_1_offset_00: byte_offset:%b, addr expected:%h actual:%h",
//              2'b00, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_1_addr);
//
//  addr_calc_byte_2_offset_00_assert:
//    assert property(addr_calc_prop(2'b00, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_2_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_2_offset_00: byte_offset:%b, addr expected:%h actual:%h",
//              2'b00, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_2_addr);
//
//  addr_calc_byte_3_offset_00_assert:
//    assert property(addr_calc_prop(2'b00, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_3_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_3_offset_00: byte_offset:%b, addr expected:%h actual:%h",
//              2'b00, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_3_addr);
//
//  /******* offset 01 ******/
//  //We are shifted over a byte
//  // - byte_0 gets bumped to the next line in memory
//
//  addr_calc_byte_0_offset_01_assert:
//    assert property(addr_calc_prop(2'b01, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_0_offset_01: byte_offset:%b, addr expected:%h actual:%h",
//              2'b01, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr);
//
//  addr_calc_byte_1_offset_01_assert:
//    assert property(addr_calc_prop(2'b01, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_1_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_1_offset_01: byte_offset:%b, addr expected:%h actual:%h",
//              2'b01, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_1_addr);
//
//  addr_calc_byte_2_offset_01_assert:
//    assert property(addr_calc_prop(2'b01, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_2_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_2_offset_01: byte_offset:%b, addr expected:%h actual:%h",
//              2'b01, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_2_addr);
//
//  addr_calc_byte_3_offset_01_assert:
//    assert property(addr_calc_prop(2'b01, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_3_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_3_offset_01: byte_offset:%b, addr expected:%h actual:%h",
//              2'b01, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_3_addr);
//
//  /******* offset 10 ******/
//  //We are shifted over two bytes
//  // - byte_0 and byte_1 get bumped to the next line in memory
//
//  addr_calc_byte_0_offset_10_assert:
//    assert property(addr_calc_prop(2'b10, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_0_offset_10: byte_offset:%b, addr expected:%h actual:%h",
//              2'b10, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr);
//
//  addr_calc_byte_1_offset_10_assert:
//    assert property(addr_calc_prop(2'b10, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_1_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_1_offset_10: byte_offset:%b, addr expected:%h actual:%h",
//              2'b10, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_1_addr);
//
//  addr_calc_byte_2_offset_10_assert:
//    assert property(addr_calc_prop(2'b10, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_2_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_2_offset_10: byte_offset:%b, addr expected:%h actual:%h",
//              2'b10, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_2_addr);
//
//  addr_calc_byte_3_offset_10_assert:
//    assert property(addr_calc_prop(2'b10, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_3_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_3_offset_10: byte_offset:%b, addr expected:%h actual:%h",
//              2'b10, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_3_addr);
//
//  /******* offset 11 ******/
//  //We are shifted over three bytes
//  // - byte_0, byte_1, and byte_2 get bumped to the next line in memory
//
//  addr_calc_byte_0_offset_11_assert:
//    assert property(addr_calc_prop(2'b11, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_0_offset_11: byte_offset:%b, addr expected:%h actual:%h",
//              2'b11, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr);
//
//  addr_calc_byte_1_offset_11_assert:
//    assert property(addr_calc_prop(2'b11, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_1_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_1_offset_11: byte_offset:%b, addr expected:%h actual:%h",
//              2'b11, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_1_addr);
//
//  addr_calc_byte_2_offset_11_assert:
//    assert property(addr_calc_prop(2'b11, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_2_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_2_offset_11: byte_offset:%b, addr expected:%h actual:%h",
//              2'b11, lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_2_addr);
//
//  addr_calc_byte_3_offset_11_assert:
//    assert property(addr_calc_prop(2'b11, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_3_addr)) else
//      $error("[DATA_MEM_ASSERT] addr_calc_byte_3_offset_11: byte_offset:%b, addr expected:%h actual:%h",
//              2'b11, lut_addr_t'(addr[XLEN-1:2]), data_mem.byte_3_addr);
//
//  /*=============================================================================*/
//  /*------------------------ WR_SEL ROUTE CHECK ---------------------------------*/
//  /*=============================================================================*/
//
//  //look at the byte offset and make sure wr_sel is routed correctly
//  property wr_sel_route_prop(logic[1:0] byte_offset, byte_sel_t expected_lut_wr_en, byte_sel_t actual_lut_wr_en);
//    @(posedge clk)
//    (data_mem.addr[1:0] === byte_offset) |-> (expected_lut_wr_en === actual_lut_wr_en);
//  endproperty
//
//  byte_sel_t lut_ram_wr_en_exp;
//  always_comb begin
//    unique case(addr[1:0])
//      2'b00: begin
//        lut_ram_wr_en_exp = {wr_sel[3], wr_sel[2], wr_sel[1], wr_sel[0]};
//      end
//      2'b01: begin
//        lut_ram_wr_en_exp = {wr_sel[2], wr_sel[1], wr_sel[0], wr_sel[3]};
//      end
//      2'b10: begin
//        lut_ram_wr_en_exp = {wr_sel[1], wr_sel[0], wr_sel[3], wr_sel[2]};
//      end
//      2'b11: begin
//        lut_ram_wr_en_exp = {wr_sel[0], wr_sel[3], wr_sel[2], wr_sel[1]};
//      end
//      default: begin
//        lut_ram_wr_en_exp = 'x;
//      end
//    endcase
//  end
//
//  /******* offset 00 ******/
//  //We are word aligned
//  // - wr_sel routed to: {u_byte_3, u_byte_2, u_byte_1, u_byte_0}
//
//  wr_sel_route_offset_00_assert:
//    assert property(wr_sel_route_prop(2'b00, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en)) else
//      $error("[DATA_MEM_ASSERT] wr_sel_route_offset_00: byte_offset:%b, expected:%b actual:%b",
//              2'b00, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
//
//  /******* offset 01 ******/
//  //We are shifted over a byte
//  // - wr_sel routed to: {u_byte_2, u_byte_1, u_byte_0, u_byte_3}
//
//  wr_sel_route_offset_01_assert:
//    assert property(wr_sel_route_prop(2'b01, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en)) else
//      $error("[DATA_MEM_ASSERT] wr_sel_route_offset_01: byte_offset:%b, expected:%b actual:%b",
//              2'b01, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
//
//  /******* offset 10 ******/
//  //We are shifted over two bytes
//  // - wr_sel routed to: {u_byte_1, u_byte_0, u_byte_3, u_byte_2}
//
//  wr_sel_route_offset_10_assert:
//    assert property(wr_sel_route_prop(2'b10, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en)) else
//      $error("[DATA_MEM_ASSERT] wr_sel_route_offset_10: byte_offset:%b, expected:%b actual:%b",
//              2'b10, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
//
//  /******* offset 11 ******/
//  //We are shifted over three bytes
//  // - wr_sel routed to: {u_byte_0, u_byte_3, u_byte_2, u_byte_1}
//
//  wr_sel_route_offset_11_assert:
//    assert property(wr_sel_route_prop(2'b11, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en)) else
//      $error("[DATA_MEM_ASSERT] wr_sel_route_offset_11: byte_offset:%b, expected:%b actual:%b",
//              2'b11, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
//
//  /*=============================================================================*/
//  /*------------------------ WR_DATA ROUTE CHECK --------------------------------*/
//  /*=============================================================================*/
//
//  //make sure we are routing the right wr_data based on byte offset
//  property wr_data_route_prop(logic[1:0] byte_offset, word_t expected_wr_data, word_t actual_wr_data);
//    @(posedge clk)
//    (data_mem.addr[1:0] === byte_offset) |-> (expected_wr_data === actual_wr_data);
//  endproperty
//
//  word_t wr_data_actual;
//  always_comb begin
//    unique case(addr[1:0])
//      2'b00: begin
//        wr_data_actual = {data_mem.u_byte_3.wr_data, data_mem.u_byte_2.wr_data,
//                          data_mem.u_byte_1.wr_data, data_mem.u_byte_0.wr_data};
//      end
//      2'b01: begin
//        wr_data_actual = {data_mem.u_byte_0.wr_data, data_mem.u_byte_3.wr_data,
//                          data_mem.u_byte_2.wr_data, data_mem.u_byte_1.wr_data};
//      end
//      2'b10: begin
//        wr_data_actual = {data_mem.u_byte_1.wr_data, data_mem.u_byte_0.wr_data,
//                          data_mem.u_byte_3.wr_data, data_mem.u_byte_2.wr_data};
//      end
//      2'b11: begin
//        wr_data_actual = {data_mem.u_byte_2.wr_data, data_mem.u_byte_1.wr_data,
//                          data_mem.u_byte_0.wr_data, data_mem.u_byte_3.wr_data};
//      end
//      default: begin
//        wr_data_actual = 'x;
//      end
//    endcase
//  end
//
//  /******* offset 00 ******/
//  //We are word aligned
//  // - wr_data routed to: {u_byte_3, u_byte_2, u_byte_1, u_byte_0}
//
//  wr_data_route_offset_00_assert:
//    assert property(wr_data_route_prop(2'b00, wr_data, wr_data_actual)) else
//      $error("[DATA_MEM_ASSERT] wr_data_route_offset_00: byte_offset:%b, expected:%h actual:%h",
//              2'b00, wr_data, wr_data_actual);
//
//  /******* offset 01 ******/
//  //We are shifted over a byte
//  // - wr_data routed to: {u_byte_0, u_byte_3, u_byte_2, u_byte_1}
//
//  wr_data_route_offset_01_assert:
//    assert property(wr_data_route_prop(2'b01, wr_data, wr_data_actual)) else
//      $error("[DATA_MEM_ASSERT] wr_data_route_offset_01: byte_offset:%b, expected:%h actual:%h",
//              2'b01, wr_data, wr_data_actual);
//
//  /******* offset 10 ******/
//  //We are shifted over two bytes
//  // - wr_data routed to: {u_byte_1, u_byte_0, u_byte_3, u_byte_2}
//
//  wr_data_route_offset_10_assert:
//    assert property(wr_data_route_prop(2'b10, wr_data, wr_data_actual)) else
//      $error("[DATA_MEM_ASSERT] wr_data_route_offset_10: byte_offset:%b, expected:%h actual:%h",
//              2'b10, wr_data, wr_data_actual);
//
//  /******* offset 11 ******/
//  //We are shifted over three bytes
//  // - wr_data routed to: {u_byte_2, u_byte_1, u_byte_0, u_byte_3}
//
//  wr_data_route_offset_11_assert:
//    assert property(wr_data_route_prop(2'b11, wr_data, wr_data_actual)) else
//      $error("[DATA_MEM_ASSERT] wr_data_route_offset_11: byte_offset:%b, expected:%h actual:%h",
//              2'b11, wr_data, wr_data_actual);
//
//  /*=============================================================================*/
//  /*------------------------ RD_DATA ROUTE CHECK --------------------------------*/
//  /*=============================================================================*/
//
//  //Look at the byte offset, construct the expected word directly from the
//  //byte lane memories, and compare it to the actual rd_data
//  property rd_data_route_prop(logic[1:0] byte_offset, word_t expected_rd_data, word_t actual_rd_data);
//    @(posedge clk)
//    (data_mem.addr[1:0] === byte_offset) |-> (expected_rd_data === actual_rd_data);
//  endproperty
//
//  word_t rd_data_exp;
//  always_comb begin
//    unique case(addr[1:0])
//      2'b00: begin
//        rd_data_exp = {data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
//                       data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])],
//                       data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2])],
//                       data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2])]};
//      end
//      2'b01: begin
//        rd_data_exp = {data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
//                       data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
//                       data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])],
//                       data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2])]};
//      end
//      2'b10: begin
//        rd_data_exp = {data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
//                       data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
//                       data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
//                       data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])]};
//      end
//      2'b11: begin
//        rd_data_exp = {data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
//                       data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
//                       data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
//                       data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])]};
//      end
//      default: begin
//        rd_data_exp = 'x;
//      end
//    endcase
//  end
//
//  /******* offset 00 ******/
//  //We are word aligned
//  // - rd_data formed from: {u_byte_3, u_byte_2, u_byte_1, u_byte_0}
//
//  rd_data_route_offset_00_assert:
//    assert property(rd_data_route_prop(2'b00, rd_data_exp, rd_data)) else
//      $error("[DATA_MEM_ASSERT] rd_data_route_offset_00: byte_offset:%b, expected:%h actual:%h",
//              2'b00, rd_data_exp, rd_data);
//
//  /******* offset 01 ******/
//  //We are shifted over a byte
//  // - rd_data formed from: {u_byte_0(+1), u_byte_3, u_byte_2, u_byte_1}
//
//  rd_data_route_offset_01_assert:
//    assert property(rd_data_route_prop(2'b01, rd_data_exp, rd_data)) else
//      $error("[DATA_MEM_ASSERT] rd_data_route_offset_01: byte_offset:%b, expected:%h actual:%h",
//              2'b01, rd_data_exp, rd_data);
//
//  /******* offset 10 ******/
//  //We are shifted over two bytes
//  // - rd_data formed from: {u_byte_1(+1), u_byte_0(+1), u_byte_3, u_byte_2}
//
//  rd_data_route_offset_10_assert:
//    assert property(rd_data_route_prop(2'b10, rd_data_exp, rd_data)) else
//      $error("[DATA_MEM_ASSERT] rd_data_route_offset_10: byte_offset:%b, expected:%h actual:%h",
//              2'b10, rd_data_exp, rd_data);
//
//  /******* offset 11 ******/
//  //We are shifted over three bytes
//  // - rd_data formed from: {u_byte_2(+1), u_byte_1(+1), u_byte_0(+1), u_byte_3}
//
//  rd_data_route_offset_11_assert:
//    assert property(rd_data_route_prop(2'b11, rd_data_exp, rd_data)) else
//      $error("[DATA_MEM_ASSERT] rd_data_route_offset_11: byte_offset:%b, expected:%h actual:%h",
//              2'b11, rd_data_exp, rd_data);

endmodule
