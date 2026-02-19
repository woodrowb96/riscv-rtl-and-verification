package tb_alu_transaction_pkg;
  import riscv_32i_defs_pkg::*;
  import riscv_32i_control_pkg::*;

  class alu_trans;
    rand alu_op_t alu_op;
    rand bit [XLEN-1:0] in_a;
    rand bit [XLEN-1:0] in_b;

    word_t result;
    logic zero;

    function bit compare(alu_trans other);
      return (this.alu_op === other.alu_op &&
              this.in_a   === other.in_a   &&
              this.in_b   === other.in_b   &&
              this.result === other.result &&
              this.zero   === other.zero);
    endfunction

    /******** NOTE ********/
    //Manually using the post_rand function to randomize the msb is
    //a workaround for a bug in xsim.
    //
    //SEE: tb_lut_ram_transaction_pkg.sv NOTE for a full explination
    /***********************/
    function void post_randomize();
      //I exclude all the corner values from msb randomixation
      if(!(in_a inside {WORD_ALL_ZEROS, WORD_ALL_ONES,
                        WORD_ALT_ONES_55, WORD_ALT_ONES_AA,
                        WORD_UNSIGNED_ONE,
                        WORD_MAX_SIGNED_POS, WORD_MIN_SIGNED_NEG})) begin
        randcase
          1: in_a[XLEN-1] = 1'b0;
          1: in_a[XLEN-1] = 1'b1;
        endcase
      end

      if(!(in_b inside {WORD_ALL_ZEROS, WORD_ALL_ONES,
                        WORD_ALT_ONES_55, WORD_ALT_ONES_AA,
                        WORD_UNSIGNED_ONE,
                        WORD_MAX_SIGNED_POS, WORD_MIN_SIGNED_NEG})) begin
        randcase
          1: in_b[XLEN-1] = 1'b0;
          1: in_b[XLEN-1] = 1'b1;
        endcase
      end
    endfunction

    function void print(string msg = "");
      $display("[%s] t=%0t alu_op:%0b in_a:%0h in_b:%0h result:%0h zero:%0b",
               msg, $time, alu_op, in_a, in_b, result, zero);
    endfunction
  endclass
endpackage
