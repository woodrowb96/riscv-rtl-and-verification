import riscv_32i_defs_pkg::*;
import riscv_32i_control_pkg::*;

module alu_assert(
  input alu_op_t alu_op,
  input word_t in_a,
  input word_t in_b,
  input word_t result,
  input logic zero
);
  always_comb begin
    //zero flag assertion
    if(result == '0) begin
      assert(zero == 1'b1) else
        $error("ERROR ALU: Zero flag not set, result=%0h, zero_flag=%0b",
              result, zero);
    end else if(result != '0) begin
      assert(zero == 1'b0) else
        $error("ERROR ALU: Zero flag set incorrectly, result=%0h, zero_flag=%0b",
              result, zero);
    end
  end

    /************* NOTE *************/
    //I want to have immediate assertions that run and look at the alu_op then check the
    //result against the inputs
    //
    //The problem I had was that these assertions were always failing.
    //I think the issue was alu_op was changing and the always_comb block
    //would get triggered, then it would check the assertion.  But this
    //happened immediatly and did not give the inputs enough time to propogate
    //to the outputs so the assertions were failing.
    //
    //I wanted to add these defered immediate assertions, but they are not
    //supported on the version of Vivado im using (the free one). I havent
    //been able to test if the following works, but I think it probably does.
    //
    //The defered immediate assertions seems like the best solution.
    //
    //I dont want to add a clock and use concurent assertions, because the rtl
    //that this is binded into (alu.sv) is purely combinatorial and I dont
    //want its assertions to have to be given a clock to work.
    /*******************************/
    //always_comb begin
    // case(alu_op)
    //   4'b0000: begin
    //     assert #0 (result == (in_a & in_b)) else
    //       $error("ERROR ALU: AND op result mismatch, in_a = %h, in_b = %h, result = %h",
    //               in_a, in_b, result);
    //   end
    //   4'b0001: begin
    //     assert #0 (result == (in_a | in_b)) else
    //       $error("ERROR ALU: OR op result mismatch, in_a = %h, in_b = %h, result = %h",
    //               in_a, in_b, result);
    //   end
    //   4'b0010: begin
    //     assert #0 (result == (in_a + in_b)) else
    //       $error("ERROR ALU: ADD op result mismatch, in_a = %h, in_b = %h, result = %h",
    //               in_a, in_b, result);
    //   end
    //   4'b0110: begin
    //     assert #0 (result == (in_a - in_b)) else
    //       $error("ERROR ALU: SUB op result mismatch, in_a = %h, in_b = %h, result = %h",
    //               in_a, in_b, result);
    //   end
    //   default: begin
    //     assert #0 (result == '0) else
    //       $error("ERROR ALU: INVALID op result is not zero,",
    //               "ALU_OP: %b, result: %h, in_a: %h, in_b %h",
    //               alu_op, result, in_a, in_b);
    //   end
    // endcase
  // end
endmodule
