module data_mem_assert(
  data_mem_intf.monitor intf
);
/*************** WRITE CHECK ****************/

// property wr_check_byte_lane_0_prop;
//   @(posedge intf.clk)
//   (data_mem.byte_0.wr_en) |=>
//     (data_mem.byte_0.mem[$past(data_mem.byte_0.wr_addr)]
// endproperty

/*************** READ CHECK *****************/
  //make sure we are reading the word actually stored in memory
  word_t lut_word;
  always @(posedge intf.clk) begin
    #0
    //look at the byte offset
    //constuct the word directly from the byte lane memories
    //compare it to the actaul rd_data
    unique case(intf.addr[1:0])
      2'b00: begin
        lut_word = {data_mem.byte_3.mem[intf.addr[XLEN-1:2]],
                    data_mem.byte_2.mem[intf.addr[XLEN-1:2]],
                    data_mem.byte_1.mem[intf.addr[XLEN-1:2]],
                    data_mem.byte_0.mem[intf.addr[XLEN-1:2]]};

        assert(intf.rd_data === lut_word) else
          $error("[DATA_MEM_ASSERT] read failed at offset 00: addr=%0h, expected=%0h, actual=%0h",
                  intf.addr, lut_word, intf.rd_data);
      end
      2'b01:begin
        lut_word = {data_mem.byte_0.mem[intf.addr[XLEN-1:2] + 'd1],
                    data_mem.byte_3.mem[intf.addr[XLEN-1:2]],
                    data_mem.byte_2.mem[intf.addr[XLEN-1:2]],
                    data_mem.byte_1.mem[intf.addr[XLEN-1:2]]};

        assert(intf.rd_data === lut_word) else
          $error("[DATA_MEM_ASSERT] read failed at offset 01: addr=%0h, expected=%0h, actual=%0h",
                  intf.addr, lut_word, intf.rd_data);
      end
      2'b10:begin
        lut_word = {data_mem.byte_1.mem[intf.addr[XLEN-1:2] + 'd1],
                    data_mem.byte_0.mem[intf.addr[XLEN-1:2] + 'd1],
                    data_mem.byte_3.mem[intf.addr[XLEN-1:2]],
                    data_mem.byte_2.mem[intf.addr[XLEN-1:2]]};

        assert(intf.rd_data === lut_word) else
          $error("[DATA_MEM_ASSERT] read failed at offset 10: addr=%0h, expected=%0h, actual=%0h",
                  intf.addr, lut_word, intf.rd_data);
      end
      2'b11:begin
        lut_word = {data_mem.byte_2.mem[intf.addr[XLEN-1:2] + 'd1],
                    data_mem.byte_1.mem[intf.addr[XLEN-1:2] + 'd1],
                    data_mem.byte_0.mem[intf.addr[XLEN-1:2] + 'd1],
                    data_mem.byte_3.mem[intf.addr[XLEN-1:2]]};

        assert(intf.rd_data === lut_word) else
          $error("[DATA_MEM_ASSERT] read failed at offset 11: addr=%0h, expected=%0h, actual=%0h",
                  intf.addr, lut_word, intf.rd_data);
      end
  endcase
endmodule
