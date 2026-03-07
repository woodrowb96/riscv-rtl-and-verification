package tb_alu_generator_pkg;
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
  import verify_const_pkg::*;
  import tb_alu_transaction_pkg::*;

  /********* NOTE  ************/
  //The classes to wrap constraints are kind of unnecessary, but it's
  //a workaround for a vivado bug
  //SEE THE NOTE IN: tb_lut_ram_generator_pkg.sv for more details
  /*****************************/

  class alu_trans_logical_ops extends alu_trans;
    constraint logical_ops {
      alu_op inside {ALU_AND, ALU_OR};
    };

    constraint logical_corner_values{
      in_a dist {
        WORD_ALL_ZEROS                     := 3,
        WORD_ALT_ONES_55                   := 3,
        WORD_ALT_ONES_AA                   := 3,
        WORD_ALL_ONES                      := 3,
        [WORD_ALL_ZEROS  : WORD_ALL_ONES]  :/ 2
      };
      in_b dist {
        WORD_ALL_ZEROS                           := 3,
        WORD_ALT_ONES_55                         := 3,
        WORD_ALT_ONES_AA                         := 3,
        WORD_ALL_ONES                            := 3,
        [WORD_ALL_ZEROS  : WORD_ALL_ONES]         :/ 2
      };
    };
  endclass

  class alu_trans_add_op extends alu_trans;
    constraint add_op {
      alu_op == ALU_ADD;
    };

    constraint add_corner_values {
      in_a dist {
        WORD_UNSIGNED_ZERO                 := 3,
        WORD_UNSIGNED_ONE                  := 3,
        WORD_MAX_UNSIGNED                  := 3,
        [WORD_ALL_ZEROS  : WORD_ALL_ONES]  :/ 2
      };
      in_b dist {
        WORD_UNSIGNED_ZERO                 := 3,
        WORD_UNSIGNED_ONE                  := 3,
        WORD_MAX_UNSIGNED                  := 3,
        [WORD_ALL_ZEROS  : WORD_ALL_ONES]  :/ 2
      };
    };
  endclass

  class alu_trans_sub_op extends alu_trans;
    constraint sub_op {
      alu_op == ALU_SUB;
    };

    constraint sub_corner_values {
      in_a dist {
        WORD_SIGNED_ZERO                   := 4,
        WORD_SIGNED_POS_ONE                := 4,
        WORD_SIGNED_NEG_ONE                := 4,
        WORD_MAX_SIGNED_POS                := 4,
        WORD_MIN_SIGNED_NEG                := 4,
        [WORD_ALL_ZEROS  : WORD_ALL_ONES]  :/ 4
      };
      in_b dist {
        WORD_SIGNED_ZERO                   := 4,
        WORD_SIGNED_POS_ONE                := 4,
        WORD_SIGNED_NEG_ONE                := 4,
        WORD_MAX_SIGNED_POS                := 4,
        WORD_MIN_SIGNED_NEG                := 4,
        [WORD_ALL_ZEROS  : WORD_ALL_ONES]  :/ 4
      };
    };
  endclass

  /**************************** GENERATOR **************************************/
  class tb_alu_generator;
    function alu_trans gen_trans();
      alu_trans trans;

      randcase
        //logical operations
        1: begin
          alu_trans_logical_ops trans_logical = new();

          assert(trans_logical.randomize()) else
            $fatal(1, "TB_ALU_GENERATOR: gen_trans() randomization failed, logical trans");

          trans = trans_logical;
        end

        //add operation
        3: begin
          alu_trans_add_op trans_add = new();

          assert(trans_add.randomize()) else
            $fatal(1, "TB_ALU_GENERATOR: gen_trans() randomization failed, add trans");

          trans = trans_add;
        end

        //sub operation
        7: begin
          alu_trans_sub_op trans_sub = new();

          assert(trans_sub.randomize()) else
            $fatal(1, "TB_ALU_GENERATOR: gen_trans() randomization failed, sub trans");

          trans = trans_sub;
        end
      endcase

      return trans;   //return the trans
    endfunction
  endclass

endpackage
