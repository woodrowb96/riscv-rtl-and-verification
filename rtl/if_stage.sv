/*
      The Instruction Fetch Stage for a riscv rv32i implementation.
      (currently a single cycle implementation)

CLK:
  - synchronous operations are synced to the posedge of the clk

RESET:
  - reset_n: synchronous reset signal
      - resets the following signals:
          - PC <= 0
CONTROL
  - branch: 1 bit branch select
      - determines whether we continue incrementing PC or take the jump to the branch_target
      - The next PC is set according to the following:
          - 1 : pc <= branch_target
          - 0 : pc <= pc + 4
INPUT
  - branch_target: 32bit unsigned address of the branch target
      - branch_targets are word aligned in this implementation
      - NOTE: The branch target has already been calculated in the EX stage.
              This module doesnt need to do any extra-processing on it.

OUTPUT
  - PC: 32bit unsigned address currently in the Program Counter
      - The current address in the inst_mem we are reading out of
      - PC is sent to the EX stage to aid in branch_target calculation
  - inst: 32bit instruction
      - The instruction that PC is currently pointing to in instruction memory
      - sent to the ID stage and Control Unit to be decoded


NOTE: EXCEPTION HANDLING (deferred)
  - I am waiting to implement exceptions until after I get the pipelined core up and
    running without them. I will then go back and add the proper exception handling
    functionality to the core.

  - For now the following behavior happens silently for each exception:

    INSTRUCTION ADDRESS MISALIGNED:
      Non-word-aligned branch_target addresses (branch_target[1:0] != 2'b00) are
      silently rounded down to the next lowest word aligned address (this happens
      inside u_inst_mem). Each proceeding PC after a misaligned branch will also be
      misaligned, but this is not a problem since those too will get rounded down.

    INSTRUCTION ACCESS FAULT:
      Currently the only access fault defined in this implementation is trying to
      access an out-of-bounds instruction address (inst_addr >= INST_MEM_DEPTH).
      Out-of-bounds addresses silently wrap around to the start of memory
      (inst_addr == INST_MEM_DEPTH + 50 becomes inst_addr == 50).
*/
import rv32i_defs_pkg::*;
import rv32i_config_pkg::*;

module if_stage #(parameter string PROGRAM = NO_PROGRAM) (
  //clk and reset
  input logic clk,
  input logic reset_n,

  //control
  input logic branch,

  //input
  input word_t branch_target,

  //output
  output word_t pc,
  output word_t inst
);
  word_t pc_next;

  /************ CALC NEXT PC *******************/
  always_comb begin
    if(branch) begin
      pc_next = branch_target;
    end
    else begin
      pc_next = pc + word_t'(4);
    end
  end

  /************ PROGRAM COUNTER ***************/
  always_ff @(posedge clk) begin
    if(~reset_n) begin
      pc <= PC_RESET;
    end
    else begin
      pc <= pc_next;
    end
  end

  /***********  INSTRUCTION ACCESS ****************/
  inst_mem #(.PROGRAM(PROGRAM)) u_inst_mem (
    .inst_addr(pc),
    .inst(inst)
  );

endmodule
