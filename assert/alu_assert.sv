module alu_assert(
  input logic [3:0] alu_op,

  input logic [31:0] in_a,
  input logic [31:0] in_b,

  input logic [31:0] result,
  input logic zero
);
  always_comb begin
    //zero flag assertion
    if(result == '0) begin
      assert(zero == 1'b1) else begin
        $fatal("ERROR ALU: incorect zero flag\n");
      end
    end
  end
endmodule
