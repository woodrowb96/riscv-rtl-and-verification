import rv32i_defs_pkg::*;

module imm_gen_assert(
  //rtl has no clk, but we'll use the tb's clock to sync assertions
  input logic tb_clk,

  //DUT input
  input word_t inst,
  //DUT output
  input word_t imm
);
  /************** OPCODE ASSERT ********************/
  //make sure we are selecting the right bits in the inst to get the opcode

  always @(posedge tb_clk) begin
    assert(imm_gen.opcode == opcode_t'(inst[6:0])) else
      $error("[IMM_GEN_ASSERT] opcode_check failed: opcode expected:%0b, actual:%0b",
              opcode_t'(inst[6:0]), imm_gen.opcode);
  end

  /*********** IMMEDIATE GENERATION ASSERTS ********************/
  //make sure we construct the correct immediate from the instruction

  //R-type: no immediate, output should be zero
  always @(posedge tb_clk) begin
    if(inst[6:0] == OP_REG) begin
      assert(imm == '0) else
        $error("[IMM_GEN_ASSERT] r_type_check: imm expected:%h, got:%h", '0, imm);
    end
  end

  //I-type
  always @(posedge tb_clk) begin
    if(inst[6:0] inside {OP_IMM, OP_LOAD, OP_JALR}) begin
      assert(imm == {{20{inst[31]}}, inst[31:20]}) else
        $error("[IMM_GEN_ASSERT] i_type_check: imm expected:%h, got:%h",
                {{20{inst[31]}}, inst[31:20]}, imm);
    end
  end

  //S-type
  always @(posedge tb_clk) begin
    if(inst[6:0] == OP_STORE) begin
      assert(imm == {{20{inst[31]}}, inst[31:25], inst[11:7]}) else
        $error("[IMM_GEN_ASSERT] s_type_check: imm expected:%h, got:%h",
                {{20{inst[31]}}, inst[31:25], inst[11:7]}, imm);
    end
  end

  //B-type
  always @(posedge tb_clk) begin
    if(inst[6:0] == OP_BRANCH) begin
      assert(imm == {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}) else
        $error("[IMM_GEN_ASSERT] b_type_check: imm expected:%h, got:%h",
                {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}, imm);
    end
  end

  //U-type
  always @(posedge tb_clk) begin
    if(inst[6:0] inside {OP_LUI, OP_AUIPC}) begin
      assert(imm == {inst[31:12], {12{1'b0}}}) else
        $error("[IMM_GEN_ASSERT] u_type_check: imm expected:%h, got:%h",
                {inst[31:12], {12{1'b0}}}, imm);
    end
  end

  //J-type
  always @(posedge tb_clk) begin
    if(inst[6:0] == OP_JAL) begin
      assert(imm == {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}) else
        $error("[IMM_GEN_ASSERT] j_type_check: imm expected:%h, got:%h",
                {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}, imm);
    end
  end
endmodule
