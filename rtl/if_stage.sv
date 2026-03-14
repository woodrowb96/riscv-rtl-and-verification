/*
      The Instruction Fetch Stage for a riscv rv32i implementation.
      (currently a single cycle implementation)

CLK:
  - syncronous operations are synced to the posedge of the clk

RESET:
  - reset_n: synchrounous reset signal
      - resets the following signals:
          - PC <= 0
CONTROL
  - branch: 1 bit branch select
      - determines whether we continue incrementing PC or take the jump to the branch_target
      - The next PC is set according to the following:
          - 1 : pc <= branch_target
          - 0 : pc <= pc + 4
INPUT
  - branch_target: 32bit address of the branch target
      - calculated in the EX stage

OUTPUT
  - PC: 32bit address currently in the Program Counter
      - The current address in the inst_mem we are reading out of
      - PC is sent to the EX stage to aid in branch_target calculation
  - inst: 32bit instruction
      - The instruction that PC is currently pointing to in instruction memory
      - sent to the ID stage and Control Unit to be decoded
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
