package tb_if_stage_generator_pkg;
  import tb_if_stage_transaction_pkg::*;
  import base_generator_pkg::*;
  import rv32i_config_pkg::*;
  import rv32i_defs_pkg::*;
  import verify_const_pkg::*;

  //NOTE: Using the classes to hold all the constraints is partially
  //a workaround for a bug in Vivado.
  //SEE THE NOTE IN: tb_lut_ram_generator_pkg.sv for full details

  /*==============================================================================*/
  /*------------------------- BASE GENERATOR -------------------------------------*/
  /*==============================================================================*/
  //We don't use this in any test directly, but these transaction and generator base
  //classes have the logic to keep the PC in bounds throughout the sequence,
  //by forcing a branch whenever PC == INST_MEM_LAST_ADDR.

  class if_stage_trans_base_constraints extends if_stage_trans;
    word_t prev_pc;

    function new(word_t prev_pc);
      this.prev_pc = prev_pc;
    endfunction

    constraint force_branch_to_stay_in_bound {
      (prev_pc == INST_MEM_LAST_ADDR) -> (branch == 1);
    };
  endclass

  //GENERATOR
  virtual class if_stage_base_gen extends base_generator #(if_stage_trans);
    word_t prev_pc; //the previous pc from the last generated transaction

    function new(string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.reset_state();
    endfunction

    function void reset_state();
      prev_pc = PC_RESET;
    endfunction

    function void update_state(if_stage_trans trans);
      //We can use the most recently generated trans to update the prev_pc for
      //the next generation
      if(trans.branch === 1'b1) begin
        prev_pc = trans.branch_target;
      end
      else if(trans.branch === 1'b0) begin
        prev_pc += 'd4;
      end
      else begin //if branch is ever X/Z something went wrong with generation
        $fatal(1, "[%s] update_state(): branch is X/Z — randomization went wrong", tag);
      end
    endfunction
  endclass

  /*==============================================================================*/
  /*--------------------------- MAIN TEST GENERATOR ------------------------------*/
  /*==============================================================================*/
  //Generator for the main test.
  //Random branches and branch_targets.
  //Branch is slightly weighted towards not taking.

  class if_stage_trans_main_test extends if_stage_trans_base_constraints;

    function new(word_t prev_pc);
      super.new(prev_pc);
    endfunction

    constraint branch_weights {
      //We want to mirror normal operation, so we want to only branch about 20% of the time
      branch dist {
        1 := 1,
        0 := 5
      };
    }
  endclass

  class if_stage_main_test_gen extends if_stage_base_gen;

    function new(mailbox_t gen_to_drv_mbx);
      super.new("IF_STAGE_MAIN_TEST_GEN", gen_to_drv_mbx);
    endfunction

    function if_stage_trans gen_trans();
      if_stage_trans_main_test trans = new(prev_pc);

      assert(trans.randomize()) else
        $fatal("[%s] gen_trans(): randomization failed", tag);

      //update generator state and return the trans
      update_state(trans);
      return trans;
    endfunction

  endclass

  /*==============================================================================*/
  /*------------------------- BRANCH CORNERS GENERATOR ---------------------------*/
  /*==============================================================================*/
  //Generate branch_targets that only hit corner addresses

  class if_stage_trans_branch_corners extends if_stage_trans_base_constraints;
    function new(word_t prev_pc);
      super.new(prev_pc);
    endfunction

    constraint branch_weights {
      //We want to mirror normal operation, so we want to only branch about 20% of the time
      branch dist {
        1 := 1,
        0 := 5
      };
    }

    constraint branch_corners {
      branch_target inside {
        INST_MEM_FIRST_ADDR,         //first address in mem
        INST_MEM_FIRST_ADDR + 'd4,   //second address
        INST_MEM_LAST_ADDR  - 'd4,   //second to last address
        INST_MEM_LAST_ADDR           //last address
      };
    }
  endclass
  
  class if_stage_branch_corners_gen extends if_stage_base_gen;

    function new(mailbox_t gen_to_drv_mbx);
      super.new("IF_STAGE_BRANCH_CORNERS_GEN", gen_to_drv_mbx);
    endfunction

    function if_stage_trans gen_trans();
      if_stage_trans_branch_corners trans = new(prev_pc);

      assert(trans.randomize()) else
        $fatal("[%s] gen_trans(): randomization failed", tag);

      //update generator state and return the trans
      update_state(trans);
      return trans;
    endfunction

  endclass

  /*==============================================================================*/
  /*------------------------- MISALIGNED OOB GENERATOR ---------------------------*/
  /*==============================================================================*/
  //We want to test the silent handling of PC when it gets misaligned and goes
  //out-of-bound. We are also interested in what happens when both of those
  //are true at the same time (so a misaligned OOB PC).
  //
  //This generator will generate misaligned/OOB branch_targets and allow PC to
  //be incremented OOB (so we don't force a branch when PC == INST_MEM_LAST_ADDR, like
  //the other generators do).
  //
  //This generator will also keep PC concentrated around the OOB region by
  //keeping it contained in the regions [INST_MEM_FIRST_ADDR : INST_MEM_FIRST_ADDR + 5]
  //and [INST_MEM_LAST_ADDR - 5 : INST_MEM_LAST_ADDR + 5].

  class if_stage_trans_misaligned_oob extends if_stage_trans;
    word_t prev_pc;

    function new(word_t prev_pc);
      this.prev_pc = prev_pc;
    endfunction

    //disable the constraint keeping branch_targets word_aligned (see tb_if_stage_transaction_pkg)
    function void pre_randomize();
      this.word_aligned_branch_target.constraint_mode(0);
    endfunction

    constraint force_branch_to_stay_in_bounds {
      //if PC is in the range [FIRST_ADDR + 5 : LAST_ADDR - 5] then branch
      ((prev_pc >= (INST_MEM_FIRST_ADDR + 5)) && (prev_pc <= (INST_MEM_LAST_ADDR - 5))) -> (branch == 1);

      //if PC is above LAST_ADDR + 5 then branch
      (prev_pc >= INST_MEM_LAST_ADDR + 5) -> (branch == 1);
    }


    //override the legal branch_target range
    //(see tb_if_stage_transaction_pkg for the OG constraint)
    constraint legal_branch_target_range {
      branch_target dist {
        [INST_MEM_FIRST_ADDR     : INST_MEM_FIRST_ADDR + 5] :/ 1,  //stay in the lower range
        [INST_MEM_LAST_ADDR - 5  : INST_MEM_LAST_ADDR  + 5] :/ 1   //stay in the upper range

      };
    }

    constraint branch_weights {
      //We want to make sure PC has enough time to increment OOB before
      //a branch, so we only want to branch 10% of the time
      branch dist {
        1 := 1,
        0 := 10
      };
    }
  endclass

  class if_stage_oob_misaligned_gen extends if_stage_base_gen;

    function new(mailbox_t gen_to_drv_mbx);
      super.new("IF_STAGE_OOB_MISALIGNED_GEN", gen_to_drv_mbx);
    endfunction

    function if_stage_trans gen_trans();
      if_stage_trans_misaligned_oob trans = new(prev_pc);

      assert(trans.randomize()) else
        $fatal(1, "[%s]: gen_trans() randomization failed, OOB/Misaligned trans", tag);

      update_state(trans);
      return trans;
    endfunction
  endclass

endpackage
