import rv32i_defs_pkg::*;
import rv32i_config_pkg::*;

module inst_mem_assert(
  input logic tb_clk, //inst mem doesnt have a clock, but we will sync assertions to the tb clock

  input word_t inst_addr,
  input word_t inst
);
  /*=============================================================================*/
  /*------------------------ ROM ADDRESS ASSERTION  -----------------------------*/
  /*=============================================================================*/

  //make sure the word length inst_addr is getting routed to the rom_addr port correctly
  //  - byte_offset (lower 2 bits) dropped
  //  - truncated to fit inside the rom_addr_t length
  property rom_addr_prop;
    @(posedge tb_clk)
    inst_mem.rom_addr === inst_addr[$clog2(INST_MEM_DEPTH)+1:2];
  endproperty

  rom_addr_assert: assert property(rom_addr_prop) else
    $error("[INST_MEM_ASSERT] rom_addr_assert: inst_addr=%0h, rom_addr expected=%0h, actual=%0h",
            inst_addr, inst_addr[$clog2(INST_MEM_DEPTH)+1:2], inst_mem.rom_addr);

  /*=============================================================================*/
  /*----------------------------- READ ASSERTION  -------------------------------*/
  /*=============================================================================*/

  //make sure we are reading out the instruction that is actually stored in
  //the instruction memory at the address we need it from
  property inst_read_prop;
    @(posedge tb_clk)
    inst === inst_mem.inst_rom[inst_addr[$clog2(INST_MEM_DEPTH)+1:2]];
  endproperty

  inst_read_assert: assert property(inst_read_prop) else
    $error("[INST_MEM_ASSERT] inst_read_assert: inst_addr=%0h, inst expected=%0h, actual=%0h",
            inst_addr, inst_mem.inst_rom[inst_addr[$clog2(INST_MEM_DEPTH)+1:2]], inst);

endmodule
