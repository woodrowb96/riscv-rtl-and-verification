import riscv_32i_defs_pkg::*;
import riscv_32i_control_pkg::*;

module data_mem_assert(
  input logic clk,
  input byte_sel_t wr_sel,
  input word_t addr,
  input word_t wr_data,
  input word_t rd_data
);
/*************** WRITE CHECK ****************/

// property wr_check_byte_lane_0_prop;
//   @(posedge clk)
//   (data_mem.byte_0.wr_en) |=>
//     (data_mem.byte_0.mem[$past(data_mem.byte_0.wr_addr)]
// endproperty

/*************** READ CHECK *****************/
  //make sure we are reading the word actually stored in memory
  word_t lut_word;
  always @(posedge clk) begin
    #0
    //look at the byte offset
    //constuct the word directly from the byte lane memories
    //compare it to the actaul rd_data
    unique case(addr[1:0])
      2'b00: begin
        lut_word = {data_mem.byte_3.mem[addr[XLEN-1:2]],
                    data_mem.byte_2.mem[addr[XLEN-1:2]],
                    data_mem.byte_1.mem[addr[XLEN-1:2]],
                    data_mem.byte_0.mem[addr[XLEN-1:2]]};

        assert(rd_data === lut_word) else
          $error("[DATA_MEM_ASSERT] read failed at offset 00: addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_word, rd_data);
      end
      2'b01:begin
        lut_word = {data_mem.byte_0.mem[addr[XLEN-1:2] + 'd1],
                    data_mem.byte_3.mem[addr[XLEN-1:2]],
                    data_mem.byte_2.mem[addr[XLEN-1:2]],
                    data_mem.byte_1.mem[addr[XLEN-1:2]]};

        assert(rd_data === lut_word) else
          $error("[DATA_MEM_ASSERT] read failed at offset 01: addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_word, rd_data);
      end
      2'b10:begin
        lut_word = {data_mem.byte_1.mem[addr[XLEN-1:2] + 'd1],
                    data_mem.byte_0.mem[addr[XLEN-1:2] + 'd1],
                    data_mem.byte_3.mem[addr[XLEN-1:2]],
                    data_mem.byte_2.mem[addr[XLEN-1:2]]};

        assert(rd_data === lut_word) else
          $error("[DATA_MEM_ASSERT] read failed at offset 10: addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_word, rd_data);
      end
      2'b11:begin
        lut_word = {data_mem.byte_2.mem[addr[XLEN-1:2] + 'd1],
                    data_mem.byte_1.mem[addr[XLEN-1:2] + 'd1],
                    data_mem.byte_0.mem[addr[XLEN-1:2] + 'd1],
                    data_mem.byte_3.mem[addr[XLEN-1:2]]};

        assert(rd_data === lut_word) else
          $error("[DATA_MEM_ASSERT] read failed at offset 11: addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_word, rd_data);
      end
    endcase
  end
endmodule
