package tb_alu_coverage_pkg;
  import riscv_32i_defs_pkg::*;
  class tb_alu_coverage;

    virtual alu_intf.coverage vif;

    //function used to determine if two inputs will overflow when added
    //in_a and in_b are treated as unsigned numbers
    function automatic bit add_overflow(word_t in_a, word_t in_b);
      //result is one bit wider that the inputs
      logic [XLEN:0] result;

      //extend the two inputs by one bit, put a 0 in the new msb, then add
      result = {1'b0, in_a} + {1'b0, in_b};

      //if extra bit in result is set, then we have overflowed
      return result[XLEN];
    endfunction

    //function to determine if two inputs will overflow during subtraction
    //in_a and in_b are treated as signed 2s complement numbers
    function automatic bit sub_overflow(word_t in_a, word_t in_b);
      word_t result;

      result = in_a - in_b;

      //look at the msb to see the signs
      //we will overflow if
      //in_a and in_b are opposite signed, and result has a dif sign than in_a
      return (in_a[XLEN-1] != in_b[XLEN-1]) && (result[XLEN-1] != in_a[XLEN-1]);
    endfunction

    //some params, so we can split the unsigned values up into 
    //lower, middle and upper thirds in the add coverage
    localparam word_t UNSIGNED_LOWER_THIRD     = WORD_MAX_UNSIGNED / 3;
    localparam word_t UNSIGNED_LOWER_TWO_THIRD = (WORD_MAX_UNSIGNED / 3) * 2;

    //some params, so we can split the signed values up in the sub coverage
    //we want the pos and neg nums to be split in half
    localparam word_t SIGNED_POS_LOWER_HALF = WORD_MAX_SIGNED_POS / 2;
    localparam word_t SIGNED_NEG_LOWER_HALF = 32'hC000_0000;

    covergroup cg_alu;
      cov_op: coverpoint vif.alu_op {
        bins op_and = {ALU_AND};
        bins op_or = {ALU_OR};
        bins op_add = {ALU_ADD};
        bins op_sub = {ALU_SUB};
        bins invalid = default;
      }

      cov_zero_flag: coverpoint vif.zero{
        bins asserted = {1'b1};
        bins de_asserted = {1'b0};
      }

      //make sure we assert and deassert zero flag for all ops
      cross_op_zero_flag: cross cov_op, cov_zero_flag;


      /********** LOGICAL OPERATIONS COVERAGE ************/
      //corner cases we want to cover as inputs to logical operations
      cov_in_a_log_op: coverpoint vif.in_a
        iff (vif.alu_op inside {ALU_AND, ALU_OR}) {
          bins all_zero    = {WORD_ALL_ZEROS};
          bins alt_ones_55 = {WORD_ALT_ONES_55};
          bins alt_ones_aa = {WORD_ALT_ONES_AA};
          bins all_one     = {WORD_ALL_ONES};
          bins non_corners = {[WORD_ALL_ZEROS + 1   : WORD_ALT_ONES_55 - 1],
                              [WORD_ALT_ONES_55 + 1 : WORD_ALT_ONES_AA - 1],
                              [WORD_ALT_ONES_AA + 1 : WORD_ALL_ONES - 1]};
        }
      cov_in_b_log_op: coverpoint vif.in_b
        iff (vif.alu_op inside {ALU_AND, ALU_OR}) {
          bins all_zero    = {WORD_ALL_ZEROS};
          bins alt_ones_55 = {WORD_ALT_ONES_55};
          bins alt_ones_aa = {WORD_ALT_ONES_AA};
          bins all_one     = {WORD_ALL_ONES};
          bins non_corners = {[WORD_ALL_ZEROS + 1   : WORD_ALT_ONES_55 - 1],
                              [WORD_ALT_ONES_55 + 1 : WORD_ALT_ONES_AA - 1],
                              [WORD_ALT_ONES_AA + 1 : WORD_ALL_ONES - 1]};
        }

      //We want to cover all combos of corner cases for each logical op
      cross_inputs_and: cross cov_in_a_log_op, cov_in_b_log_op
        iff (vif.alu_op == ALU_AND);

      cross_inputs_or: cross cov_in_a_log_op, cov_in_b_log_op
        iff (vif.alu_op == ALU_OR);

      /********** ADD OPERATION COVERAGE ************/
      //input corner cases to ADD operations
      cov_in_a_ADD_op: coverpoint vif.in_a
        iff (vif.alu_op == ALU_ADD) {
          bins zero             = {WORD_UNSIGNED_ZERO};
          bins one              = {WORD_UNSIGNED_ONE};
          bins max_unsigned     = {WORD_MAX_UNSIGNED};
          //We split the range into 3rds, so we cover a good range of
          //different numbers
          bins non_corners_low  = {[WORD_UNSIGNED_ZERO + 1       : UNSIGNED_LOWER_THIRD]};
          bins non_corners_med  = {[UNSIGNED_LOWER_THIRD + 1     : UNSIGNED_LOWER_TWO_THIRD]};
          bins non_corners_high = {[UNSIGNED_LOWER_TWO_THIRD + 1 : WORD_MAX_UNSIGNED - 1]};
        }
      cov_in_b_ADD_op: coverpoint vif.in_b
        iff (vif.alu_op == ALU_ADD) {
          bins zero             = {WORD_UNSIGNED_ZERO};
          bins one              = {WORD_UNSIGNED_ONE};
          bins max_unsigned     = {WORD_MAX_UNSIGNED};
          //We split the range into 3rds, so we cover a good range of
          //different numbers
          bins non_corners_low  = {[WORD_UNSIGNED_ZERO + 1       : UNSIGNED_LOWER_THIRD]};
          bins non_corners_med  = {[UNSIGNED_LOWER_THIRD + 1     : UNSIGNED_LOWER_TWO_THIRD]};
          bins non_corners_high = {[UNSIGNED_LOWER_TWO_THIRD + 1 : WORD_MAX_UNSIGNED - 1]};
        }

      //we want to cover all combos of corner cases for ADD operation
      cross_inputs_ADD: cross cov_in_a_ADD_op, cov_in_b_ADD_op 
        iff (vif.alu_op == ALU_ADD);

      //we want to cover overflowing and not overflowing the addition operation
      cov_ADD_overflow: coverpoint add_overflow(vif.in_a, vif.in_b) 
        iff (vif.alu_op == ALU_ADD){
            bins yes = {1};
            bins no = {0};
        }


      /********** SUB OPERATION COVERAGE ************/
      //corner inputs we want to cover with the sub operation
      cov_in_a_SUB_op: coverpoint vif.in_a
        iff (vif.alu_op == ALU_SUB) {
          //these numbers are all signed 2s complements
          bins zero                 = {WORD_SIGNED_ZERO};
          bins signed_pos_one       = {WORD_SIGNED_POS_ONE};
          bins signed_neg_one       = {WORD_SIGNED_NEG_ONE};
          bins max_signed_pos       = {WORD_MAX_SIGNED_POS};
          bins min_signed_neg       = {WORD_MIN_SIGNED_NEG};
          //We split the negatives and positives into halfs, so we cover large
          //and small positive and negative numbers
          bins non_corners_low_pos  = {[WORD_SIGNED_POS_ONE + 1   : SIGNED_POS_LOWER_HALF]};
          bins non_corners_high_pos = {[SIGNED_POS_LOWER_HALF + 1 : WORD_MAX_SIGNED_POS - 1]};
          bins non_corners_high_neg = {[SIGNED_NEG_LOWER_HALF     : WORD_SIGNED_NEG_ONE - 1]};
          bins non_corners_low_neg  = {[WORD_MIN_SIGNED_NEG + 1   : SIGNED_NEG_LOWER_HALF - 1]};
        }
      cov_in_b_SUB_op: coverpoint vif.in_b
        iff (vif.alu_op == ALU_SUB) {
          //these numbers are all signed 2s complements
          bins zero                 = {WORD_SIGNED_ZERO};
          bins signed_pos_one       = {WORD_SIGNED_POS_ONE};
          bins signed_neg_one       = {WORD_SIGNED_NEG_ONE};
          bins max_signed_pos       = {WORD_MAX_SIGNED_POS};
          bins min_signed_neg       = {WORD_MIN_SIGNED_NEG};
          //We split the negatives and positives into halfs, so we cover large
          //and small positive and negative numbers
          bins non_corners_low_pos  = {[WORD_SIGNED_POS_ONE + 1   : SIGNED_POS_LOWER_HALF]};
          bins non_corners_high_pos = {[SIGNED_POS_LOWER_HALF + 1 : WORD_MAX_SIGNED_POS - 1]};
          bins non_corners_high_neg = {[SIGNED_NEG_LOWER_HALF     : WORD_SIGNED_NEG_ONE - 1]};
          bins non_corners_low_neg  = {[WORD_MIN_SIGNED_NEG + 1   : SIGNED_NEG_LOWER_HALF - 1]};
        }

      //cross the corners for the sub operation
      cross_inputs_SUB: cross cov_in_a_SUB_op, cov_in_b_SUB_op
        iff (vif.alu_op == ALU_SUB);

      //we want to cover overflowing during sub operations
      cov_SUB_overflow: coverpoint sub_overflow(vif.in_a, vif.in_b)
        iff (vif.alu_op == ALU_SUB){
            bins yes = {1};
            bins no = {0};
        }
    endgroup

    function new(virtual alu_intf.coverage vif);
      this.vif = vif;
      this.cg_alu = new();
    endfunction

    function void sample();
      cg_alu.sample();
    endfunction
  endclass
endpackage
