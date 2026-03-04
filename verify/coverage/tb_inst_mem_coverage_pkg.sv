package tb_inst_mem_coverage_pkg;
  import riscv_32i_config_pkg::*;
  import riscv_32i_defs_pkg::*;

  class tb_inst_mem_coverage;
    virtual inst_mem_intf.monitor vif;

    function bit misaligned_addr(word_t inst_addr);
      return inst_addr[1:0] != 2'b00 ? 1 : 0;
    endfunction

    function bit out_of_bound_addr(word_t inst_addr);
      //get rid of the byte offset and check if we are OOB
      return ((inst_addr >> 2) >= INST_MEM_DEPTH) ? 1 : 0;
    endfunction

    covergroup cg;

      /************* INST_ADDR COVERAGE *****************/
      inst_addr: coverpoint vif.inst_addr {
        bins first_addr          = {INST_MEM_FIRST_ADDR};
        bins second_addr         = {INST_MEM_FIRST_ADDR + 'd4};
        bins second_to_last_addr = {INST_MEM_LAST_ADDR - 'd4};
        bins last_addr           = {INST_MEM_LAST_ADDR};
        bins non_corner          = {[INST_MEM_FIRST_ADDR + 'd8 : INST_MEM_LAST_ADDR - 'd8]};
      }

      //My implementation assumes alligned access, but the module is supposed
      //to handle the misaligned case silently so well cover it.
      misaligned_access: coverpoint misaligned_addr(vif.inst_addr){
        bins aligned = {0};
        bins misaligned = {1};
      }

      //My implementation assumes inbound access, but the module is supposed
      //to handle the out-of-bound case silently so well cover it.
      out_of_bound_access: coverpoint out_of_bound_addr(vif.inst_addr){
        bins in_bound = {0};
        bins out_of_bound = {1};
      }

      /************* INST COVERAGE *****************/
      inst: coverpoint vif.inst {
        bins all_zeros =  {WORD_ALL_ZEROS};
        bins all_ones =   {WORD_ALL_ONES};
        bins non_corner = {[WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]};
      }

      //we want to read all the corner inst from each corner addr
      inst_x_inst_addr: cross inst, inst_addr;
    endgroup

    function void sample();
      cg.sample();
    endfunction

    function new(virtual inst_mem_intf.monitor vif);
      this.vif = vif;
      this.cg = new();
    endfunction
  endclass
endpackage
