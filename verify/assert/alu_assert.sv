import rv32i_defs_pkg::*;
import rv32i_control_pkg::*;

module alu_assert(
  //rtl has no clk, but we'll use the tb's clock to sync assertions
  input logic tb_clk,

  //DUT input
  input alu_op_t alu_op,
  input word_t in_a,
  input word_t in_b,

  //DUT output
  input word_t result,
  input logic zero
);
  /*=============================================================================*/
  /*--------------------------  ZERO FLAG CHECK ---------------------------------*/
  /*=============================================================================*/

  //make sure zero flag gets asserted properly
  property zero_set_prop;
    @(posedge tb_clk)
    (result == '0) |-> (zero == 1'b1);
  endproperty

  zero_set_assert:
    assert property(zero_set_prop) else
      $error("[ALU_ASSERT] zero flag not set, result:%0h, zero:%0b", result, zero);

  //make sure zero flag gets deasserted properly
  property zero_clear_prop;
    @(posedge tb_clk)
    (result != '0) |-> (zero == 1'b0);
  endproperty

  zero_clear_assert:
    assert property(zero_clear_prop) else
      $error("[ALU_ASSERT] zero flag set incorrectly, result:%0h, zero:%0b", result, zero);

  /*=============================================================================*/
  /*--------------------------  ALU OP CHECK ------------------------------------*/
  /*=============================================================================*/
  //make sure we do the correct operation for each ALU_OP

  //ALU_AND
  property alu_and_prop;
    @(posedge tb_clk)
    (alu_op == ALU_AND) |-> (result == (in_a & in_b));
  endproperty

  alu_and_assert:
    assert property(alu_and_prop) else
      $error("[ALU_ASSERT] AND result mismatch, in_a:%h, in_b:%h, result:%h", in_a, in_b, result);

  //ALU_OR
  property alu_or_prop;
    @(posedge tb_clk)
    (alu_op == ALU_OR) |-> (result == (in_a | in_b));
  endproperty

  alu_or_assert:
    assert property(alu_or_prop) else
      $error("[ALU_ASSERT] OR result mismatch, in_a:%h, in_b:%h, result:%h", in_a, in_b, result);

  //ALU_ADD
  property alu_add_prop;
    @(posedge tb_clk)
    (alu_op == ALU_ADD) |-> (result == (in_a + in_b));
  endproperty

  alu_add_assert:
    assert property(alu_add_prop) else
      $error("[ALU_ASSERT] ADD result mismatch, in_a:%h, in_b:%h, result:%h", in_a, in_b, result);

  //ALU_SUB
  property alu_sub_prop;
    @(posedge tb_clk)
    (alu_op == ALU_SUB) |-> (result == (in_a - in_b));
  endproperty

  alu_sub_assert:
    assert property(alu_sub_prop) else
      $error("[ALU_ASSERT] SUB result mismatch, in_a:%h, in_b:%h, result:%h", in_a, in_b, result);

  //INVALID OP: result should be zero
  property alu_invalid_op_prop;
    @(posedge tb_clk)
    !(alu_op inside {ALU_AND, ALU_OR, ALU_ADD, ALU_SUB}) |-> (result == '0);
  endproperty

  alu_invalid_op_assert:
    assert property(alu_invalid_op_prop) else
      $error("[ALU_ASSERT] invalid op result not zero, alu_op:%0b, in_a:%h, in_b:%h, result:%h",
              alu_op, in_a, in_b, result);

endmodule
