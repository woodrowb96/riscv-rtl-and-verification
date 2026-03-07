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
  /************** ZERO FLAG ASSERTIONS *************************/

  //make sure zero flag gets asserted properly
  always @(posedge tb_clk) begin
    if(result == '0) begin
      assert(zero == 1'b1) else
        $error("[ALU_ASSERT] zero flag not set, result:%0h, zero:%0b", result, zero);
    end
  end

  //make sure zero flag gets deasserted properly
  always @(posedge tb_clk) begin
    if(result != '0) begin
      assert(zero == 1'b0) else
        $error("[ALU_ASSERT] zero flag set incorrectly, result:%0h, zero:%0b", result, zero);
    end
  end

  /************** ALU OP ASSERTIONS *************************/
  //make sure we do the correct operation for each ALU_OP

  //ALU_AND
  always @(posedge tb_clk) begin
    if(alu_op == ALU_AND) begin
      assert(result == (in_a & in_b)) else
        $error("[ALU_ASSERT] AND result mismatch, in_a:%h, in_b:%h, result:%h", in_a, in_b, result);
    end
  end

  //ALU_OR
  always @(posedge tb_clk) begin
    if(alu_op == ALU_OR) begin
      assert(result == (in_a | in_b)) else
        $error("[ALU_ASSERT] OR result mismatch, in_a:%h, in_b:%h, result:%h", in_a, in_b, result);
    end
  end

  //ALU_ADD
  always @(posedge tb_clk) begin
    if(alu_op == ALU_ADD) begin
      assert(result == (in_a + in_b)) else
        $error("[ALU_ASSERT] ADD result mismatch, in_a:%h, in_b:%h, result:%h", in_a, in_b, result);
    end
  end

  //ALU_SUB
  always @(posedge tb_clk) begin
    if(alu_op == ALU_SUB) begin
      assert(result == (in_a - in_b)) else
        $error("[ALU_ASSERT] SUB result mismatch, in_a:%h, in_b:%h, result:%h", in_a, in_b, result);
    end
  end

  //INVALID OP: result should be zero
  always @(posedge tb_clk) begin
    if(!(alu_op inside {ALU_AND, ALU_OR, ALU_ADD, ALU_SUB})) begin
      assert(result == '0) else
        $error("[ALU_ASSERT] invalid op result not zero, alu_op:%0b, in_a:%h, in_b:%h, result:%h",
                alu_op, in_a, in_b, result);
    end
  end
endmodule
