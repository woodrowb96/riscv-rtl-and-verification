import riscv_32i_defs_pkg::*;
import riscv_32i_control_pkg::*;

module data_mem_assert(
  input logic clk,
  input byte_sel_t wr_sel,
  input word_t addr,
  input word_t wr_data,
  input word_t rd_data
);
  typedef logic [$clog2(DATA_MEM_DEPTH)-1:0] lut_addr_t;

  /*************** BIND LUT_RAM ASSERTIONS ****************/

  //lut ram assertions will provide the assertions actaully touching memory
  bind data_mem.u_byte_0 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);
  bind data_mem.u_byte_1 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);
  bind data_mem.u_byte_2 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);
  bind data_mem.u_byte_3 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);

  /*************** ADDR CALC CHECK ****************/

  //we need to make sure we calculate the correct lut_ram addresses based off the byte offset
  always @(posedge clk) begin
    #0
    unique case(addr[1:0])
      2'b00: begin
        //Note: we caste the addr[XLEN-1:2] to be the same size as lut_addr_t
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
    endcase
  end

  /*************** WR_SEL ROUTE CHECK ****************/
  byte_sel_t lut_ram_wr_en_exp;

  //we need to make sure the wr_sel signals get routed to the correct u_byte bases on byte offset
  always @(posedge clk) begin
    #0
    unique case(addr[1:0])
      2'b00: begin
        lut_ram_wr_en_exp = {wr_sel[3], wr_sel[2], wr_sel[1], wr_sel[0]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] wr_sel route failed: offset=00 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end
      2'b01:begin
        lut_ram_wr_en_exp = {wr_sel[2], wr_sel[1], wr_sel[0], wr_sel[3]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] wr_sel route failed: offset=01 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end
      2'b10:begin
        lut_ram_wr_en_exp = {wr_sel[1], wr_sel[0], wr_sel[3], wr_sel[2]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] wr_sel route failed: offset=10 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end
      2'b11:begin
        lut_ram_wr_en_exp = {wr_sel[0], wr_sel[3], wr_sel[2], wr_sel[1]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] wr_sel route failed: offset=11 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end
    endcase
  end

/*************** WRITE DATA ROUTE CHECK *****************/

  word_t wr_data_actual;

  //make sure we are routing the right wr_data based on byte offset
  always @(posedge clk) begin
    #0
    unique case(addr[1:0])
      2'b00: begin
        wr_data_actual = { {data_mem.u_byte_3.wr_data,
                            data_mem.u_byte_2.wr_data,
                            data_mem.u_byte_1.wr_data,
                            data_mem.u_byte_0.wr_data} };

        assert(wr_data === wr_data_actual) else
          $error("[DATA_MEM_ASSERT] wr_data route failed: offset=00 addr=%0h, expected=%0h, actual=%0h",
                  addr, wr_data, wr_data_actual);
      end
      2'b01:begin
        wr_data_actual = { {data_mem.u_byte_0.wr_data,
                            data_mem.u_byte_3.wr_data,
                            data_mem.u_byte_2.wr_data,
                            data_mem.u_byte_1.wr_data} };

        assert(wr_data === wr_data_actual) else
          $error("[DATA_MEM_ASSERT] wr_data route failed: offset=01 addr=%0h, expected=%0h, actual=%0h",
                  addr, wr_data, wr_data_actual);
      end
      2'b10:begin
        wr_data_actual = { {data_mem.u_byte_1.wr_data,
                            data_mem.u_byte_0.wr_data,
                            data_mem.u_byte_3.wr_data,
                            data_mem.u_byte_2.wr_data} };

        assert(wr_data === wr_data_actual) else
          $error("[DATA_MEM_ASSERT] wr_data route failed: offset=10 addr=%0h, expected=%0h, actual=%0h",
                  addr, wr_data, wr_data_actual);
      end
      2'b11:begin
        wr_data_actual = { {data_mem.u_byte_2.wr_data,
                            data_mem.u_byte_1.wr_data,
                            data_mem.u_byte_0.wr_data,
                            data_mem.u_byte_3.wr_data} };

        assert(wr_data === wr_data_actual) else
          $error("[DATA_MEM_ASSERT] wr_data route failed: offset=11 addr=%0h, expected=%0h, actual=%0h",
                  addr, wr_data, wr_data_actual);
      end
    endcase

  end

/*************** READ DATA ROUTE CHECK *****************/
  word_t rd_data_exp;

  //make sure we are constructing the right rd_data based on byte offset
  always @(posedge clk) begin
    #0
    //look at the byte offset
    //constuct the word directly from the byte lane memories
    //compare it to the actaul rd_data
    unique case(addr[1:0])
      2'b00: begin
        rd_data_exp = {data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(rd_data === rd_data_exp) else
          $error("[DATA_MEM_ASSERT] rd_data route failed: offset=00 addr=%0h, expected=%0h, actual=%0h",
                  addr, rd_data_exp, rd_data);
      end
      2'b01:begin
        rd_data_exp = {data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(rd_data === rd_data_exp) else
          $error("[DATA_MEM_ASSERT] rd_data route failed: offset=01 addr=%0h, expected=%0h, actual=%0h",
                  addr, rd_data_exp, rd_data);
      end
      2'b10:begin
        rd_data_exp = {data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(rd_data === rd_data_exp) else
          $error("[DATA_MEM_ASSERT] rd_data route failed: offset=10 addr=%0h, expected=%0h, actual=%0h",
                  addr, rd_data_exp, rd_data);
      end
      2'b11:begin
        rd_data_exp = {data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(rd_data === rd_data_exp) else
          $error("[DATA_MEM_ASSERT] rd_data route failed: offset=11 addr=%0h, expected=%0h, actual=%0h",
                  addr, rd_data_exp, rd_data);
      end
    endcase
  end
endmodule
