import rv32i_defs_pkg::*;
import rv32i_config_pkg::*;

module inst_mem_assert(
  //inst_mem doesnt have any clocked logic
  //but the assertions will use a clock from the tb to sample
  input logic clk,

  input word_t inst_addr,
  input word_t inst
);
  typedef logic [$clog2(INST_MEM_DEPTH)-1:0] rom_addr_t;

  //we want to make sure rom_addr uses the correct bits from inst_addr
  always @(posedge clk) begin
    assert(inst_mem.rom_addr == rom_addr_t'(inst_addr[XLEN-1:2])) else
      $error("[INST_MEM_ASSERT] rom_addr_check failed: inst_addr=%0h, rom_addr expected=%0h, actual=%0h",
              inst_addr, rom_addr_t'(inst_addr[XLEN-1:2]), inst_mem.rom_addr);
  end

  //we want to make sure we read the correct data from the instruction memory
  always @(posedge clk) begin
    assert(inst == inst_mem.inst_rom[rom_addr_t'(inst_addr[XLEN-1:2])]) else
      $error("[INST_MEM_ASSERT] inst_read_check failed: inst_addr=%0h, inst expected=%0h, actual=%0h",
              inst_addr, inst_mem.inst_rom[rom_addr_t'(inst_addr[XLEN-1:2])], inst);
  end
endmodule
