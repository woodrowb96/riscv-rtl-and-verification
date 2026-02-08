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

  /*********   x0 OVERWRITE CHECK **************/
  //x0 should always be zero, it should never be overwritten
  property x0_always_zero_prop;
    @(posedge intf.clk)
    register_file.reg_file[0] == '0;
  endproperty

  x0_always_zero_assert:
    assert property(x0_always_zero_prop) else
      $error("x0_always_zero_assert: x0=%h", register_file.reg_file[0]);

  /******* WRITE CHECK *****************/
  //We want to make sure the wr_data is actually written into the reg_file
  property write_prop;
    @(posedge intf.clk)
    //if wr_en and we are not writting to x0
    //then the data should be in the reg_file during the next clk cycle
    (intf.wr_en && intf.wr_reg != '0) |=> (register_file.reg_file[$past(intf.wr_reg)] == $past(intf.wr_data));
  endproperty

  write_assert:
    assert property(write_prop) else
      $error("write_assert: wr_data was not written into the reg_file");

  // /********  READ CHECKS  ****************/
  // //we want to make sure we are reading the actual value stored in the reg file
  // property read_prop(logic [4:0] rd_reg, logic [31:0] rd_data);
  //   @(posedge intf.clk)
  //   //reads are immediate and combinatorial, so it should we are not looking
  //   //forward to the next cycle like we do with writes
  //   1 |-> rd_data == register_file.reg_file[rd_reg];
  // endproperty
  //
  // read_rd_reg_1_assert: assert property(read_prop(intf.rd_reg_1, intf.rd_data_1)) else
  //   $error("read_rd_reg_1_assert: actual rd_data: %h, expected: %h", 
  //           intf.rd_data_1,
  //           register_file.reg_file[intf.rd_reg_1]
  //         );
  //

endmodule
