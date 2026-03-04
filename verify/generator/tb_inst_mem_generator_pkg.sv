package tb_inst_mem_generator_pkg;
  import tb_inst_mem_transaction_pkg::*;
  import riscv_32i_config_pkg::*;

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
      inst_addr >= INST_MEM_LAST_ADDR;
    }
  endclass



  /****************** GENERATOR *****************************/
  class tb_inst_mem_generator;

    //use randcase to either gen a transaction that hits the corner addresses
    //or one that hits the full address range
    function inst_mem_trans gen_trans();
      inst_mem_trans trans;
      randcase
        1: begin
          inst_mem_trans_corner_addr trans_corner_addr = new();

          assert(trans_corner_addr.randomize()) else
            $fatal(1, "[TB_INST_MEM_GENERATOR]: gen_trans() randomization failed, trans_corner_addr");

          trans = trans_corner_addr;
        end
        5: begin
          inst_mem_trans trans_full_addr_range = new();

          assert(trans_full_addr_range.randomize()) else
            $fatal(1, "[TB_INST_MEM_GENERATOR]: gen_trans() randomization failed, trans_full_addr_range");

          trans = trans_full_addr_range;
        end
      endcase
      return trans;
    endfunction

    //a generator to generate out of bound transaction
    function inst_mem_trans gen_oob_trans;
      inst_mem_trans_oob trans = new();

      assert(trans.randomize()) else
        $fatal(1, "[TB_INST_MEM_GENERATOR]: gen_oob_trans() randomization failed");

      return trans;
    endfunction

    //a generator to generate misaligned transactions
    function inst_mem_trans gen_misaligned_trans;
      inst_mem_trans trans = new();

      assert(trans.randomize()) else
        $fatal(1, "[TB_INST_MEM_GENERATOR]: gen_misaligned_trans() randomization failed");

      //Add a misaligned offset to the random inst_addr 
      //(inst_addr is constrained to 2'b00 in the inst_mem_trans class)
      trans.inst_addr = trans.inst_addr + $urandom_range(1, 3);

      return trans;
    endfunction
  endclass
endpackage
