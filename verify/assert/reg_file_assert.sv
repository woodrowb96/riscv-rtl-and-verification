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
  /*=============================================================================*/
  /*--------------------------  WRITE CHECK -------------------------------------*/
  /*=============================================================================*/

  //if(wr_en) => wr_data should now appear in the register on the NEXT CLK
  property write_next_clk_prop;
    @(posedge clk)
    (wr_en && wr_reg != X0) |=> (reg_file.reg_file[$past(wr_reg)] === $past(wr_data));
  endproperty

  write_next_clk_assert:
    assert property(write_next_clk_prop) else
      $error("[REG_FILE_ASSERT] write_next_clk: wr_data was not written into the reg_file, wr_reg:%0d, wr_data:%0h, reg_file[wr_reg]:%0h",
              wr_reg, wr_data, reg_file.reg_file[wr_reg]);

  /*=============================================================================*/
  /*--------------------------  NO WRITE CHECK ----------------------------------*/
  /*=============================================================================*/

  //We want to make sure data in a register does not change, if we are not writing to it
  generate
    for(genvar index = X0 + 1; index < RF_DEPTH; index++) begin  //check x1->x31 (we'll do x0 assertions separate)
      no_write_assert:
        assert property(
          @(posedge clk)
          //If we are NOT writing to the CURRENT index |=> then on the NEXT CLK data in the reg should not have changed
          !(wr_en && wr_reg == index) |=> reg_file.reg_file[index] === $past(reg_file.reg_file[index])
        );
    end
  endgenerate

  /*=============================================================================*/
  /*--------------------------  READ CHECK --------------------------------------*/
  /*=============================================================================*/

  //We want to make sure we are reading out the actual data stored in the reg_file
  property read_prop(rf_addr_t rd_reg, word_t rd_data);
    @(posedge clk)
    (rd_reg != X0) |-> (rd_data === reg_file.reg_file[rd_reg]);
  endproperty

  read_rd_reg_1_assert:
    assert property(read_prop(rd_reg_1, rd_data_1)) else
      $error("[REG_FILE_ASSERT] read_rd_reg_1: expected:%0h, actual:%0h",
              reg_file.reg_file[rd_reg_1], rd_data_1);
  read_rd_reg_2_assert:
    assert property(read_prop(rd_reg_2, rd_data_2)) else
      $error("[REG_FILE_ASSERT] read_rd_reg_2: expected:%0h, actual:%0h",
              reg_file.reg_file[rd_reg_2], rd_data_2);


  /*=============================================================================*/
  /*------------------------- X0 READ CHECK -------------------------------------*/
  /*=============================================================================*/

  //We want to make sure we always read 0 from x0
  property x0_rd_zero_prop(rf_addr_t rd_reg, word_t rd_data);
    @(posedge clk)
    (rd_reg == X0) |-> (rd_data == '0);
  endproperty

  x0_rd_zero_rd_reg_1_assert:
    assert property(x0_rd_zero_prop(rd_reg_1, rd_data_1)) else
      $error("[REG_FILE_ASSERT] x0_rd_zero_rd_reg_1: rd_data_1=0x%0h", rd_data_1);
  x0_rd_zero_rd_reg_2_assert:
    assert property(x0_rd_zero_prop(rd_reg_2, rd_data_2)) else
      $error("[REG_FILE_ASSERT] x0_rd_zero_rd_reg_2: rd_data_2=0x%0h", rd_data_2);

  /*=============================================================================*/
  /*------------------------- X0 WRITE CHECK -------------------------------------*/
  /*=============================================================================*/

  //x0 should always be zero, it should never be overwritten
  property x0_always_zero_prop;
    @(posedge clk)
    reg_file.reg_file[X0] == '0;
  endproperty

  x0_always_zero_assert:
    assert property(x0_always_zero_prop) else
      $error("[REG_FILE_ASSERT] x0_always_zero: x0=%0h", reg_file.reg_file[X0]);

endmodule
