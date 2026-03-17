import rv32i_defs_pkg::*;

module imm_gen_assert(
  //rtl has no clk, but we'll use the tb's clock to sync assertions
  input logic tb_clk,

  //DUT input
  input word_t inst,
  //DUT output
  input word_t imm
);
  /*=============================================================================*/
  /*--------------------------- OPCODE ASSERTION  -------------------------------*/
  /*=============================================================================*/

  //make sure we are selecting the right bits in the inst to get the opcode
  property opcode_prop;
    @(posedge tb_clk)
    imm_gen.opcode === opcode_t'(inst[6:0]);
  endproperty

  opcode_assert: assert property(opcode_prop) else
    $error("[IMM_GEN_ASSERT] opcode_asset: opcode expected:%0b, actual:%0b",
            opcode_t'(inst[6:0]), imm_gen.opcode);


  /*=============================================================================*/
  /*------------------ IMMEDIATE GENERATION ASSERTIONS --------------------------*/
  /*=============================================================================*/
  //make sure we construct the correct immediate from the instruction

  //R-type: no immediate, output should be zero
  property r_type_imm_prop;
    @(posedge tb_clk)
    (inst[6:0] == OP_REG) |-> (imm === '0);
  endproperty

  r_type_imm_assert: assert property(r_type_imm_prop) else
    $error("[IMM_GEN_ASSERT] r_type_imm_assert: imm expected:%h, got:%h", '0, imm);

  //I-type
  property i_type_imm_prop;
    @(posedge tb_clk)
    (inst[6:0] inside {OP_IMM, OP_LOAD, OP_JALR}) |->
      (imm === {{20{inst[31]}}, inst[31:20]});
  endproperty

  i_type_imm_assert: assert property(i_type_imm_prop) else
    $error("[IMM_GEN_ASSERT] i_type_imm_assert: imm expected:%h, got:%h",
            {{20{inst[31]}}, inst[31:20]}, imm);

  //S-type
  property s_type_imm_prop;
    @(posedge tb_clk)
    (inst[6:0] == OP_STORE) |->
      (imm === {{20{inst[31]}}, inst[31:25], inst[11:7]});
  endproperty

  s_type_imm_assert: assert property(s_type_imm_prop) else
    $error("[IMM_GEN_ASSERT] s_type_imm_assert: imm expected:%h, got:%h",
            {{20{inst[31]}}, inst[31:25], inst[11:7]}, imm);

  //B-type
  property b_type_imm_prop;
    @(posedge tb_clk)
    (inst[6:0] == OP_BRANCH) |->
      (imm === {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0});
  endproperty

  b_type_imm_assert: assert property(b_type_imm_prop) else
    $error("[IMM_GEN_ASSERT] b_type_imm_assert: imm expected:%h, got:%h",
            {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}, imm);

  //U-type
  property u_type_imm_prop;
    @(posedge tb_clk)
    (inst[6:0] inside {OP_LUI, OP_AUIPC}) |->
      (imm === {inst[31:12], {12{1'b0}}});
  endproperty

  u_type_imm_assert: assert property(u_type_imm_prop) else
    $error("[IMM_GEN_ASSERT] u_type_imm_assert: imm expected:%h, got:%h",
            {inst[31:12], {12{1'b0}}}, imm);

  //J-type
  property j_type_imm_prop;
    @(posedge tb_clk)
    (inst[6:0] == OP_JAL) |->
      (imm === {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0});
  endproperty

  j_type_imm_assert: assert property(j_type_imm_prop) else
    $error("[IMM_GEN_ASSERT] j_type_imm_assert: imm expected:%h, got:%h",
            {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}, imm);

endmodule
