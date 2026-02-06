package tb_alu_stimulus_pkg;
  //enum used to include or exclude invalid alu_ops from randomization
  typedef enum {TRUE, FALSE} include_invalid_ops;

  //base transaction class
  //alu_op is randomized inside the valid ops, unless we include invalid ops
  //in_a and in_b out randomized inside the full 32bit range
  class general_trans;
    //output to DUT
    rand logic [3:0] alu_op;
    rand logic [31:0] in_a;
    rand logic [31:0] in_b;

    //input from DUT
    logic [31:0] result;
    logic zero;

    //by default dont include invalid ops in randomization
    include_invalid_ops inc_inv_ops = FALSE;
    constraint valid_ops {
      (inc_inv_ops == FALSE) -> (alu_op inside {4'b0000, 4'b0001, 4'b0010, 4'b0110});
    }

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

  //enum to switch how we randomize the inputs
  typedef enum {CORNERS_ONLY, //input constrained to corner cases only
                FULL_RANGE,   //input comes from the entire range (corners included)
                WEIGHTED      //input chosen from corner and full_range using a dist
                } input_randomization_mode;

  //operation specific transactions (logical, add, sub ...)
  //contains the randomization_mode infestructure and
  //its children specify there own corner cases
  virtual class op_specific_trans extends general_trans;
    //By default use a weighted dist to set which catagory we get input from
    input_randomization_mode in_a_mode = WEIGHTED;
    input_randomization_mode in_b_mode = WEIGHTED;

    //which catagory inputs are constrained too
    typedef enum {CORNER, FULL} input_catagory;
    input_catagory in_a_cat;
    input_catagory in_b_cat;

    //look at the randomization mode, and return an input catagory
    function input_catagory catagory_select(input_randomization_mode input_mode);
      input_catagory cat;
      unique case(input_mode)
        CORNERS_ONLY: begin
          return CORNER;
        end
        FULL_RANGE: begin
          return FULL;
        end
        WEIGHTED: begin
          randcase
            2: return CORNER;
            1: return FULL;
          endcase
        end
      endcase
    endfunction

    //before randomization set the catagory inputs should be constrained too
    function void pre_randomize();
      in_a_cat = catagory_select(in_a_mode);
      in_b_cat = catagory_select(in_b_mode);
    endfunction
  endclass

  //transaction for logical operations (and, or ...)
  class logical_op_trans extends op_specific_trans;
    //constrain to corners, else us the full range
    constraint logical_op_inputs {
      if(in_a_cat == CORNER) {
        in_a inside {
          32'h0000_0000,
          32'h5555_5555,
          32'haaaa_aaaa,
          32'hffff_ffff
        };
      }

      if(in_b_cat == CORNER) {
        in_b inside {
          32'h0000_0000,
          32'h5555_5555,
          32'haaaa_aaaa,
          32'hffff_ffff
        };
      }
    }
  endclass

  //transaction for ADD ops
  class add_op_trans extends op_specific_trans;
    constraint add_op { alu_op == 4'b0010; }

    //constrain to corners, else us the full range
    constraint add_op_inputs {
      if(in_a_cat == CORNER) {
        in_a inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff
        };
      }

      if(in_b_cat == CORNER) {
        in_b inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff
        };
      }
    }
  endclass
  
  //SUB op transaction
  class sub_op_trans extends op_specific_trans;
    constraint sub_op { alu_op == 4'b0110; }

    //constrain to corners, else the whole range
    constraint sub_op_inputs {
      if(in_a_cat == CORNER) {
        in_a inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff,
          32'h7fff_ffff,
          32'h8000_0000
        };
      }

      if(in_b_cat == CORNER) {
        in_b inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff,
          32'h7fff_ffff,
          32'h8000_0000
        };
      }
    }

    /********* NOTE *************/
    //I Do this in post_rand instead of inside a constraint
    //because doing this
    //
    //in_a[31:0] dist {
    //  2'b00 := 1,
    //  2'b01 := 1,
    //  2'b10 := 1,
    //  2'b11 := 1,
    // }
    //
    //inside of a constraint was causing vivado to crash during elaboration
    //(I was getting a seg fault during the xelab call)
    //So its possible its a bug in the free version of vivado im using
    /****************************/
    function void post_randomize();
      //I want the full range of values to be spread evenly over 
      //High and low positive 2s comp values
      //and
      //High and low neg 2s comp values
      //So I set make sure the frist two msbs are evenly distributed
      if(in_a_cat == FULL) begin
        randcase
          1: in_a[31:30] = 2'b00;
          1: in_a[31:30] = 2'b01;
          1: in_a[31:30] = 2'b10;
          1: in_a[31:30] = 2'b11;
        endcase
      end

      if(in_b_cat == FULL) begin
        randcase
          1: in_b[31:30] = 2'b00;
          1: in_b[31:30] = 2'b01;
          1: in_b[31:30] = 2'b10;
          1: in_b[31:30] = 2'b11;
        endcase
      end
    endfunction
  endclass
endpackage
