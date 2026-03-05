/*
  The Immediate Generation Module for a riscv rv32i implementation.

Input:
  inst: 32bit rv32i instruction

Output:
  imm: 32bit immediate value constructed according to the instructions format
       - R-type:
                - no encoded immediate
                - imm = '0 (just output all zeros)
      - I-type:
                - encoded immediate stored in bits inst[31:20]
                - imm = {{20{inst[31]}}, inst[31:20]}
      - S-type:
                - encoded immediate split across bits inst[31:25] and inst[11:7]
                - imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}
      - B-type:
                - encoded immediate split across instruction
                - imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}
      - U-type:
                - encoded immediate stored in bits inst[31:12]
                - imm = {inst[31:12], {12{1'b0}}}
      - J-type:
                - encoded immediate split across instruction
                - imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}
*/
import rv32i_defs_pkg::*;

module imm_gen(
  //input
  input word_t inst,

  //output
  output word_t imm
);
  opcode_t opcode;
  assign opcode = opcode_t'(inst[6:0]);

  always_comb begin
    unique case(opcode)
      //R-type
      OP_REG: begin
        imm = '0;
      end
      //I-type
      OP_IMM, OP_LOAD, OP_JALR: begin
        imm = {{20{inst[31]}}, inst[31:20]};
      end
      //S-type
      OP_STORE: begin
        imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
      end
      //B-type
      OP_BRANCH: begin
        imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
      end
      //U-type
      OP_LUI, OP_AUIPC: begin
        imm = {inst[31:12], {12{1'b0}}};
      end
      //J-type
      OP_JAL: begin
        imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
      end
    endcase
  end
endmodule
