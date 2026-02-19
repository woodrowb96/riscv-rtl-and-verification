package alu_ref_model_pkg;
  import riscv_32i_defs_pkg::*;
  import riscv_32i_control_pkg::*;
  import tb_alu_transaction_pkg::*;

  //so we can return both expected values at the same time
  typedef struct {
    word_t result;
    logic zero;
  } ref_alu_output;

  class alu_ref_model;

    function ref_alu_output predict(alu_trans trans);
      logic [XLEN:0] in_a_wide = {1'b0, trans.in_a};
      logic [XLEN:0] in_b_wide = {1'b0, trans.in_b};
      logic [XLEN:0] result_wide = '0;

      logic zero = 1'b0;

      ref_alu_output prediction;

      if(trans.alu_op == ALU_SUB) begin
        result_wide = in_a_wide - in_b_wide;
      end
      else if(trans.alu_op == ALU_ADD) begin
        result_wide = in_a_wide + in_b_wide;
      end
      else if(trans.alu_op == ALU_OR) begin
        result_wide = in_a_wide | in_b_wide;
      end
      else if(trans.alu_op == ALU_AND) begin
        result_wide = in_a_wide & in_b_wide;
      end

      if(result_wide[XLEN-1:0] == '0) begin
        zero = 1'b1;
      end

      prediction.result = result_wide[XLEN-1:0];
      prediction.zero = zero;

      return prediction;
    endfunction
  endclass
endpackage
