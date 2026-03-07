package tb_data_mem_generator_pkg;
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import verify_const_pkg::*;
  import tb_data_mem_transaction_pkg::*;

  //SEE THE NOTE IN: tb_lut_ram_generator_pkg.sv for why im using child trans
  //classes instead of just inlining this stuff in the generator
  

  //data and wr_sel are going to be constrained the same in all the other
  //classes so lets just make this class the common parent
  class data_mem_trans_base_contraints extends data_mem_trans;
    constraint general_corners {
      //Im just going to constrain the wr_sel to only test the scenarios it
      //will actually incounter in the rv32i scenarion (no_write, SB, SH and SW)
      //
      //  -NOTE: My rtl can handle the other wr_sel (ie 4'b1001, 4'b0101 ...)
      //         but for now im just going to test the rv32i scenarios.
      //         Normally I try and verify the full function of all the modules, but
      //         for now I want to keep the generator simple and just focus
      //         on rv32i functionality for wr_sel.
      wr_sel dist {
        4'b0000 := 1,
        4'b0001 := 2,
        4'b0011 := 2,
        4'b1111 := 2
      };

      wr_data dist {
        WORD_ALL_ZEROS                 := 1,
        WORD_ALL_ONES                  := 1,
        [WORD_ALL_ZEROS:WORD_ALL_ONES] :/ 5
      };
    };
  endclass

  //constraint the trans to just hit address corners
  class data_mem_trans_corner_addr extends data_mem_trans_base_contraints;
    constraint addr_corners {
      addr dist {
        DATA_MEM_FIRST_ADDR         := 1,
        DATA_MEM_LAST_WORD_ADDR     := 1,
        DATA_MEM_LAST_WORD_ADDR + 1 := 1,
        DATA_MEM_LAST_WORD_ADDR + 2 := 1,
        DATA_MEM_LAST_ADDR          := 1
      };
    };
  endclass

  class data_mem_trans_prev_written extends data_mem_trans_base_contraints;
    word_t prev_written_addr [$] = {0};

    constraint prev_written {
      addr inside {prev_written_addr};
    }
  endclass

  /************************* GENERATOR    *******************************************/
  class tb_data_mem_generator;

    //queue to keep track of our prev written addresses
    //  -I init to 0 so the solver never tries to inside {empty_queue}
    word_t prev_written_addr [$] = {0};

    function void reset_prev_written_addr();
      prev_written_addr = {0};
    endfunction

    function data_mem_trans gen_trans();
      data_mem_trans trans;
      randcase
        1: begin
          data_mem_trans_corner_addr trans_corner_addr = new();

          assert(trans_corner_addr.randomize()) else
            $fatal(1, "TB_DATA_MEM_GENERATOR: gen_trans() randomization failed, corners addresses");

          trans = trans_corner_addr;
        end
        5: begin
          data_mem_trans_prev_written trans_prev_written = new();

          //give the trans the current set of prev written addresses
          trans_prev_written.prev_written_addr = prev_written_addr;

          assert(trans_prev_written.randomize()) else
            $fatal(1, "TB_DATA_MEM_GENERATOR: gen_trans() randomization failed, prev_written");

          trans = trans_prev_written;
        end
        3: begin
          data_mem_trans_base_contraints trans_full_range = new();

          assert(trans_full_range.randomize()) else
            $fatal(1, "TB_DATA_MEM_GENERATOR: gen_trans() randomization failed, full_range");

          trans = trans_full_range;
        end
      endcase

      if(trans.wr_sel != 0) begin
        prev_written_addr.push_back(trans.addr);
      end

      // trans.print("TB_DATA_MEM_GENERATOR");
      return trans;
    endfunction
  endclass
endpackage
