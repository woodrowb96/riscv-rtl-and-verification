package tb_data_mem_generator_pkg;
  import base_generator_pkg::*;
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import verify_const_pkg::*;
  import tb_data_mem_transaction_pkg::*;

  //SEE THE NOTE IN: tb_lut_ram_generator_pkg.sv for why im using child trans
  //classes instead of just inlining this stuff in the generator

  class data_mem_trans_base_constraints extends data_mem_trans;
    constraint general_corners {

      //Im going to constrain wr_sel to only the scenarios its going to hit
      //during riscv operation. For now I am choosing not to hit the non-riscv
      //operations.
      wr_sel dist {
        4'b0000 := 1, //no_write
        4'b0001 := 3, //sb
        4'b0011 := 3, //sh
        4'b1111 := 3  //sw
      };

      //hit the data corners, but also get some full range values in too
      wr_data dist {
        WORD_ALL_ZEROS                 := 1,
        WORD_ALL_ONES                  := 1,
        [WORD_ALL_ZEROS:WORD_ALL_ONES] :/ 5
      };
    };
  endclass

  //constrain the trans to just hit address corners
  class data_mem_trans_corner_addr extends data_mem_trans_base_constraints;
    constraint addr_corners {
      addr inside {
        //first word
        DATA_MEM_FIRST_ADDR,
        DATA_MEM_FIRST_ADDR + 1,
        DATA_MEM_FIRST_ADDR + 2,
        DATA_MEM_FIRST_ADDR + 3,
        //last word
        DATA_MEM_LAST_WORD_ADDR,
        DATA_MEM_LAST_WORD_ADDR + 1,
        DATA_MEM_LAST_WORD_ADDR + 2,
        DATA_MEM_LAST_ADDR
      };
    };
  endclass

  class data_mem_trans_prev_written extends data_mem_trans_base_constraints;
    word_t prev_written_addr [$];

    function new(word_t prev_written_addr [$]);
      super.new();
      this.prev_written_addr = prev_written_addr;
    endfunction

    constraint prev_written {
      addr inside {prev_written_addr};
    }
  endclass

  /*==============================================================================*/
  /*------------------------------ GENERATOR -------------------------------------*/
  /*==============================================================================*/
  class data_mem_default_gen extends base_generator #(data_mem_trans);

    //use a dynamic queue to keep track of previously written addresses
    //  - Note: I init with 0, so the solver never tries to solve a 
    //          constraint with an empty queue in it
    word_t prev_written_addr [$] = {0};

    function new(mailbox_t gen_to_drv_mbx);
      super.new("DATA_MEM_DEFAULT_GEN", gen_to_drv_mbx);
    endfunction

    function void reset_prev_written_addr();
      prev_written_addr = {0};
    endfunction

    function void update_prev_written_addr(data_mem_trans trans);
      if(trans.wr_sel) begin
        prev_written_addr.push_back(trans.addr);
      end
    endfunction

    task run();
      data_mem_trans trans;

      //We want to randomly choose a transaction that hits either
      //the corner addresses, previously written addresses, or the full range of addresses
      randcase

        //corner addresses
        4: begin
          data_mem_trans_corner_addr trans_corner_addr = new();

          assert(trans_corner_addr.randomize()) else
            $fatal(1, "TB_DATA_MEM_GENERATOR: randomization failed, corners addresses");

          trans = trans_corner_addr;
        end

        //previously written addresses
        5: begin
          data_mem_trans_prev_written trans_prev_written = new(prev_written_addr);

          assert(trans_prev_written.randomize()) else
            $fatal(1, "TB_DATA_MEM_GENERATOR: randomization failed, prev_written");

          trans = trans_prev_written;
        end

        //full range of addresses
        3: begin
          data_mem_trans_base_constraints trans_full_range = new();

          assert(trans_full_range.randomize()) else
            $fatal(1, "TB_DATA_MEM_GENERATOR: randomization failed, full_range");

          trans = trans_full_range;
        end
      endcase

      //update previously written addresses
      update_prev_written_addr(trans);

      gen_to_drv_mbx.put(trans);
    endtask
  endclass

endpackage
