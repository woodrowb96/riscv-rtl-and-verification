package tb_data_mem_coverage_pkg;
  import riscv_32i_config_pkg::*;
  import riscv_32i_config_pkg::*;
  import riscv_32i_defs_pkg::*;

  class tb_data_mem_coverage;
    virtual data_mem_intf.monitor vif;

    //using an associative array to keep track of prev written addresses
    word_t prev_written_addresses [word_t];

    //A function to check if the trans on vif, is currently overwritting a
    //previously written address
    //
    //  -NOTE: Calling this function will also update the prev_written_addresses
    //         and add the current_addr if vif.wr_sel != 0
    function automatic bit overwritting(word_t current_addr);
      bit overwrite = 0;

      if(vif.wr_sel != 0) begin                                  //if we are currently writting
        overwrite = prev_written_addresses.exists(current_addr); //see if we already wrote to the current_addr
        prev_written_addresses[current_addr] = 1;                //and add the current_addr to the prev_written array
      end

      return overwrite;
    endfunction

    function void clear_prev_written_addresses();
      prev_written_addresses.delete();
    endfunction

    covergroup cg @(posedge vif.clk);

      //We want to cover the specific wr_sel patterns the rv32i implementation
      //will exercise during operation.
      // - store byte, store halfword, store word
      // - and not writting
      wr_sel: coverpoint vif.wr_sel{
        bins no_write = {4'b0000};
        bins sb       = {4'b0001};
        bins sh       = {4'b0011};
        bins sw       = {4'b1111};
        bins others   = default;
      }

      //want to hit the following interesting addr corners
      // - the first address in mem (it points to both the first word, and first byte)
      // - the address of each byte in the last word in memory
      //NOTE: byte_3 of the last word, is the last address in our byte
      //      addressable memory
      addr: coverpoint vif.addr {
        bins first_addr       = {DATA_MEM_FIRST_ADDR};
        bins last_word_byte_0 = {DATA_MEM_LAST_WORD_ADDR};
        bins last_word_byte_1 = {DATA_MEM_LAST_WORD_ADDR + 1};
        bins last_word_byte_2 = {DATA_MEM_LAST_WORD_ADDR + 2};
        bins last_word_byte_3 = {DATA_MEM_LAST_ADDR};
        bins non_corner       = {[DATA_MEM_FIRST_ADDR + 1     : DATA_MEM_LAST_WORD_ADDR - 1]};
      }

      //we want to do each type of write, and no_write from all the
      //interesting addr corners
      wr_sel_x_addr: cross addr, wr_sel;

      //we want to cover reading a byte from each byte offset in mem
      byte_offset: coverpoint vif.addr[1:0];

      //we want to do each type of write and_no_write from all the byte offests
      wr_sel_x_byte_offset: cross byte_offset, wr_sel;

      //we want to read and write all ones, all zeros and non_corners
      //from the read and write data ports
      wr_data: coverpoint vif.wr_data {
        bins all_ones    = {WORD_ALL_ONES};
        bins all_zeros   = {WORD_ALL_ZEROS};
        bins non_corners = {[WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]};
      }
      rd_data: coverpoint vif.rd_data {
        bins all_ones    = {WORD_ALL_ONES};
        bins all_zeros   = {WORD_ALL_ZEROS};
        bins non_corners = {[WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]};
      }

      //we want to cover overwritting prev written data
      overwrite: coverpoint overwritting(vif.addr) {
        bins hit = {1};
      }

      //we want to make sure we overwrite in all combos of wr_sel and at each byte offset
      overwrite_x_byte_offset_x_wr_sel: cross overwrite, byte_offset, wr_sel {
        ignore_bins not_writting = binsof(wr_sel.no_write);
      }
    endgroup

    function new(virtual data_mem_intf.monitor vif);
      this.vif = vif;
      this.cg = new();
    endfunction

    function void start();
      cg.start();
    endfunction

    function void stop();
      cg.stop();
    endfunction
  endclass
endpackage
