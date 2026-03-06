package tb_imm_gen_transaction_pkg;
  import rv32i_defs_pkg::*;

  class imm_gen_trans;
    //DUT input
    rand word_t inst;
    //DUT output
    word_t imm;

    constraint valid_opcodes {
      inst[6:0] inside {
        OP_REG, OP_IMM, OP_LOAD, OP_STORE, OP_BRANCH, OP_LUI, OP_AUIPC, OP_JAL, OP_JALR
      };
    };

    function bit compare(imm_gen_trans other);
      return (this.inst === other.inst && this.imm === other.imm);
    endfunction

    function void print(string msg = "");
      opcode_t opcode;
      opcode = opcode_t'(inst[6:0]);
      $display("[%s] t=%0t inst:%h, imm:%h, opcode:%s", msg, $time, inst, imm, opcode.name());
    endfunction

    /******** NOTE ********/
    //Manually using the post_rand function to randomize the msb is
    //a workaround for a bug in xsim.
    //
    //SEE: tb_lut_ram_transaction_pkg.sv NOTE for a full explination
    /***********************/
    function void post_randomize();
      randcase
        1: inst[XLEN-1] = 1'b0;
        1: inst[XLEN-1] = 1'b1;
      endcase
    endfunction
  endclass

endpackage
