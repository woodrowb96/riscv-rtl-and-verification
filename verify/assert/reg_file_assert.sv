import rv32i_defs_pkg::*;

module reg_file_assert(
  input logic clk,

  //DUT input
  input logic wr_en,
  input rf_addr_t rd_reg_1,
  input rf_addr_t rd_reg_2,
  input rf_addr_t wr_reg,
  input word_t wr_data,

  //Dut output
  input word_t rd_data_1,
  input word_t rd_data_2
);
  //some assertions need a shadow reg_file that holds the previous clks reg_file state
  word_t prev_reg_file [0:RF_DEPTH-1];
  always_ff @(posedge clk) begin
    prev_reg_file <= reg_file.reg_file; //prev is one cycle begind the current reg_file
  end

  /************** WRITE ASSERTIONS ************************/

  //if(wr_en) => wr_data should now appear in the register on the NEXT CLK
  property write_next_clk_prop;
    @(posedge clk)
    (wr_en && wr_reg != X0) |=> (reg_file.reg_file[$past(wr_reg)] == $past(wr_data));
  endproperty

  write_next_clk_assert:
    assert property(write_next_clk_prop) else
      $error("[REG_FILE_ASSERT] write_next_clk: wr_data was not written into the reg_file, wr_reg:%0d, wr_data:%0h, reg_file[wr_reg]:%0h",
              wr_reg, wr_data, reg_file.reg_file[wr_reg]);

  //if(wr_en) -> wr_data should NOT be in the register during the CURRENT CLK
  // property write_current_clk_prop;
  //     @(posedge clk)
  //     (wr_en && (wr_reg != X0)) |-> (reg_file.reg_file[wr_reg] === prev_reg_file[wr_reg]);
  // endproperty
  //
  // write_current_clk_assert:
  //   assert property(write_current_clk_prop) else
  //     $error("[REG_FILE_ASSERT] write_current_clk: wr_data was written into the reg_file early, wr_reg:%0d, wr_data:%0h, reg_file[wr_reg]:%0h, prev_reg_file[wr_reg]:%0h",
  //             wr_reg, wr_data, reg_file.reg_file[wr_reg], prev_reg_file[wr_reg]);

  /******* WRITE PERSISTENCE CHECK *****************/
  //We want to make sure data written in does not change, if we are not
  //writing to it
  generate
    //We want to check x1->x31
    for(genvar index = X0 + 1; index < RF_DEPTH; index++) begin
      write_persistence_assert:
        assert property(
          //if we are not writing to this register |=>
          //then the data should not have changed
          @(posedge clk)
          !(wr_en && wr_reg == index) |=>
            reg_file.reg_file[index] === $past(reg_file.reg_file[index])
        );
    end
  endgenerate

  /*********** READ CHECK ******************/
  //We want to make sure we are reading out the actual data stored in the
  //reg_file
  always @(posedge clk) begin
    #0
    if(rd_reg_1 != X0) begin
      assert (rd_data_1 === reg_file.reg_file[rd_reg_1]) else
        $error("read_rd_reg_1_assert: expected:%0h, actual:%0h",
                reg_file.reg_file[rd_reg_1], rd_data_1);
    end
    if(rd_reg_2 != X0) begin
      assert (rd_data_2 === reg_file.reg_file[rd_reg_2]) else
        $error("read_rd_reg_2_assert: expected:%0h, actual:%0h",
                reg_file.reg_file[rd_reg_2], rd_data_2);
    end

    /********* NOTE *********/
    // I wanted to do the READ Check with concurrent assertions, but I was
    // having issues with race conditions.
    //
    // To fix that I tried adding in a clocking block, but I was having
    // trouble getting it to work with xelab. I'm not sure but I think it was
    // having trouble making sense of accessing a clocking block, through
    // a modport.
    //
    // For now I'm just going to use these @(posedge clk) immediate assertions,
    // and investigate clocking blocks later.
    /************************/
  end

  /*********************   x0 READ CHECK  *************************/

  //We want to make sure we always read 0 from x0
  property x0_rd_zero_prop(rf_addr_t rd_reg, word_t rd_data);
    @(posedge clk)
    (rd_reg == X0) |-> (rd_data == '0);
  endproperty

  x0_rd_zero_rd_reg_1_assert:
    assert property(x0_rd_zero_prop(rd_reg_1, rd_data_1)) else
      $error("x0_rd_zero_rd_reg_1_assert: rd_data_1=0x%0h", rd_data_1);
  x0_rd_zero_rd_reg_2_assert:
    assert property(x0_rd_zero_prop(rd_reg_2, rd_data_2)) else
      $error("x0_rd_zero_rd_reg_2_assert: rd_data_2=0x%0h", rd_data_2);

  /*********   x0 OVERWRITE CHECK **************/
  //x0 should always be zero, it should never be overwritten
  property x0_always_zero_prop;
    @(posedge clk)
    reg_file.reg_file[X0] == '0;
  endproperty

  x0_always_zero_assert:
    assert property(x0_always_zero_prop) else
      $error("x0_always_zero_assert: x0=%0h", reg_file.reg_file[X0]);

endmodule
