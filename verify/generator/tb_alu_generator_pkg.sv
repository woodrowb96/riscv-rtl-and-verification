package tb_alu_generator_pkg;
  import base_generator_pkg::*;
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
        WORD_ALL_ZEROS                     := 3,
        WORD_ALT_ONES_55                   := 3,
        WORD_ALT_ONES_AA                   := 3,
        WORD_ALL_ONES                      := 3,
        [WORD_ALL_ZEROS  : WORD_ALL_ONES]  :/ 2
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

  class alu_trans_invalid_op extends alu_trans;
    rand logic [$bits(alu_op)-1:0] invalid_op;

    constraint invalid_alu_op {
      !(invalid_op inside {ALU_AND, ALU_OR, ALU_ADD, ALU_SUB});
    }

    function void post_randomize();
      super.post_randomize();
      alu_op = alu_op_t'(invalid_op);
    endfunction
  endclass

  /*==============================================================================*/
  /*------------------------------ GENERATOR -------------------------------------*/
  /*==============================================================================*/

  class alu_default_gen extends base_generator #(alu_trans);

    function new(mailbox_t gen_to_drv_mbx);
      super.new("ALU_DEFAULT_GEN", gen_to_drv_mbx);
    endfunction

    task run();
      alu_trans trans;

      randcase
        //logical operations
        1: begin
          alu_trans_logical_ops trans_logical = new();

          assert(trans_logical.randomize()) else
            $fatal(1, "[%s]: randomization failed, logical trans", tag);

          trans = trans_logical;
        end

        //add operation
        3: begin
          alu_trans_add_op trans_add = new();

          assert(trans_add.randomize()) else
            $fatal(1, "[%s]: randomization failed, add trans", tag);

          trans = trans_add;
        end

        //sub operation
        3: begin
          alu_trans_sub_op trans_sub = new();

          assert(trans_sub.randomize()) else
            $fatal(1, "[%s]: randomization failed, sub trans", tag);

          trans = trans_sub;
        end
      endcase

      gen_to_drv_mbx.put(trans);
    endtask

  endclass

  /*==============================================================================*/
  /*--------------------------- ADD_CORNERS_GENERATOR ----------------------------*/
  /*==============================================================================*/

  class alu_add_corner_walk_gen extends base_generator #(alu_trans);
    word_t corners[] = '{
      WORD_UNSIGNED_ZERO,
      WORD_UNSIGNED_ONE,
      WORD_MAX_UNSIGNED,
      unsigned_urandom_range(WORD_UNSIGNED_ZERO + 1,       UNSIGNED_LOWER_THIRD),
      unsigned_urandom_range(UNSIGNED_LOWER_THIRD + 1,   UNSIGNED_LOWER_TWO_THIRD),
      unsigned_urandom_range(UNSIGNED_LOWER_TWO_THIRD + 1, WORD_MAX_UNSIGNED - 1)
    };
    int i = 0;
    int j = 0;

    function new(mailbox_t gen_to_drv_mbx);
      super.new("ALU_ADD_CORNER_WALK_GEN", gen_to_drv_mbx);
    endfunction

    task run();
      alu_trans trans = new();

      //if we have walked through all corner combos set finished
      if (i >= corners.size()) begin
        finished = 1;
        i = corners.size() - 1;
        j = corners.size() - 1;
      end

      //build the trans
      trans.alu_op = ALU_ADD;
      trans.in_a   = corners[i];
      trans.in_b   = corners[j];

      //iterate through the double loop
      j++;
      if (j >= corners.size()) begin
        j = 0;
        i++;
      end

      gen_to_drv_mbx.put(trans);
    endtask

  endclass

  /*==============================================================================*/
  /*--------------------------- SUB_CORNERS_GENERATOR ----------------------------*/
  /*==============================================================================*/

  class alu_sub_corner_walk_gen extends base_generator #(alu_trans);
    word_t corners[] = '{
      WORD_SIGNED_ZERO,
      WORD_SIGNED_POS_ONE,
      WORD_SIGNED_NEG_ONE,
      WORD_MAX_SIGNED_POS,
      WORD_MIN_SIGNED_NEG,
      $urandom_range(WORD_SIGNED_POS_ONE   + 1, SIGNED_POS_LOWER_HALF),
      $urandom_range(SIGNED_POS_LOWER_HALF + 1, WORD_MAX_SIGNED_POS   - 1),
      $urandom_range(SIGNED_NEG_LOWER_HALF,     WORD_SIGNED_NEG_ONE   - 1),
      $urandom_range(WORD_MIN_SIGNED_NEG   + 1, SIGNED_NEG_LOWER_HALF - 1)
    };
    int i = 0;
    int j = 0;

    function new(mailbox_t gen_to_drv_mbx);
      super.new("ALU_SUB_CORNER_WALK_GEN", gen_to_drv_mbx);
    endfunction

    task run();
      alu_trans trans = new();

      //if we have walked through all corner combos set finished
      if (i >= corners.size()) begin
        finished = 1;
        i = corners.size() - 1;
        j = corners.size() - 1;
      end

      //build the trans
      trans.alu_op = ALU_SUB;
      trans.in_a   = corners[i];
      trans.in_b   = corners[j];

      //iterate through the double loop
      j++;
      if (j >= corners.size()) begin
        j = 0;
        i++;
      end

      gen_to_drv_mbx.put(trans);
    endtask

  endclass

  /*==============================================================================*/
  /*--------------------------- INVALID_OP_GENERATOR ----------------------------*/
  /*==============================================================================*/

  class alu_invalid_op_gen extends base_generator #(alu_trans);

    function new(mailbox_t gen_to_drv_mbx);
      super.new("ALU_INVALID_OP_GEN", gen_to_drv_mbx);
    endfunction

    task run();
      alu_trans_invalid_op trans_invalid = new();

      assert(trans_invalid.randomize()) else
        $fatal(1, "[%s]: randomization failed", tag);

      gen_to_drv_mbx.put(trans_invalid);
    endtask

  endclass

endpackage
