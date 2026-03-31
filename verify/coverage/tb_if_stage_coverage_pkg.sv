/*
    Coverage for this module is collected manually through a sample() function.

    COVERAGE SAMPLING ASSUMPTIONS:
        - sample() is being called AFTER the DUT signals have been driven onto the DUT's input ports
          and AFTER the combinatorial instruction has had time to propagate to the inst output.
          but BEFORE the next pc has been clocked onto the current pc.
*/
package tb_if_stage_coverage_pkg;
  import tb_if_stage_transaction_pkg::*;
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import verify_const_pkg::*;

  class tb_if_stage_coverage;

    if_stage_trans trans;

    function new();
      this.cg = new();
    endfunction

    function void sample(if_stage_trans trans);
      this.trans = trans;
      cg.sample();
    endfunction

    /*==============================  COVERGROUP  =================================*/
    covergroup cg;

      /*************** BRANCH COVERAGE ***************/

      branch: coverpoint trans.branch {
        bins taken     = {1};
        bins not_taken = {0};
      }

      //These should get ignored in crosses, but Vivado is crossing them so
      //I'll just split them out
      branch_transitions: coverpoint trans.branch {
        bins back_to_back_take          = (1[*2]);
        bins back_to_back_not_take      = (0[*2]);
        bins take_not_taken_taken       = (1 => 0 => 1);
        bins not_taken_take_not_taken   = (0 => 1 => 0);
      }

      //We want to branch to the following corner addresses in memory
      //(we will cover the branch distance from pc in a separate coverpoint)
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
      //  -NOTE: if pc is the last_addr and we don't take the branch the
      //         rtl will silently wrap to the start of memory
      pc_x_branch: cross pc, branch {
        //Not branching when we are at the last_addr will take us out of
        //bounds. We will ignore it for now and cover OOB PC coverage separately
        ignore_bins last_addr_x_not_taken = binsof(pc.last_addr) && binsof(branch.not_taken);
      }


      /**************** INST COVERAGE *******************/

      inst: coverpoint trans.inst {
        bins all_ones = {WORD_ALL_ONES};
        bins all_zeros = {WORD_ALL_ZEROS};
        bins non_corner = default;
      }

      /*************** MISALIGNED BRANCH COVERAGE **********************/

      //This shouldn't happen during normal operation, but the rtl silently
      //rounds this down to be word aligned, so we'll cover it. Also in the
      //future when exceptions get implemented this will throw an exception
      misaligned_branch: coverpoint (trans.branch_target[1:0] != 2'b00)
        iff(trans.branch) { //only cover on actual branches
          bins hit = {1};
      }

      //The only way to get to a misaligned PC is through a misaligned branch
      //(Every PC + 4 after the misaligned branch will also be misaligned).
      //So we are not going to cover hitting misaligned PC addresses by
      //themselves.
      //
      //What is worth covering is incrementing (so not taking a branch) from
      //a misaligned PC (So PC_misaligned + 4). This stresses the PC + 4 logic
      //and makes sure it handles the silent rounding down the misaligned byte_offset properly.
      increment_misaligned_pc: coverpoint (
        (trans.pc[1:0] != 2'b00) &&  //make sure the current PC is misaligned
        (!trans.branch)              //make sure we aren't branching (so doing PC + 4 instead)
      ){
        bins hit = {1};
      }


      /********** OUT OF BOUNDS ACCESS COVERAGE ************/
      //out of bound access will eventually throw an ACCESS FAULT exception,
      //but for now the rtl silently wraps the addresses to the start of
      //memory.

      //PC can either increment (pc + 4) into the out of bounds, or it can
      //branch into out of bounds. We need to cover both scenarios.
      branch_to_oob_pc: coverpoint (trans.branch_target > INST_MEM_LAST_ADDR)
        iff(trans.branch) {
          bins hit = {1};
      }
      increment_to_oob_pc: coverpoint (
        (trans.pc == INST_MEM_LAST_ADDR) &&  //if we are at the last address
        (!trans.branch)                      //and we don't branch then we will increment OOB
      ) {
          bins hit = {1};
      }

      //We want to branch oob with a misaligned branch_target.
      //(This will stress both wrapping of addresses and rounding down of
      //misaligned byte_offset logic at the same time)
      misaligned_branch_x_branch_to_oob_pc: cross misaligned_branch, branch_to_oob_pc;

      //We want to increment a misaligned PC OOB
      //(This makes sure the PC + 4 logic handles both the wrapping of
      //addresses and the dropping of misaligned byte_offsets at the same time)
      increment_misaligned_pc_to_oob: coverpoint (
        (trans.pc[1:0] != 2'b00)                           &&  //if the current PC is misaligned
        ({trans.pc[XLEN-1:2],2'b00} == INST_MEM_LAST_ADDR) &&  //and it points to the last addr (ignoring the byte_offset)
        (!trans.branch)                                        //and we don't branch, then we will be incrementing a misaligned PC OOB
      ) {
        bins hit = {1};
      }
    endgroup

  endclass

endpackage
