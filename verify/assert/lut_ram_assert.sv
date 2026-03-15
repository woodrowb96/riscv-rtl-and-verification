module lut_ram_assert #(
  parameter LUT_WIDTH = 32,
  parameter LUT_DEPTH = 256
)(
  input logic clk,
  //DUT input
  input logic wr_en,
  input logic [$clog2(LUT_DEPTH)-1:0] wr_addr,
  input logic [$clog2(LUT_DEPTH)-1:0] rd_addr,
  input logic [LUT_WIDTH-1:0] wr_data,
  //DUT output
  input logic [LUT_WIDTH-1:0] rd_data
);

  /*=============================================================================*/
  /*--------------------------  WRITE CHECK -------------------------------------*/
  /*=============================================================================*/

  //if(wr_en) => wr_data should now appear at the mem address on the NEXT CLK
  property write_check_prop;
    @(posedge clk)
    (wr_en) |=> (lut_ram.mem[$past(wr_addr)] == $past(wr_data));
  endproperty

  write_check_assert:
    assert property(write_check_prop) else
      $error("[LUT_RAM_ASSERT] (write_check_assert): wr_data not written into wr_addr");


  /*=============================================================================*/
  /*--------------------------  READ CHECK --------------------------------------*/
  /*=============================================================================*/

  //We want to make sure we are reading out the actual data stored in memory
  property read_prop;
    @(posedge clk)
    (rd_data === lut_ram.mem[rd_addr]);
  endproperty

  read_assert:
    assert property(read_prop) else
      $error("[LUT_RAM_ASSERT] (read_assert) rd_data expected:%0h, actual:%0h",
              lut_ram.mem[rd_addr], rd_data);

endmodule
