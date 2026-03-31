package if_stage_ref_model_pkg;
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import inst_mem_ref_model_pkg::*;
  import tb_if_stage_transaction_pkg::*;

  class if_stage_ref_model;

    string tag = "IF_STAGE_REF_MODEL";

    inst_mem_ref_model ref_inst_mem; //reuse the instruction mems reference model
    word_t pc;

    function new(string program_file = "");
      ref_inst_mem = new(program_file);  //the ref_model will load the program into its ref memory
      this.reset();
    endfunction

    function void reset();
      pc = PC_RESET;
    endfunction

    function word_t fetch_inst();
      return ref_inst_mem.read(pc); //The ref_inst_mem will print warnings for misaligned and OOB memory accesses
    endfunction

    function void update(if_stage_trans trans);
      case(trans.branch)
        0: begin
        //Dont take branch
          pc = pc + 'd4;
        end
        1: begin
        //take the branch
          if(trans.branch_target[1:0] != 2'b00) begin
            $warning("[%s]: misaligned branch_target: branch_target:%0d",
              tag, trans.branch_target);
          end

          if(trans.branch_target >= (INST_MEM_DEPTH * 4)) begin
            $warning("[%s]: out of bounds branch_target: branch_target:%0d",
              tag, trans.branch_target);
          end

          pc = trans.branch_target;
        end
        default: begin
        //invalid branch
        //this is undefined behavior in the rtl, so set pc to x's and print an error
          pc = 'x;
          $error("[%s]: invalid branch, branch:%b", tag, trans.branch);
        end
      endcase
    endfunction

  endclass

endpackage
