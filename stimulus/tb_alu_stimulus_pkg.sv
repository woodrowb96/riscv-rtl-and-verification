package tb_alu_stimulus_pkg;
  import riscv_32i_defs_pkg::*;

  //base transaction class
  class alu_general_trans;
    //output to DUT
    rand alu_op_t alu_op;
    rand bit [XLEN-1:0] in_a;
    rand bit [XLEN-1:0] in_b;

    //input from DUT
    word_t result;
    logic zero;

    /******* NOTE **********/
    //I am using the post_randomize function to manually randomize the MSB in
    //the inputs.
    //
    //I am doing this because of a possible bug in the free version of xsim.
    //When I try and use dist to get corners and non corners like this:
    //
    // in_a dist {
    //   WORD_ALL_ZEROS                          := 3,
    //   WORD_ALT_ONES_55                        := 3,
    //   WORD_ALT_ONES_AA                        := 3,
    //   WORD_ALL_ONES                           := 3,
    //   [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1] :/ 2  //MSB DOESNT GET RANDOMIZED
    // };
    //
    //The constraint solver never sets the MSB when it chooses a value in the
    //range. Bits [30:0] are fully randomized, but the MSB is never set.
    //
    //This is either a bug in this version of xsim, or I am misunderstanding
    //how constraints work. Im still learning so it could be either, but
    //I think it might just be a bug because I think the above dist should work.
    /***********************/
    function void post_randomize();
    //During post_rand manually randomize the MSB in both inputs
    //I only want to do this when the input is not one of the corners
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
      $display("-----------------------");
      $display("ALU TRANS:%s\n",msg);
      $display("time: %t", $time);
      $display("-----------------------");
      $display("alu_op: %b", alu_op);
      $display("-----------------------");
      $display("in_a: %h", in_a);
      $display("in_b: %h", in_b);
      $display("-----------------------");
      $display("result: %h", result);
      $display("zero: %b", zero);
      $display("-----------------------");
    endfunction
  endclass

  //transaction for logical operations (and, or ...)
  class alu_logical_op_trans extends alu_general_trans;
    constraint logical_op_inputs {
      /******* NOTE **********/
      //I think this might be another case of a bug in xsim.
      //
      //In my range I set the ranges from ['0 + 1 to '1 - 1] (so I carve out the all 1s and all 0s cases)
      //
      // in_a dist {
      //   WORD_ALL_ZEROS                          := 3,
      //   WORD_ALT_ONES_55                        := 3,
      //   WORD_ALT_ONES_AA                        := 3,
      //   WORD_ALL_ONES                           := 3,
      //   [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1] :/ 2  //I carve out all zeros and all 1s
      // };
      //
      //I do this because when the range overlapped with those values, the
      //constraint solver only used the value 32'd1 when it selected a value
      //from the range.
      //
      //I think it might be because the range is so large and the overlaps
      //were causing issues. Maybe its too much for the solver to handle?
      //But then why dont I have to carve out the AA and 55 corners?
      //
      //I dont know it might have something to do with when the solver tries
      //to handle the extreme corners of this big range (so the range ending
      //points), and it just picks the easiest solution, which is 32'd1? maybe?
      //
      //Once again, this is either a bug in this version of xsim, or I am misunderstanding
      //how constraints work. Im still learning so it could be either, but
      //I think it might just be a bug.
      /***********************/
      in_a dist {
        WORD_ALL_ZEROS                            := 3,
        WORD_ALT_ONES_55                          := 3, //the pattern 4'h5 = 0101 repeated
        WORD_ALT_ONES_AA                          := 3, //the pattern 4'hA = 1010 repeated
        WORD_ALL_ONES                             := 3,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
      in_b dist {
        WORD_ALL_ZEROS                            := 3,
        WORD_ALT_ONES_55                          := 3, //the pattern 4'h5 = 0101 repeated
        WORD_ALT_ONES_AA                          := 3, //the pattern 4'hA = 1010 repeated
        WORD_ALL_ONES                             := 3,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
    }
  endclass

  //transaction for ADD ops
  class alu_add_op_trans extends alu_general_trans;
    constraint add_op { alu_op == ALU_ADD; }

    constraint add_op_inputs {
      in_a dist {
        WORD_UNSIGNED_ZERO                        := 3,
        WORD_UNSIGNED_ONE                         := 3,
        WORD_MAX_UNSIGNED                         := 3,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
      in_b dist {
        WORD_UNSIGNED_ZERO                        := 3,
        WORD_UNSIGNED_ONE                         := 3,
        WORD_MAX_UNSIGNED                         := 3,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
    }
  endclass

  //transaction for SUB ops
  class alu_sub_op_trans extends alu_general_trans;
    constraint sub_op { alu_op == ALU_SUB; }

    constraint sub_op_inputs {
      in_a dist {
        WORD_SIGNED_ZERO                          := 4,
        WORD_SIGNED_POS_ONE                       := 4,
        WORD_SIGNED_NEG_ONE                       := 4,
        WORD_MAX_SIGNED_POS                       := 4,
        WORD_MIN_SIGNED_NEG                       := 4,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
      in_b dist {
        WORD_SIGNED_ZERO                          := 4,
        WORD_SIGNED_POS_ONE                       := 4,
        WORD_SIGNED_NEG_ONE                       := 4,
        WORD_MAX_SIGNED_POS                       := 4,
        WORD_MIN_SIGNED_NEG                       := 4,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
    }
  endclass
endpackage
