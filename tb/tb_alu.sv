`include "../coverage/tb_alu_coverage.sv"
// `timescale 1ns / 1ns

module tb_alu();
  alu_intf intf();

  //connect the dut to interface
  alu dut(.alu_op(intf.alu_op),
          .in_a(intf.in_a),
          .in_b(intf.in_b),
          .result(intf.result),
          .zero(intf.zero)
          );

  //bind assertions to the dut
  bind tb_alu.dut alu_assert dut_assert(intf.assertion);

  //coverage
  tb_alu_coverage coverage;

  //A general transaction 
  typedef enum {TRUE, FALSE} include_invalid_ops;
  class general_trans;
    rand logic [3:0] alu_op;
    rand logic [31:0] in_a;
    rand logic [31:0] in_b;

    include_invalid_ops inc_inv_ops = FALSE;

    constraint valid_ops {
      (inc_inv_ops == FALSE) -> (alu_op inside {4'b0000, 4'b0001, 4'b0010, 4'b0110});
    }

    function void print(string msg = "");
      $display("-----------------------");
      $display("transaction:%s\n",msg);
      $display("time: %t", $time);
      $display("-----------------------");
      $display("alu_op: %b", alu_op);
      $display("-----------------------");
      $display("in_a: %h", in_a);
      $display("in_b: %h", in_b);
      $display("-----------------------");
    endfunction
  endclass

  typedef enum {CORNERS_ONLY, //input constrained to corner cases only
                FULL_RANGE,   //input comes from the entire range (corners included)
                WEIGHTED      //input chosen from corner and full_range cats using a dist
                } input_rand_mode;

  virtual class op_specific_trans extends general_trans;
    typedef enum {CORNER, FULL} input_catagory;

    input_catagory in_a_cat;
    input_catagory in_b_cat;

    input_rand_mode in_a_mode = WEIGHTED;
    input_rand_mode in_b_mode = WEIGHTED;

    function input_catagory cat_select(input_rand_mode input_mode);
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

    function void pre_randomize();
      in_a_cat = cat_select(in_a_mode);
      in_b_cat = cat_select(in_b_mode);
    endfunction
  endclass

  class logical_op_trans extends op_specific_trans;
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

  class add_op_trans extends op_specific_trans;

    constraint add_op { alu_op == 4'b0010; }

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

  class sub_op_trans extends op_specific_trans;
    constraint sub_op { alu_op == 4'b0110; }

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

    function void post_randomize();
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

  task drive(general_trans trans);
    intf.alu_op = trans.alu_op;
    intf.in_a = trans.in_a;
    intf.in_b = trans.in_b;
  endtask

  typedef struct {
    logic [31:0] result;
    logic zero;
  } expected_output;

  class reference_alu;
    function expected_output expected(logic [3:0] alu_op,
                                      logic [31:0] in_a,
                                      logic [31:0] in_b);
      logic [32:0] in_a_wide = {1'b0, in_a};
      logic [32:0] in_b_wide = {1'b0, in_b};
      logic [32:0] result_wide = '0;
      logic zero = 1'b0;

      expected_output exp;

      if(alu_op == 4'b0110) begin
        result_wide = in_a_wide - in_b_wide;
      end
      else if(alu_op == 4'b0010) begin
        result_wide = in_a_wide + in_b_wide;
      end
      else if(alu_op == 4'b0001) begin
        result_wide = in_a_wide | in_b_wide;
      end
      else if(alu_op == 4'b0000) begin
        result_wide = in_a_wide & in_b_wide;
      end

      if(result_wide[31:0] == '0) begin
        zero = 1'b1;
      end

      exp.result = result_wide[31:0];
      exp.zero = zero;

      return exp;
    endfunction
  endclass

  int num_tests = 0;
  int num_fails = 0;

  reference_alu ref_alu;

  task automatic score_test();

    bit test_fail = 0;
    expected_output expected = ref_alu.expected(intf.alu_op, intf.in_a, intf.in_b);

    if(intf.result != expected.result) begin
      $error("FAIL\nIncorect Result\nExpected: %h",expected.result);
      test_fail = 1;
    end

    if(intf.zero != expected.zero) begin
      $error("Zero flag incorect\nexpected: %b", expected.zero);
      test_fail = 1;
    end

    if(test_fail) begin
      num_fails++;
      intf.print_state();
    end

    num_tests++;
  endtask

  task print_test_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %d", num_tests);
    $display("Total tests failed: %d", num_fails);
    $display("----------------");
  endtask

  //we are going to need these kinds of transactions for our tests
  logical_op_trans logical_trans;
  add_op_trans add_trans;
  sub_op_trans sub_trans;
  general_trans gen_trans;

  initial begin
    //create coverage and connect it to the interface
    coverage = new(intf.coverage);

    //create the referance alu
    ref_alu = new();

    //create our transactions
    logical_trans = new();
    add_trans = new();
    sub_trans = new();
    gen_trans = new();

    /*************  TEST AND ***************/
    for(int i = 0; i < 1000; i++) begin
      assert(logical_trans.randomize() with { alu_op == 4'b0000; })
      drive(logical_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    /************   TEST OR *****************/
    for(int i = 0; i < 1000; i++) begin
      assert(logical_trans.randomize() with { alu_op == 4'b0001; });
      drive(logical_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    /*****************  TEST ADD **************/
    for(int i = 0; i < 1000; i++) begin
      assert(add_trans.randomize());
      drive(add_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    /************ TEST SUB ****************/
    for(int i = 0; i < 1000; i++) begin
      assert(sub_trans.randomize());
      drive(sub_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    /************ TEST EVERYTHING WITH COMP RAND ****************/
    for(int i = 0; i < 1000; i++) begin
      assert(gen_trans.randomize());
      drive(gen_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    /************ TEST INVALID OP ****************/
    gen_trans.inc_inv_ops = TRUE;
    for(int i = 0; i < 10; i++) begin
      assert(gen_trans.randomize() with { alu_op inside {4'b1111, 4'b1100, 4'b1010}; });
      drive(gen_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    print_test_results();

    $stop(1);
  end
endmodule
