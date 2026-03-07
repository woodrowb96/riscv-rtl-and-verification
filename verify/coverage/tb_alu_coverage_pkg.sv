package tb_alu_coverage_pkg;
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
  import verify_const_pkg::*;

  class tb_alu_coverage;

    virtual alu_intf.coverage vif;

    /**********************************************************************************/
    /*************************** COVERAGE HELPER FUNCTIONS ****************************/
    /**********************************************************************************/
    function automatic bit detect_add_overflow(word_t in_a, word_t in_b);
      //Treating in_a and in_b as unsigned 32 bit nums,
      //compute a wide result, check if the wide msb is set
      logic [XLEN:0] result_wide = {1'b0, in_a} + {1'b0, in_b};
      return result_wide[XLEN];
    endfunction

    function automatic bit detect_sub_overflow(word_t in_a, word_t in_b);
      word_t result = in_a - in_b;    //treating both numbers as signed 2s complement
      //An overflow happens when:
      //  - in_a and in_b are opposite signs
      //    AND result has a diff sign than in_a
      return (in_a[XLEN-1] != in_b[XLEN-1]) && (result[XLEN-1] != in_a[XLEN-1]);
    endfunction

    /**********************************************************************************/
    /******************************* COVERAGE *****************************************/
    /**********************************************************************************/

    //to help split the unsigned values up into  lower, middle and upper thirds in coverage
    localparam int unsigned UNSIGNED_LOWER_THIRD     = WORD_MAX_UNSIGNED / 3;
    localparam int unsigned UNSIGNED_LOWER_TWO_THIRD = (WORD_MAX_UNSIGNED / 3) * 2;
    //to help split the signed values up into high and low pos and neg 4ths in coverage
    localparam int SIGNED_POS_LOWER_HALF = WORD_MAX_SIGNED_POS / 2;
    localparam int SIGNED_NEG_LOWER_HALF = 32'hC000_0000;

    covergroup cg;
      /********************** ALU_OP COVERAGE ******************/

      alu_op: coverpoint vif.alu_op {
        bins op_and = {ALU_AND};
        bins op_or  = {ALU_OR};
        bins op_add = {ALU_ADD};
        bins op_sub = {ALU_SUB};
        bins invalid = default;
      }


      /***************** ZERO FLAG  COVERAGE *******************/
      zero_flag: coverpoint vif.zero{
        bins set   = {1'b1};
        bins unset = {1'b0};
      }

      //we want zeros and non_zeros with each op
      alu_op_x_zero_flag: cross alu_op, zero_flag;


      /*************** LOGICAL OPERATIONS COVERAGE *************/

      //we want to hit the following corners
      in_a_log_op: coverpoint vif.in_a
        iff (vif.alu_op inside {ALU_AND, ALU_OR}) {
          bins all_zero    = {WORD_ALL_ZEROS};
          bins alt_ones_55 = {WORD_ALT_ONES_55};
          bins alt_ones_aa = {WORD_ALT_ONES_AA};
          bins all_one     = {WORD_ALL_ONES};
          bins non_corners = default;
      }
      in_b_log_op: coverpoint vif.in_b
        iff (vif.alu_op inside {ALU_AND, ALU_OR}) {
          bins all_zero    = {WORD_ALL_ZEROS};
          bins alt_ones_55 = {WORD_ALT_ONES_55};
          bins alt_ones_aa = {WORD_ALT_ONES_AA};
          bins all_one     = {WORD_ALL_ONES};
          bins non_corners = default;
      }

      //We want to cover all combos of corner cases for each logical op
      in_a_x_in_b_and: cross in_a_log_op, in_b_log_op
        iff (vif.alu_op == ALU_AND);
      in_a_x_in_b_or: cross in_a_log_op, in_b_log_op
        iff (vif.alu_op == ALU_OR);


      /******************** ADD OPERATION COVERAGE **********************/

      //we want to hit the following corners values/ranges for both inputs
      in_a_add_op: coverpoint vif.in_a
        iff (vif.alu_op == ALU_ADD) {
          bins zero             = {WORD_UNSIGNED_ZERO};
          bins one              = {WORD_UNSIGNED_ONE};
          bins max_unsigned     = {WORD_MAX_UNSIGNED};
          bins non_corners_low  = {[WORD_UNSIGNED_ZERO + 1       : UNSIGNED_LOWER_THIRD]};
          bins non_corners_med  = {[UNSIGNED_LOWER_THIRD + 1     : UNSIGNED_LOWER_TWO_THIRD]};
          bins non_corners_high = {[UNSIGNED_LOWER_TWO_THIRD + 1 : WORD_MAX_UNSIGNED - 1]};
        }
      in_b_add_op: coverpoint vif.in_b
        iff (vif.alu_op == ALU_ADD) {
          bins zero             = {WORD_UNSIGNED_ZERO};
          bins one              = {WORD_UNSIGNED_ONE};
          bins max_unsigned     = {WORD_MAX_UNSIGNED};
          bins non_corners_low  = {[WORD_UNSIGNED_ZERO + 1       : UNSIGNED_LOWER_THIRD]};
          bins non_corners_med  = {[UNSIGNED_LOWER_THIRD + 1     : UNSIGNED_LOWER_TWO_THIRD]};
          bins non_corners_high = {[UNSIGNED_LOWER_TWO_THIRD + 1 : WORD_MAX_UNSIGNED - 1]};
        }

      //we want to cover all combos of corners
      in_a_x_in_b_add: cross in_a_add_op, in_b_add_op
        iff (vif.alu_op == ALU_ADD);

      //we want to cover both overflowing and not overflowing during an add_op
      add_overflow: coverpoint detect_add_overflow(vif.in_a, vif.in_b) 
        iff (vif.alu_op == ALU_ADD){
            bins yes = {1};
            bins no = {0};
        }


      /******************** SUB OPERATION COVERAGE ***********************/

      //we want to hit the following corners values/ranges for both inputs
      //  NOTE: we are treating the values as signed 2s complement numbers
      in_a_sub_op: coverpoint $signed(vif.in_a)
        iff (vif.alu_op == ALU_SUB) {
          bins zero                 = {WORD_SIGNED_ZERO};
          bins signed_pos_one       = {WORD_SIGNED_POS_ONE};
          bins signed_neg_one       = {WORD_SIGNED_NEG_ONE};
          bins max_signed_pos       = {WORD_MAX_SIGNED_POS};
          bins min_signed_neg       = {WORD_MIN_SIGNED_NEG};
          bins non_corners_low_pos  = {[WORD_SIGNED_POS_ONE   + 1 : SIGNED_POS_LOWER_HALF]};
          bins non_corners_high_pos = {[SIGNED_POS_LOWER_HALF + 1 : WORD_MAX_SIGNED_POS   - 1]};
          bins non_corners_high_neg = {[SIGNED_NEG_LOWER_HALF     : WORD_SIGNED_NEG_ONE   - 1]};
          bins non_corners_low_neg  = {[WORD_MIN_SIGNED_NEG   + 1 : SIGNED_NEG_LOWER_HALF - 1]};
        }
      in_b_sub_op: coverpoint $signed(vif.in_b)
        iff (vif.alu_op == ALU_SUB) {
          bins zero                 = {WORD_SIGNED_ZERO};
          bins signed_pos_one       = {WORD_SIGNED_POS_ONE};
          bins signed_neg_one       = {WORD_SIGNED_NEG_ONE};
          bins max_signed_pos       = {WORD_MAX_SIGNED_POS};
          bins min_signed_neg       = {WORD_MIN_SIGNED_NEG};
          bins non_corners_low_pos  = {[WORD_SIGNED_POS_ONE   + 1 : SIGNED_POS_LOWER_HALF]};
          bins non_corners_high_pos = {[SIGNED_POS_LOWER_HALF + 1 : WORD_MAX_SIGNED_POS   - 1]};
          bins non_corners_high_neg = {[SIGNED_NEG_LOWER_HALF     : WORD_SIGNED_NEG_ONE   - 1]};
          bins non_corners_low_neg  = {[WORD_MIN_SIGNED_NEG   + 1 : SIGNED_NEG_LOWER_HALF - 1]};
        }

      in_a_x_in_b_sub: cross in_a_sub_op, in_b_sub_op
        iff (vif.alu_op == ALU_SUB);

      sub_overflow: coverpoint detect_sub_overflow(vif.in_a, vif.in_b)
        iff (vif.alu_op == ALU_SUB){
            bins yes = {1};
            bins no = {0};
        }
    endgroup

    function void sample();
      cg.sample();
    endfunction

    function new(virtual alu_intf.coverage vif);
      this.vif = vif;
      this.cg = new();
    endfunction
  endclass

endpackage
