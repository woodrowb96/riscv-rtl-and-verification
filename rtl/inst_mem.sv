/*
    Instruction Memory module for a riscv rv32i implementation

Input:
  inst_addr: address of the instruction we are reading

Output:
  inst: the instruction we are reading from inst_addr

NOTE:
  -Out of Range access:
      For my implementation I let the instruction memory silently wrap inst_addr back to 0
      when inst_addr >= INST_MEM_DEPTH.  I leave it to other parts of the riscv implementation
      to catch and handle that scenario.

  - Misaligned access:
      This module assumes word aligned access and doesnt handle scenarios where byte_offset != 0.
      Ill leave the catching and handling of that to other parts of the riscv implementation.
*/
import riscv_32i_defs_pkg::*;
import riscv_32i_config_pkg::*;

module inst_mem #(parameter string PROGRAM = "NO_INST_MEM_PROGRAM_SPECIFIED") (
  //input
  input word_t inst_addr,

  //output
  output word_t inst
);
  /********************************************************************/
  //Make sure our instruction memory is a power of 2.
  //This ensures the addresses will wrap back to 0 with no extra logic.
  /********************************************************************/
  initial assert((INST_MEM_DEPTH & (INST_MEM_DEPTH - 1)) == 0) else
    $fatal("INST_MEM_DEPTH must be a power of 2");


  /***************  ROM **********************************************/

  typedef logic [$clog2(INST_MEM_DEPTH)-1:0] rom_addr_t;
  rom_addr_t rom_addr;

  logic [XLEN-1:0] inst_rom [0:INST_MEM_DEPTH-1];

  //initialize the rom for simulation
  //(may need to use another way for synthesis onto an fpga)
  initial begin
    $readmemh(PROGRAM, inst_rom);
    assert(inst_rom[0] !== 'x) else
      $fatal(1, "Failed to load program: %s", PROGRAM);
  end

  /*************** READ OUT INSTRUCTION *****************************/

  //truncate the addr to fit in the rom_addr port
  //and drop the bottom 2bits (the byte offset)
  assign rom_addr = rom_addr_t'(inst_addr[XLEN-1:2]);

  assign inst = inst_rom[rom_addr];

endmodule
