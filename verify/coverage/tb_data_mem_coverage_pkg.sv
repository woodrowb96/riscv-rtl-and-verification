/*
  Coverage for this module is collected manually through the sample() function.

  COVERAGE SAMPLING ASSUMPTIONS:
        - sample() is being called AFTER the DUT signals have been driven onto the DUT's input ports
          and AFTER the combinatorial addr has had time to propagate to rd_data
          but BEFORE the new wr_data has been clocked into memory.

       - NOTE:
            - The covergroup uses state variables to collect coverage.
            - This state is updated when you call sample().
            - If you drive/clock the DUT without calling sample(), the coverage
              state will get out of sync with the test state.
       - NOTE:
            - If you reset the DUT in between tests you can call
              reset_state() to reset state.
              (this will NOT reset the coverage percentages, just the state variables)
*/
package tb_data_mem_coverage_pkg;
  import rv32i_config_pkg::*;
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
  import verify_const_pkg::*;
  import tb_data_mem_transaction_pkg::*;

  class tb_data_mem_coverage;

    data_mem_trans trans;

    //we keep some state to help with coverage collection
    byte_sel_t written [word_t]; //we need to keep track of which bytes in each address have been written to
    byte_sel_t prev_wr_sel;
    word_t     prev_addr;

    function new();
      this.cg = new();
      this.reset_state();
    endfunction

    function reset_state();
      written.delete();
      prev_wr_sel = '0;
      prev_addr   = 'x;
    endfunction

    function update_state();
      if(!written.exists(trans.addr)) begin
        //if this is the first write to the address, then the current wr_sel
        //tells us which bytes were written
        written[trans.addr] = trans.wr_sel;
      end
      else begin
        //else we can OR with the new wr_sel to get any new writes
        written[trans.addr] |= trans.wr_sel;
      end
      prev_wr_sel = trans.wr_sel;
      prev_addr   = trans.addr;
    endfunction

    function void sample(data_mem_trans trans);
      this.trans = trans;
      this.cg.sample();
      this.update_state();
    endfunction

    /*==============================  COVERGROUP  =================================*/
    covergroup cg;

      /***************** ADDRESS COVERAGE ****************************/

      //want to hit the following interesting addr corners
      //  - Each byte of the first word in memory
      //  - Each byte of the last word in memory
      addr: coverpoint trans.addr {
        //first word
        bins first_word_byte_0 = {DATA_MEM_FIRST_ADDR};
        bins first_word_byte_1 = {DATA_MEM_FIRST_ADDR + 1};
        bins first_word_byte_2 = {DATA_MEM_FIRST_ADDR + 2};
        bins first_word_byte_3 = {DATA_MEM_FIRST_ADDR + 3};
        //last word
        bins last_word_byte_0  = {DATA_MEM_LAST_WORD_ADDR};
        bins last_word_byte_1  = {DATA_MEM_LAST_WORD_ADDR + 1};
        bins last_word_byte_2  = {DATA_MEM_LAST_WORD_ADDR + 2};
        bins last_word_byte_3  = {DATA_MEM_LAST_ADDR};

        bins non_corner        = default;
      }

      //We want to hit each byte offset at least once
      byte_offset: coverpoint trans.addr[1:0];


      /********************* WRITE COVERAGE *********************/

      //We want to cover the specific wr_sel patterns the rv32i implementation
      //will exercise during operation.
      // - store byte, store half-word, store word and no-write
      wr_sel: coverpoint trans.wr_sel{
        bins no_write = {4'b0000};
        bins sb       = {4'b0001};
        bins sh       = {4'b0011};
        bins sw       = {4'b1111};
        bins others   = default;
      }

      //we want to write all 1s and all 0s
      //  -NOTE: we only collect when we are actually writing
      wr_data: coverpoint trans.wr_data 
        iff(trans.wr_sel) {
          bins all_ones    = {WORD_ALL_ONES};
          bins all_zeros   = {WORD_ALL_ZEROS};
          bins non_corners = default;
      }

      //We want to do write all 1s and all 0s to each corner addr, with each type of wr_sel
      //  - NOTE: we don't want to collect the wr_data cross when we are not writing
      wr_sel_x_addr_x_wr_data: cross addr, wr_sel, wr_data {
        ignore_bins no_write_x_wr_data = binsof(wr_sel.no_write) && binsof(wr_data);
      }

      //We want to write all 1s and all 0s across each byte_offset, with each type of wr_sel
      //  - NOTE: we don't want to collect the wr_data cross when we are not writing
      wr_sel_x_byte_offset_x_wr_data: cross byte_offset, wr_sel, wr_data {
        ignore_bins no_write_x_wr_data = binsof(wr_sel.no_write) && binsof(wr_data);
      }

      /*********** BACK TO BACK WRITE COVERAGE **********************/

      //We want to cover back to back writes to the same address.
      //  - (trans.wr_sel & prev_wr_sel) //bitwise AND
      //       - The bitwise AND lets us pick out which bits in the wr_sel overlap between
      //         consecutive transactions. (Each bit corresponds to which byte
      //         is being written, so this is really picking out which bytes
      //         are getting hit back-to-back)
      //       - Writes are byte granular, so we need to see which bytes in
      //         the wr_sel signals are getting hit back to back.
      // - iff(trans.addr == prev_addr)
      //       - Only collect coverage when we are hitting the same address
      //         back to back. Nothing gets overwritten (most likely) if they are different.
      back_to_back_write: coverpoint (trans.wr_sel & prev_wr_sel)
        iff (trans.addr == prev_addr) {
          wildcard bins byte_0 = {4'b???1};
          wildcard bins byte_1 = {4'b??1?};
          wildcard bins byte_2 = {4'b?1??};
          wildcard bins byte_3 = {4'b1???};
          //Writes are byte granular, so we bin back-to-back-write
          //functionality on each byte separately.
          //  - NOTE: Im using wildcard bins. So consecutive wr_sel == 1111 will
          //          hit all 4 bins. This is the desired coverage we want. We
          //          just want to make sure there was overlap on each byte lane
          //          at least once, regardless of what happens on the other lanes.
      }

      //We want to capture back-to-back-write functionality from each byte offset.
      back_to_back_write_x_byte_offset: cross back_to_back_write, byte_offset;


      /********************* READ COVERAGE *********************/

      //We read a word out at a time, but because writes are byte granular not
      //every byte in that word will necessarily have been written to.
      //This coverpoint will be used in read coverage crosses to make sure
      //each read coverpoint covers reading each byte in the word.
      //(see the addr_x_written_bytes and byte_offset_x_written_bytes)
      written_bytes: coverpoint (written[trans.addr])
        iff(written.exists(trans.addr)) {  //make sure the written entry exists first
          wildcard bins byte_0 = {4'b???1};
          wildcard bins byte_1 = {4'b??1?};
          wildcard bins byte_2 = {4'b?1??};
          wildcard bins byte_3 = {4'b1???};
      }

      //We want to read written data out of each byte of each corner address
      addr_x_written_bytes: cross addr, written_bytes;

      //We want to read written data out of each byte in a word, from each
      //byte offset
      byte_offset_x_written_bytes: cross byte_offset, written_bytes;

      rd_data: coverpoint trans.rd_data {
        bins all_ones    = {WORD_ALL_ONES};
        bins all_zeros   = {WORD_ALL_ZEROS};
        bins non_corners = default;
      }

      //we want to read corner data out of each corner address
      rd_data_x_addr: cross rd_data, addr;

      //we want to read corner data out of each byte offset
      rd_data_x_byte_offset: cross rd_data, byte_offset;

      //The write and read address are always the same, so all reads are reads
      //during write (if wr_sel != 0). Writes are byte granular though, so we
      //need the wildcard bins to make sure we did a read_during_write while
      //writing to each byte.
      read_during_write: coverpoint (trans.wr_sel) {
        wildcard bins byte_0 = {4'b???1};
        wildcard bins byte_1 = {4'b??1?};
        wildcard bins byte_2 = {4'b?1??};
        wildcard bins byte_3 = {4'b1???};
      }

      //we want to do read_during_writes at each corner address
      read_during_write_x_addr: cross read_during_write, addr;

      //we want to do read_during_writes at each byte_offset
      read_during_write_x_byte_offset: cross read_during_write, byte_offset;

      //We want to cover reading the clk immediately following a write.
      //Once again, we need to bin each byte separately
      next_cycle_read_after_write: coverpoint prev_wr_sel
        iff(trans.addr == prev_addr) {
          wildcard bins byte_0 = {4'b???1};
          wildcard bins byte_1 = {4'b??1?};
          wildcard bins byte_2 = {4'b?1??};
          wildcard bins byte_3 = {4'b1???};
      }

      //we want to read_after_write at each corner address
      next_cycle_read_after_write_x_addr: cross next_cycle_read_after_write, addr;

      //we want to read_after_write at each byte_offset
      next_cycle_read_after_write_x_byte_offset: cross next_cycle_read_after_write, byte_offset;
    endgroup
  endclass

endpackage
