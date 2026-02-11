module register_file_assert(
  register_file_intf.assertion intf
);
  /*********   x0 READ CHECK **************/
  //We want to make sure we always read 0 from x0
  property x0_rd_zero_prop(logic [4:0] rd_reg, logic [31:0] rd_data);
    @(posedge intf.clk)
    (rd_reg == '0) |-> (rd_data == '0);
  endproperty

  x0_rd_zero_rd_reg_1_assert:
    assert property(x0_rd_zero_prop(intf.rd_reg_1, intf.rd_data_1)) else
      $error("x0_rd_zero_rd_reg_1_assert: rd_data_1=0x%h", intf.rd_data_1);
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
    //if wr_en and we are not writting to x0 |=>
    //then the data should be in the reg_file during the next clk cycle
    @(posedge intf.clk)
    (intf.wr_en && intf.wr_reg != '0) |=>
      (register_file.reg_file[$past(intf.wr_reg)] == $past(intf.wr_data));
  endproperty

  write_assert:
    assert property(write_prop) else
      $error("write_assert: wr_data was not written into the reg_file");

  /******* WRITE PERSISTANCE CHECK *****************/
  //We want to make sure data written in does not change, if we are not
  //writting to it
  generate
    //We want to check x1->x32
    for(genvar index = 1; index < 32; index++) begin
      write_persistance_assert:
        assert property(
          //if we are not writting to this register |=>
          //then the data should not have changed
          @(posedge intf.clk)
          !(intf.wr_en && intf.wr_reg == index) |=>
            register_file.reg_file[index] === $past(register_file.reg_file[index])
        );
    end
  endgenerate

  /*********** READ CHECK ******************/
  //We want to make sure we are reading out the actual data stored in the
  //reg_file
  always @(posedge intf.clk) begin
    #0
    if(intf.rd_reg_1 != '0) begin
      assert (intf.rd_data_1 === register_file.reg_file[intf.rd_reg_1]) else
        $error("read_rd_reg_1_assert: expected:%h, actual: %h", 
                register_file.reg_file[intf.rd_reg_1], intf.rd_data_1);
    end
    if(intf.rd_reg_2 != '0) begin
      assert (intf.rd_data_2 === register_file.reg_file[intf.rd_reg_2]) else
        $error("read_rd_reg_2_assert: expected:%h, actual: %h", 
                register_file.reg_file[intf.rd_reg_2], intf.rd_data_2);
    end

    /********* NOTE *********/
    // I wanted to do the READ Check with concurent assertions, but I was
    // having issues with race conditions.
    //
    // To fix that I tried adding in a clocking block, but I was having
    // trouble getting it to work with xeleb. Im not sure but I think it was
    // having trouble making sense of accessing a clocking block, through
    // a modport.
    //
    // For now Im just going to use these @(posedge clk) immediate assertions,
    // and investigate clocking blocks later.
    /************************/
  end

endmodule
