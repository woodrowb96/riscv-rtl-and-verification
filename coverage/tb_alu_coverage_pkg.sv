package tb_alu_coverage_pkg;
  class tb_alu_coverage;

    virtual alu_intf.coverage vif;

    //function used to determine if two inputs will overflow when added
    //in_a and in_b are treated as unsigned numbers
    function automatic bit add_overflow(logic [31:0] in_a, logic [31:0] in_b);
      //result is one bit wider that the inputs
      logic [32:0] result;

      //extend the two inputs by one bit, put a 0 in the new msb, then add
      result = {1'b0, in_a} + {1'b0, in_b};

      //if extra bit in result is set, then we have overflowed
      return result[32];
    endfunction

    //function to determin if two inputs will overflow during subtraction
    //in_a and in_b are treated as signed 2s compliment numbers
    function automatic bit sub_overflow(logic [31:0] in_a, logic [31:0] in_b);
      logic [31:0] result;

      result = in_a - in_b;

      //look at the msb to see the signs
      //we will overflow if
      //in_a and in_b are oposite signed, and result has a dif sign than in_a
      return (in_a[31] != in_b[31]) && (result[31] != in_a[31]);
    endfunction

    covergroup cg_alu;
    cov_op: coverpoint vif.alu_op {
        bins op_and = {4'b0000};
        bins op_or = {4'b0001};
        bins op_add = {4'b0010};
        bins op_sub = {4'b0110};
        bins invalid = default;
      }

      cov_zero_flag: coverpoint vif.zero{
        bins asserted = {1'b1};
        bins de_asserted = {1'b0};
      }

      //make sure we assert and deasert zero flag for all ops
      cross_op_zero_flag: cross cov_op, cov_zero_flag;


      /********** LOGICAL OPERATIONS COVERAGE ************/
      //corner cases we want to cover as inputs to logical operations
      cov_in_a_log_op: coverpoint vif.in_a
        iff (vif.alu_op inside {4'b0000,4'b0001}) {
          bins all_zero = {32'h0000_0000};
          bins alt_ones_55 = {32'h5555_5555};
          bins alt_ones_aa = {32'haaaa_aaaa};
          bins all_one = {32'hffff_ffff};
          bins non_corners = {[32'h0000_0001 : 32'h5555_5554],
                              [32'h5555_5556 : 32'haaaa_aaa9],
                              [32'haaaa_aaab : 32'hffff_fffe]};
        }
      cov_in_b_log_op: coverpoint vif.in_b
        iff (vif.alu_op inside {4'b0000,4'b0001}) {
          bins all_zero = {32'h0000_0000};
          bins alt_ones_55 = {32'h5555_5555};
          bins alt_ones_aa = {32'haaaa_aaaa};
          bins all_one = {32'hffff_ffff};
          bins non_corners = {[32'h0000_0001 : 32'h5555_5554],
                              [32'h5555_5556 : 32'haaaa_aaa9],
                              [32'haaaa_aaab : 32'hffff_fffe]};
        }

      //We want to cover all combos of corner cases for each logical op
      cross_inputs_and: cross cov_in_a_log_op, cov_in_b_log_op
        iff (vif.alu_op == 4'b0000);

      cross_inputs_or: cross cov_in_a_log_op, cov_in_b_log_op
        iff (vif.alu_op == 4'b0001);

      /********** ADD OPERATION COVERAGE ************/
      //input corner cases to ADD operations
      cov_in_a_ADD_op: coverpoint vif.in_a
        iff (vif.alu_op == 4'b0010) {
          bins zero = {32'h0000_0000};
          bins one = {32'h0000_0001};
          bins max_unsigned = {32'hffff_ffff};
          bins non_corners_low = {[32'h0000_0002 : 32'h5555_5555]};
          bins non_corners_med = {[32'h5555_5556 : 32'haaaa_aaaa]};
          bins non_corners_high = {[32'haaaa_aaab : 32'hffff_fffe]};
        }
      cov_in_b_ADD_op: coverpoint vif.in_b
        iff (vif.alu_op == 4'b0010) {
          bins zero = {32'h0000_0000};
          bins one = {32'h0000_0001};
          bins max_unsigned = {32'hffff_ffff};
          bins non_corners_low = {[32'h0000_0002 : 32'h5555_5555]};
          bins non_corners_med = {[32'h5555_5556 : 32'haaaa_aaaa]};
          bins non_corners_high = {[32'haaaa_aaab : 32'hffff_fffe]};
        }

      //we want to cover all combos of corner cases for ADD operation
      cross_inputs_ADD: cross cov_in_a_ADD_op, cov_in_b_ADD_op 
        iff (vif.alu_op == 4'b0010);

      //we want to cover overflowing and not overflowing the addition operation
      cov_ADD_overflow: coverpoint add_overflow(vif.in_a, vif.in_b) 
        iff (vif.alu_op == 4'b0010){
            bins yes = {1};
            bins no = {0};
        }


      /********** SUB OPERATION COVERAGE ************/
      //corner inputs we want to cover with the sub operation
      cov_in_a_SUB_op: coverpoint vif.in_a
        iff (vif.alu_op == 4'b0110) {
          bins zero = {32'h0000_0000};            //these numbers are signes 2s compliment
          bins signed_pos_one = {32'h0000_0001};
          bins signed_neg_one = {32'hffff_ffff};
          bins max_signed_pos = {32'h7fff_ffff};
          bins min_signed_neg = {32'h8000_0000};
          bins non_corners_low_pos = {[32'h0000_0002 : 32'h3fff_ffff]};
          bins non_corners_high_pos = {[32'h4000_0000 : 32'h7fff_fffe]};
          bins non_corners_low_neg = {[32'h8000_0001 : 32'hbfff_ffff]};
          bins non_corners_high_neg = {[32'hc000_0000 : 32'hffff_fffe]};
        }
      cov_in_b_SUB_op: coverpoint vif.in_b
        iff (vif.alu_op == 4'b0110) {
          bins zero = {32'h0000_0000};            //these numbers are signes 2s compliment
          bins signed_pos_one = {32'h0000_0001};
          bins signed_neg_one = {32'hffff_ffff};
          bins max_signed_pos = {32'h7fff_ffff};
          bins min_signed_neg = {32'h8000_0000};
          bins non_corners_low_pos = {[32'h0000_0002 : 32'h3fff_ffff]};
          bins non_corners_high_pos = {[32'h4000_0000 : 32'h7fff_fffe]};
          bins non_corners_low_neg = {[32'h8000_0001 : 32'hbfff_ffff]};
          bins non_corners_high_neg = {[32'hc000_0000 : 32'hffff_fffe]};
        }

      //cross the corners for the sub operation
      cross_inputs_SUB: cross cov_in_a_SUB_op, cov_in_b_SUB_op
        iff (vif.alu_op == 4'b0110);

      //we want to cover overflowing during sub operations
      cov_SUB_overflow: coverpoint sub_overflow(vif.in_a, vif.in_b)
        iff (vif.alu_op == 4'b0110){
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
