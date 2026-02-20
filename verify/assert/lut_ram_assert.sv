module lut_ram_assert #(
  parameter LUT_WIDTH = 32,
  parameter LUT_DEPTH = 256
)(
  input logic clk,
  input logic wr_en,
  input logic [$clog2(LUT_DEPTH)-1:0] wr_addr,
  input logic [$clog2(LUT_DEPTH)-1:0] rd_addr,
  input logic [LUT_WIDTH-1:0] wr_data,
  input logic [LUT_WIDTH-1:0] rd_data
);

/********  WRITE CHECK *************/
  //We want to make sure writes are actually written into mem on the next clk cycle
  property write_check_prop;
    @(posedge clk)
    (wr_en) |=> (lut_ram.mem[$past(wr_addr)] == $past(wr_data));
  endproperty

  write_check_assert:
    assert property(write_check_prop) else
      $error("[LUT_RAM_ASSERT] (write_check_assert): wr_data not written into wr_addr");

/********  READ CHECK *************/
  //Make sure we read the actual data stored at the rd_addr
  always @(posedge clk) begin
    #0
    assert(rd_data === lut_ram.mem[rd_addr]) else
      $error("[LUT_RAM_ASSERT] (read_check_assert): rd_data not reading correct rd_data from mem\n",
              "rd_addr: %0d, mem[rd_addr]: %0h, rd_data: %0h",
              rd_addr, lut_ram.mem[rd_addr], rd_data);
  end

endmodule
