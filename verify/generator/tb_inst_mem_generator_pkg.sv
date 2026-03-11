package tb_inst_mem_generator_pkg;
  import base_generator_pkg::*;
  import tb_inst_mem_transaction_pkg::*;
  import rv32i_config_pkg::*;

  //SEE THE NOTE IN: tb_lut_ram_generator_pkg.sv for why im using child trans
  //classes instead of just inlining this stuff in the generator
  class inst_mem_trans_corner_addr extends inst_mem_trans;
    constraint inst_addr_corners {
      inst_addr dist {
        INST_MEM_FIRST_ADDR     := 1,
        INST_MEM_FIRST_ADDR + 4 := 1,
        INST_MEM_LAST_ADDR - 4  := 1,
        INST_MEM_LAST_ADDR      := 1
      };
    }
  endclass

  class inst_mem_trans_oob extends inst_mem_trans;

    //we are overriding the legal_addr_range const in the base class
    //so that we will only gen OOB addresses
    constraint legal_addr_range {
      inst_addr > INST_MEM_LAST_ADDR;
    }
  endclass

  class inst_mem_trans_misaligned extends inst_mem_trans;

    //override the word_aligned constraint to force a non-zero byte offset
    constraint word_aligned {
      inst_addr[1:0] != 2'b00;
    }
  endclass

  /*==============================================================================*/
  /*------------------------------ DEFAULT GENERATOR -----------------------------*/
  /*==============================================================================*/

  class inst_mem_default_gen extends base_generator #(inst_mem_trans);

    function new(mailbox_t gen_to_drv_mbx);
      super.new("INST_MEM_DEFAULT_GEN", gen_to_drv_mbx);
    endfunction

    //use randcase to either gen a transaction that hits the corner addresses
    //or one that hits the full address range
    function inst_mem_trans gen_trans();
      inst_mem_trans trans;
      randcase
        1: begin
          inst_mem_trans_corner_addr trans_corner_addr = new();

          assert(trans_corner_addr.randomize()) else
            $fatal(1, "[%s]: gen_trans() randomization failed, trans_corner_addr", tag);

          trans = trans_corner_addr;
        end
        5: begin
          inst_mem_trans trans_full_addr_range = new();

          assert(trans_full_addr_range.randomize()) else
            $fatal(1, "[%s]: gen_trans() randomization failed, trans_full_addr_range", tag);

          trans = trans_full_addr_range;
        end
      endcase
      return trans;
    endfunction
  endclass

  /*==============================================================================*/
  /*------------------------------ MISALIGNED GENERATOR --------------------------*/
  /*==============================================================================*/

  class inst_mem_misaligned_gen extends base_generator #(inst_mem_trans);

    function new(mailbox_t gen_to_drv_mbx);
      super.new("INST_MEM_MISALIGNED_GEN", gen_to_drv_mbx);
    endfunction

    function inst_mem_trans gen_trans();
      inst_mem_trans_misaligned trans = new();

      assert(trans.randomize()) else
        $fatal(1, "[%s]: gen_trans() randomization failed", tag);

      return trans;
    endfunction
  endclass

  /*==============================================================================*/
  /*------------------------------ OOB GENERATOR ---------------------------------*/
  /*==============================================================================*/

  class inst_mem_oob_gen extends base_generator #(inst_mem_trans);

    function new(mailbox_t gen_to_drv_mbx);
      super.new("INST_MEM_OOB_GEN", gen_to_drv_mbx);
    endfunction

    function inst_mem_trans gen_trans();
      inst_mem_trans_oob trans = new();

      assert(trans.randomize()) else
        $fatal(1, "[%s]: gen_trans() randomization failed", tag);

      return trans;
    endfunction
  endclass

endpackage
