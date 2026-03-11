/*
  Coverage for this module is collected manually through the sample() function.

  COVERAGE SAMPLING ASSUMPTIONS:
        - sample() is being called AFTER the DUT signals have been driven onto the DUT's input ports
          and AFTER the combinatorial rd_addr has had time to propagate to rd_data
          but BEFORE the new wr_data has been clocked into memory.
*/
package tb_lut_ram_coverage_pkg;
  import tb_lut_ram_transaction_pkg::*;

  class tb_lut_ram_coverage #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256);
    localparam int unsigned MIN_ADDR = 0;
    localparam int unsigned MAX_ADDR = LUT_DEPTH - 1;

    lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) trans;

    //we keep track of some values to collect coverage with
    logic prev_wr_en;
    logic [$clog2(LUT_DEPTH)-1:0] prev_wr_addr;

    covergroup cg;

      /************************ WRITTING *********************/
      wr_en: coverpoint trans.wr_en{
        bins write = {1'b1};
        bins no_write = {1'b0};
      }

      //split the coverage into three catagories:
      // the corner two corners, and then the rest of the range
      wr_addr: coverpoint trans.wr_addr {
        bins addr_min =   {MIN_ADDR};
        bins addr_max =   {MAX_ADDR};
        bins non_corner = {[MIN_ADDR + 1 : MAX_ADDR - 1]};
      }

      //we want to write and not write to our corner addresses
      wr_addr_x_wr_en: cross wr_addr, wr_en;

      //ALL_ONES and ALL_ZERO and then the rest of the range are our interesting data corners
      wr_data: coverpoint trans.wr_data
        iff(trans.wr_en) {
          bins zeros      = {'0};
          bins all_ones   = {'1};
          bins non_corner = {['0 + 1 : '1 - 1]};
        }

      //we want to cover writting back to back, to at least one address
      //in consecutive clk cycles
      back_to_back_writes: coverpoint ((trans.wr_addr == prev_wr_addr) && (trans.wr_en && prev_wr_en)) {
        bins hit = {1};
      }

      /************************ READING *********************/
      rd_addr: coverpoint trans.rd_addr {
        bins addr_min =   {MIN_ADDR};
        bins addr_max =   {MAX_ADDR};
        bins non_corner = {[MIN_ADDR + 1 : MAX_ADDR - 1]};
      }

      rd_data: coverpoint trans.rd_data{
        bins zeros      = {'0};
        bins all_ones   = {'1};
        bins non_corner = {['0 + 1 : '1 - 1]};
      }

      //cross the rd_addr catagories with the rd_data
      //This covers read after write fucntionality becasue
      //we can only read data out after it has been written.
      read_after_write: cross rd_addr, rd_data;

      /**************************************************************************/
      //@(posedge clk) rd_addr == wr_addr, and write is enabled.
      //
      //Becasue our reads are combinatorial, and writes are syncronous
      //the rd_data = mem[wr_addr] should read out the old data @mem[wr_addr]
      //not the new wr_data that is in the process of being clked into memory.
      //
      //The functionality that this coverpoint is trying to capture is the
      //fact the combinatorial read path is "independent" of the synchronous
      //write path, in the sense that reads should be asyncronous.
      //
      //rd_addr and rd_data are not effected by changes on wr_addr, wr_data and wr_en
      //(even if wr_en == 1, wr_addr == rd_addr). Those changes wont take
      //effect until AFTER the clock edge.
      /**************************************************************************/
      read_before_write: coverpoint (trans.wr_en && (trans.rd_addr == trans.wr_addr)) {
        bins hit = {1};
      }
    endgroup

    function void update_state();
      prev_wr_en = trans.wr_en;
      prev_wr_addr = trans.wr_addr;
    endfunction

    function void reset_state();
      prev_wr_en = '0;
      prev_wr_addr = 'x;
    endfunction

    function void sample(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) trans);
      this.trans = trans;
      cg.sample();
      update_state();
    endfunction

    function new();
      this.cg = new();
      this.reset_state();
    endfunction
  endclass
endpackage
