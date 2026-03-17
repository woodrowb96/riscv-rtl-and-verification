package tb_if_stage_transaction_pkg;
  import base_transaction_pkg::*;
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;

  class if_stage_trans extends base_transaction;
    //control
    rand logic branch;
    //input
    rand word_t branch_target;
    //output
    word_t pc;
    word_t inst;

    constraint word_aligned_branch_target {
      branch_target[1:0] == 2'b00;
    }
    constraint legal_branch_target_range {
      branch_target inside { [INST_MEM_FIRST_ADDR : INST_MEM_LAST_ADDR] };
    }

    function bit compare(if_stage_trans other);
      return (this.branch        === other.branch        &&
              this.branch_target === other.branch_target &&
              this.pc            === other.pc            &&
              this.inst          === other.inst);
    endfunction

    function void print(string msg = "");
      $display("[%s] t=%0t branch:%b branch_target:%0d pc:%0d inst:%h",
               msg, $time, branch, branch_target, pc, inst);
    endfunction

    function void post_randomize();
      //not sure if ill need to post_rand to branch target MSB yet
    endfunction
  endclass

endpackage
