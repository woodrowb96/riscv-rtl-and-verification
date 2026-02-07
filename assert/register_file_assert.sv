module register_file_assert(
  register_file_intf.assertion intf
);
  /*********   x0 READ CHECK **************/
  property x0_rd_zero_prop(logic [4:0] rd_reg, logic [31:0] rd_data);
    @(posedge intf.clk)
    (rd_reg == '0) |-> (rd_data == '0);
  endproperty

  x0_rd_zero_rd_reg_1_assert:
    assert property(x0_rd_zero_prop(intf.rd_reg_1, intf.rd_data_1)) else
      $error("x0_rd_zero_rd_reg_2_assert: rd_data_2=0x%h", intf.rd_data_2);
  x0_rd_zero_rd_reg_2_assert:
    assert property(x0_rd_zero_prop(intf.rd_reg_2, intf.rd_data_2)) else
      $error("x0_rd_zero_rd_reg_2_assert: rd_data_2=0x%h", intf.rd_data_2);

endmodule
