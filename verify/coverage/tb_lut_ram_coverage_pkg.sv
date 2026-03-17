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
    bit written [logic[$clog2(LUT_DEPTH)-1:0]]; //keep track of which addresses have been written to at least once
    logic prev_wr_en;
    logic [$clog2(LUT_DEPTH)-1:0] prev_wr_addr;

    function new();
      this.cg = new();
      this.reset_state();
    endfunction

    function void update_state();
      if(trans.wr_en) begin
        written[trans.wr_addr] = 1;
      end
      prev_wr_en = trans.wr_en;
      prev_wr_addr = trans.wr_addr;
    endfunction

    function void reset_state();
      written.delete();
      prev_wr_en = '0;
      prev_wr_addr = 'x;
    endfunction

    function void sample(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) trans);
      this.trans = trans;
      cg.sample();
      update_state();
    endfunction

    /*==============================  COVERGROUP  =================================*/
    covergroup cg;
      /****************** WRITING *********************/
      wr_en: coverpoint trans.wr_en{
        bins write = {1'b1};
        bins no_write = {1'b0};
      }

      wr_addr: coverpoint trans.wr_addr {
        bins addr_min            = {MIN_ADDR};
        bins second_addr         = {MIN_ADDR + 1};
        bins second_to_last_addr = {MAX_ADDR - 1};
        bins addr_max            = {MAX_ADDR};
        bins non_corner          = default;
      }

      //we want to write and not write to our corner addresses
      wr_addr_x_wr_en: cross wr_addr, wr_en;

      //we want to write back to back to at least one address
      back_to_back_writes: coverpoint ((trans.wr_addr == prev_wr_addr) && (trans.wr_en && prev_wr_en)) {
        bins hit = {1};
      }

      //We want to write all 1s and all 0s through the wr_data port
      //  - We only want to collect this coverage when wr_en == 1, i.e. we are writing
      wr_data: coverpoint trans.wr_data
        iff(trans.wr_en) {
          bins zeros      = {'0};
          bins all_ones   = {'1};
          bins non_corner = default;
      }

      //we want to write corner wr_data into corner addresses
      wr_data_x_wr_addr: cross wr_data, wr_addr;


      /*********************** READING *********************/

      //Note: we only want to collect rd_addr coverage on addresses that have
      //been written into already. Reading unwritten/uninitialized addresses that
      //point to x's doesnt verify much and is not the functionality we are interested in covering.
      rd_addr: coverpoint trans.rd_addr
        iff(written.exists(trans.rd_addr)) {
          bins addr_min            = {MIN_ADDR};
          bins second_addr         = {MIN_ADDR + 1};
          bins second_to_last_addr = {MAX_ADDR - 1};
          bins addr_max            = {MAX_ADDR};
          bins non_corner          = default;
      }

      rd_data: coverpoint trans.rd_data
        iff(written.exists(trans.rd_addr)) {
          bins zeros      = {'0};
          bins all_ones   = {'1};
          bins non_corner = default;
      }

      //we want to read corner data out of all corner addresses
      rd_data_x_rd_addr: cross rd_data, rd_addr;

      //Cover reading and writing to the same address during the same transaction
      //  - rd_data will be the old data at that address, not the new wr_data
      //    about to be clocked in
      //  - NOTE: iff(rd_data != wr_data)
      //      - This functionality is only verifiable when the data already in
      //        the memory is different than the data about to be written in.
      //        We only want to cover functionality when its verifiable.
      //  - Note:
      //      - I dont guard with iff(written). The fact that the rd_addr
      //        might be unwritten doesnt matter here. We dont really care
      //        what is in the memory currently, just that it is not what is
      //        about to get written in.
      read_during_write: coverpoint (trans.wr_en && (trans.rd_addr == trans.wr_addr)) 
        iff(trans.rd_data != trans.wr_data) {
          bins hit = {1};
      }

      //We want to cover reading from a register the clk cycle immediately
      //preceding the clk cycle it got written to.
      //  - Note:
      //       - There is a small verifiablility gap here.
      //       - If the memory already held the same data that got written in,
      //         then we cant really verify much about the next cycle read
      //         functionality (did the write actually work? We dont know
      //         because the write data was already in memory)
      //       - SEE: the note in the tb_reg_file_coverage_pkg.sv for 
      //          a deeper explanation.
      next_cycle_read_after_write: coverpoint ((trans.rd_addr == prev_wr_addr) && prev_wr_en) {
        bins hit = {1};
      }
    endgroup
  endclass

endpackage
