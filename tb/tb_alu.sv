// `timescale 1ns / 1ns

module tb_alu();

  //clock
  logic clk;
  initial clk = 0;
  always #1 clk = ~clk;

  //control
  logic [3:0] alu_op;

  //input
  logic [31:0] in_a;
  logic [31:0] in_b;

  //output
  logic [31:0] result;
  logic zero;

  task print_state(string msg = "");
    $display("-----------------------");
    $display(msg);
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
  endtask

  int num_tests = 0;
  int num_fails = 0;

  task automatic score_test(logic [31:0] expected);

    bit test_fail = 0;

    if(result != expected) begin
      $error("FAIL\nIncorect Result\nExpected: %h",expected);
      test_fail = 1;
    end

    if(zero != (result == '0)) begin
      $error("Zero flag incorect\nexpected: %b", result == '0);
      test_fail = 1;
    end

    if(test_fail) begin
      num_fails++;
      print_state();
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

  alu dut(.*);

  //bind assertions to the dut
  bind tb_alu.dut alu_assert dut_assert(.*);

  initial begin

    /*************  TEST AND ***************/

    alu_op = 4'b0000;
    in_a = 32'hffffffff;
    in_b = 32'h00000000;
    #1
    score_test(32'h00000000);
    #49

    alu_op = 4'b0000;
    in_a = 32'hffffffff;
    in_b = 32'h00ff00ff;
    #1
    score_test(32'h00ff00ff);
    #49

    /************   TEST OR *****************/
    alu_op = 4'b0001;
    in_a = 32'hffffffff;
    in_b = 32'h00000000;
    #1
    score_test(32'hffffffff);
    #49

    alu_op = 4'b0001;
    in_a = 32'h0f0f0f0f;
    in_b = 32'hffff0000;
    #1
    score_test(32'hffff0f0f);
    #49

    alu_op = 4'b0001;             //testing zero flag is set with OR op
    in_a = 32'h00000000;
    in_b = 32'h00000000;
    #1
    score_test(32'h00000000);
    #49

    /*****************  TEST ADD **************/
    alu_op = 4'b0010;
    in_a = 32'd5;
    in_b = 32'd6;
    #1
    score_test(32'd11);
    #49

    alu_op = 4'b0010;     //test zero flag with ADD op
    in_a = 32'd0;
    in_b = 32'd0;
    #1
    score_test(32'd0);
    #49
    
    alu_op = 4'b0010;     //test overflow
    in_a = 32'hffffffff;
    in_b = 32'd1;
    #1
    score_test(32'd0);    //result should overflow back to 0
    #49
    
    alu_op = 4'b0010;     //test overflow
    in_a = 32'hffffffff;
    in_b = 32'd400;
    #1
    score_test(32'd399);    //result should overflow to 399
    #49
    
    alu_op = 4'b0010;         //test overflow
    in_a = 32'hffffffff;
    in_b = 32'hffffffff;
    #1
    score_test(32'hfffffffe); //result should overflow to 1 less than max
    #49

    alu_op = 4'b0010;         //test adding 0
    in_a = 32'hffffffff;
    in_b = 32'd0;
    #1
    score_test(32'hffffffff); //shouldnt overflow
    #49

    /************ TEST SUB ****************/

    alu_op = 4'b0110;         //test sub, with pos result
    in_a = 32'd5;
    in_b = 32'd3;
    #1
    score_test(32'd2);
    #49
    
    alu_op = 4'b0110;         //test sub, with neg result
    in_a = 32'd5;
    in_b = 32'd6;
    #1
    score_test(-32'd1);
    #49
    
    alu_op = 4'b0110;         //test sub, positive from a neg
    in_a = -32'd5;
    in_b = 32'd6;
    #1
    score_test(-32'd11);
    #49
    
    alu_op = 4'b0110;         //test sub, neg from a neg
    in_a = -32'd15;
    in_b = -32'd9;
    #1
    score_test(-32'd6);       //result should still be neg
    #49
    
    alu_op = 4'b0110;         //test sub, neg from a neg
    in_a = -32'd53512;
    in_b = -32'd53513;
    #1
    score_test(32'd1);       //result should now be positive
    #49

    alu_op = 4'b0110;         //test subtracting from 0
    in_a = 32'd0;
    in_b = 32'd500;
    #1
    score_test(-32'd500);
    #49
    
    alu_op = 4'b0110;         //test subtracting 0
    in_a = 32'h80000000;      //in_a = max neg number
    in_b = 32'd0;             //in_b = 0
    #1
    score_test(32'h80000000);   //result should still be max neg number
    #49
    
    alu_op = 4'b0110;         //sub -1 from -1, shouldnt overflow
    in_a = 32'hffffffff;      //in_a = -1 in 2s compl
    in_b = 32'hffffffff;      //in_b = -1
    #1
    score_test(32'd0);        //result = -1 - -1 = 0
    #49
    
    alu_op = 4'b0110;         //test overflow (max_neg - 1 => overflow)
    in_a = 32'h80000000;      //in_a = max neg number
    in_b = 32'd1;             //in_b = 1
    #1
    score_test(32'h7fffffff);  //result should overflow to max pos num
    #49


    alu_op = 4'b0110;         //test overflow (max_pos - (-1) => overflow)
    in_a = 32'h7fffffff;      //in_a = max positive number
    in_b = -32'd1;            //in_b = -1
    #1
    score_test(32'h80000000);  //result should overflow to max neg
    #49

    alu_op = 4'b0110;         //test zero flag with sub op
    in_a = 32'd555121;
    in_b = 32'd555121;
    #1
    score_test(-32'd0);     //zero flag should be set
    #49
    
    /************ TEST INVALID OP ****************/
    
    alu_op = 4'b1110;         //not a valid operation
    in_a = 32'd5;
    in_b = 32'd2222;
    #1
    score_test(32'd0);     //result should be 0
    #49

    print_test_results();

    $stop(1);

  end

endmodule
