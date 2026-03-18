/*
  NOTE: reset coverage
    - I dont currently cover any reset functionality. I am going to modify the
    base verification library (see ../../lib/) to make handling resets accross components
    easier. Im going to finish the if_stage without reset coverage, then modify the
    library, then come back and add reset coverage (and any additional tests) to the 
    if_stage verification.
*/
package tb_if_stage_coverage_pkg;
  import tb_if_stage_transaction_pkg::*;
  import rv32i_config_pkg::*;
  import verify_const_pkg::*;

  class tb_if_stage_coverage;

    if_stage_trans trans;

    function new();
      this.cg = new();
    endfunction

    function sample(if_stage_trans trans);
      this.trans = trans;
      cg.sample();
    endfunction

    /*==============================  COVERGROUP  =================================*/
    covergroup cg;

      /*************** BRANCH COVERAGE ***************/

      branch: coverpoint trans.branch {
        bins taken     = {1};
        bins not_taken = {0};

        //transition bins:
        bins back_to_back_take          = (1[*2]);
        bins back_to_back_not_take      = (0[*2]);
        bins take_not_taken_taken       = (1 => 0 => 1);
        bins not_taken_take_not_taken   = (0 => 1 => 0);
      }

      //We want to branch to the following corner addresses in memory
      //(we will cover the branch distance from pc in a seperate coverpoint)
      branch_target: coverpoint trans.branch_target
        iff(trans.branch) { //only cover on branch takens
          bins first_addr          = {INST_MEM_FIRST_ADDR};
          bins second_addr         = {INST_MEM_FIRST_ADDR + 'd4};
          bins second_to_last_addr = {INST_MEM_LAST_ADDR  - 'd4};
          bins last_addr           = {INST_MEM_LAST_ADDR};
          bins non_corner          = default;
      }


      /********* BRANCH DISTANCE COVERAGE ***************/

      //We need to collect some coverage for how far from PC we are jumping
      //NOTE:
      //  - According to the RISCV spec the max B-type branches have a max
      //  range of -4096->4094 bytes and J-type branches have a max range of
      //  -1048576->1048574 bytes. My implementation currently is using an inst_mem
      //  that is only 256 words deep. So I will only cover the max range
      //  possible for my implementation (1024 bytes). If in the future the full
      //  range for B-type and J-types are available we will cover those
      //  distances.
      branch_distance: coverpoint $signed(trans.branch_target - trans.pc)
        iff(trans.branch) {  //only cover when we are actually branching
          //we want to hit the corner distances
          bins max_neg       = {MAX_NEG_BRANCH_DIST};  //max negative distance physically allowed in mem
          bins pc_minus_four = {-4}; //branch to the instruction below PC
          bins pc            = {0};  //branch to PC
          bins pc_plus_four  = {4};  //branch to the next PC
          bins max_pos       = {MAX_POS_BRANCH_DIST};  //max positive distance physically allowed in mem

          //We want to hit both non_corner negatives and non_corner positives
          bins branch_backward = {[MAX_NEG_BRANCH_DIST + 1 : -8]};
          bins branch_forward  = {[8 : MAX_POS_BRANCH_DIST - 1]};

      }

      /***************** PC COVERAGE ********************/

      //We want PC to hit the following corner addresses
      pc: coverpoint trans.pc {
          bins first_addr          = {INST_MEM_FIRST_ADDR};
          bins second_addr         = {INST_MEM_FIRST_ADDR + 'd4};
          bins second_to_last_addr = {INST_MEM_LAST_ADDR  - 'd4};
          bins last_addr           = {INST_MEM_LAST_ADDR};
          bins non_corner          = default;
      }

      //We want to both branch and not branch from each corner.
      //  -NOTE: if pc is the last_addr and we dont take the branch the
      //         rtl will silently wrap to the start of memory
      pc_x_branch: cross pc, branch;


      /**************** INST COVERAGE *******************/

      inst: coverpoint trans.inst {
        bins all_ones = {WORD_ALL_ONES};
        bins all_zeros = {WORD_ALL_ZEROS};
        bins non_corner = default;
      }

      /*************** MISALIGNED BRANCH COVERAGE **********************/

      //This shouldnt happen durring normal operation, but the rtl silently
      //rounds this down to be word aligned, so well cover it. Also in the
      //future when exceptions get implemented this will throw an exception
      misaligned_branch: coverpoint (trans.branch_target[1:0] != 2'b00)
        iff(trans.branch) { //only cover on actual branches
          bins hit = {1};
      }

      //Im not going to cover misaligned PC's. The only way PC can get
      //misaligned is through a branch (every PC + 4 after a misaligned branch
      //will also be misaligned) so covering misaligned PC is a bit
      //redundent on its own.

      /********** OUT OF BOUNDS ACCESS COVERAGE ************/
      //out of bound access will eventually throw an ACCESS FAULT exception,
      //but for now the rtl silently wraps the addresses to the start of
      //memory.

      //cover branching out of bounds
      out_of_bound_branch: coverpoint (trans.branch_target > INST_MEM_LAST_ADDR)
        iff(trans.branch) {
          bins hit = {1};
      }

      //cover pc when its pointing out of bounds
      out_of_bound_pc: coverpoint (trans.pc > INST_MEM_LAST_ADDR) {
          bins hit = {1};
      }
    endgroup

  endclass

endpackage
