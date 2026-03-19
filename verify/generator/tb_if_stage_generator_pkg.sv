package tb_if_stage_generator_pkg;
  import tb_if_stage_transaction_pkg::*;
  import base_generator_pkg::*;
  import rv32i_config_pkg::*;
  import rv32i_defs_pkg::*;
  import verify_const_pkg::*;

  //NOTE: Using the classes to hold all the constraints is partially
  //a workaround for a bug in Vivado.
  //SEE THE NOTE IN: tb_lut_ram_generator_pkg.sv for full details

  class if_stage_trans_base_constraints extends if_stage_trans;
    word_t prev_pc;

    function new(word_t prev_pc);
      this.prev_pc = prev_pc;
    endfunction

    //If the previous PC is pointing to the last address in memory, then force a branch
    //to stay in bounds (so pc_next = pc + 4 doesnt take us out of bounds)
    constraint force_branch_to_stay_in_bound {
      (prev_pc == INST_MEM_LAST_ADDR) -> (branch == 1);
    };
  endclass

  class if_stage_trans_branch_target_corners extends if_stage_trans_base_constraints;
    function new(word_t prev_pc);
      super.new(prev_pc);
    endfunction

    constraint branch_corners {
      branch == 1; //force a branch

      branch_target inside {
        INST_MEM_FIRST_ADDR,         //fist address in mem
        INST_MEM_FIRST_ADDR + 'd4,   //second address
        INST_MEM_LAST_ADDR  - 'd4,   //second to last address
        INST_MEM_LAST_ADDR           //last address
      };
    }
  endclass


  /*==============================================================================*/
  /*------------------------- BASE GENERATOR -------------------------------------*/
  /*==============================================================================*/

  //a base generator to hold the state logic all the other gens can use
  virtual class if_stage_base_gen extends base_generator #(if_stage_trans);
    word_t prev_pc; //the previously pc from the last generated transaction

    function new(string tag, mailbox_t gen_to_drv_mbx);
      super.new(tag, gen_to_drv_mbx);
      this.reset_state();
    endfunction

    function void reset_state();
      prev_pc = PC_RESET;
    endfunction

    function update_state(if_stage_trans trans);
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
  /*------------------------- DEFAULT GENERATOR ----------------------------------*/
  /*==============================================================================*/

  class if_stage_default_gen extends if_stage_base_gen;

    function new(mailbox_t gen_to_drv_mbx);
      super.new("IF_STAGE_DEFAULT_GEN", gen_to_drv_mbx);
    endfunction

    function if_stage_trans gen_trans();
    //randomly choose a transaction that is:
    //  - fully random (with only base constraints to stay in range)
    //  - forcing a branch to a random corner branch_target
      if_stage_trans trans;

      randcase
        //fully random
        1: begin
          if_stage_trans_base_constraints trans_full_random = new(prev_pc);

          assert(trans_full_random.randomize()) else
            $fatal(1, "[%s]: gen_trans() randomization failed, full_random trans", tag);

          trans = trans_full_random;
        end

        //branch_target corners
        1: begin
          if_stage_trans_branch_target_corners trans_b_t_corners = new(prev_pc);

          assert(trans_b_t_corners.randomize()) else
            $fatal(1, "[%s]: gen_trans() randomization failed, branch_target_corners", tag);

          trans = trans_b_t_corners;
        end
      endcase

      //update generator state and return the trans
      update_state(trans);
      return trans;
    endfunction

  endclass

endpackage
