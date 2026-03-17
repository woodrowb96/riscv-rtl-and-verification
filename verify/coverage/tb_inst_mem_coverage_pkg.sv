/*
  Coverage for this module is collected manually through the sample() function.

  COVERAGE SAMPLING ASSUMPTIONS:
        - sample() is being called AFTER inst_addr has been driven onto the DUT
          and AFTER the combinatorial inst output has had time to settle.
*/
package tb_inst_mem_coverage_pkg;
  import rv32i_config_pkg::*;
  import rv32i_defs_pkg::*;
  import verify_const_pkg::*;
  import tb_inst_mem_transaction_pkg::*;

  class tb_inst_mem_coverage;

    inst_mem_trans trans;

    function new();
      this.cg = new();
    endfunction

    function void sample(inst_mem_trans trans);
      this.trans = trans;
      cg.sample();
    endfunction

    function bit misaligned_addr(word_t inst_addr);
      return inst_addr[1:0] != 2'b00 ? 1 : 0;
    endfunction

    function bit out_of_bound_addr(word_t inst_addr);
      //get rid of the byte offset and check if we are OOB
      return ((inst_addr >> 2) >= INST_MEM_DEPTH) ? 1 : 0;
    endfunction

    /*==============================  COVERGROUP  =================================*/
    covergroup cg;

      /************* INST_ADDR COVERAGE *****************/
      inst_addr: coverpoint trans.inst_addr {
        bins first_addr          = {INST_MEM_FIRST_ADDR};
        bins second_addr         = {INST_MEM_FIRST_ADDR + 'd4};
        bins second_to_last_addr = {INST_MEM_LAST_ADDR  - 'd4};
        bins last_addr           = {INST_MEM_LAST_ADDR};
        bins non_corner          = default;
      }

      //My implementation assumes alligned access, but the module is supposed
      //to handle the misaligned case silently so we'll cover it.
      misaligned_access: coverpoint misaligned_addr(trans.inst_addr){
        bins aligned = {0};
        bins misaligned = {1};
      }

      //My implementation assumes inbound access, but the module is supposed
      //to handle the out-of-bound case silently so well cover it.
      out_of_bound_access: coverpoint out_of_bound_addr(trans.inst_addr){
        bins in_bound = {0};
        bins out_of_bound = {1};
      }

      /************* INST COVERAGE *****************/
      inst: coverpoint trans.inst {
        bins all_zeros =  {WORD_ALL_ZEROS};
        bins all_ones =   {WORD_ALL_ONES};
        bins non_corner = default;
      }

    endgroup
  endclass

endpackage
