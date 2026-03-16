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
      This module assumes word aligned access and silently rounds non-zero byte offsets
      down to the next lower word. It doesnt throw a flag or error I'll leave the catching
      and handling of misaligned access to other parts of the riscv implementation.
*/
import rv32i_defs_pkg::*;
import rv32i_config_pkg::*;

module inst_mem #(parameter string PROGRAM = "") (
  //input
  input word_t inst_addr,

  //output
  output word_t inst
);
  typedef logic [$clog2(INST_MEM_DEPTH)-1:0] rom_addr_t;

  rom_addr_t rom_addr; //address sized to match the rom


  /*************** ENFORCE POWER OF 2 DEPTH *************************/
  //Depth needs to be a power of 2, so addresses wrap properly
  /******************************************************************/

  generate
  //We want this to fail for both synthesis and simulation so Im using
  //the generate block to kill it during compilation.
    if(((INST_MEM_DEPTH & (INST_MEM_DEPTH - 1)) != 0)) begin
      $error("INST_MEM_DEPTH must be power of 2");
    end
  endgenerate


  /************************** ROM ***********************************/

  logic [XLEN-1:0] inst_rom [0:INST_MEM_DEPTH-1];

  //Initialize the rom for simulation (may need a diff method for synthesis onto an FPGA)
  initial begin
    $readmemh(PROGRAM, inst_rom);

    //This assertion only fires during simulation.
    //Thats fine users might have a different way to program the mem for synthesis
    assert(inst_rom[0] !== 'x) else
      $fatal(1, "Failed to load program: %s", PROGRAM);
  end


  /********************* MEMORY ACCESS *****************************/

  //drop the bottom byte offset, then truncate the inst_addr to fit in the rom_addr port
  assign rom_addr = rom_addr_t'(inst_addr >> 2);

  //read out the instruction
  assign inst = inst_rom[rom_addr];

endmodule
