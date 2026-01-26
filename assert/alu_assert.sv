module alu_assert(
  alu_intf.assertion intf
);
  always_comb begin
    //zero flag assertion
    if(intf.result == '0) begin
      assert(intf.zero == 1'b1) else begin
        $fatal("ERROR ALU: incorect zero flag\n");
      end
    end
  end
endmodule
