// `timescale 1ns / 10ps

module tb_register_file();

  //clock
  logic clk;
  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  register_file_intf intf(clk);

  //reference reg file to hold expected values
  class ref_reg_file;
    logic [31:0] expected [0:31];

    function void write(logic [4:0] index, logic [31:0] data);
      //dont overwrite x0
      if(index != 0) begin
        expected[index] = data;
      end

      //make sure expected x0 is still 0
      exp_x0_wr_check: assert(expected[0] === 0)
        else $fatal(1, "REF_REG_FILE::write(): expected x0 != 0");
    endfunction

    function logic[31:0] read(logic [4:0] index);
      //reads from x0 should always return 0
      if(index == 0) begin
        return 0;
      end

      //if we dont read from x0
      return expected[index];
    endfunction

    function new();
      //x0 should always have an exp val of 0
      expected[0] = 0;
    endfunction
  endclass

  task drive(logic wr_en, logic [4:0] wr_reg, logic [31:0] wr_data);
    intf.wr_en <= wr_en;
    intf.wr_reg <= wr_reg;
    intf.wr_data <= wr_data;
    @(posedge clk)
    if(wr_en) begin
      ref_reg(wr_reg, wr_data);
    end
    wr_en <= 0;
  endtask
//
//
//   //test scoring
//   int num_tests = 0;
//   int num_fails = 0;
//
//   //score test by making sure rd_data matches expected values
//   task automatic score_test();
//     bit test_fail = 0;
//
//     //check rd_data_1
//     if(rd_data_1 != expected[rd_reg_1]) begin
//       $error(
//         "FAIL:\n",
//         "Incorrect rd_data_1\n",
//         "Expected: %h\n",
//         "Actual: %h\n", 
//         expected[rd_reg_1],
//         rd_data_1
//       );
//       test_fail = 1;
//     end
//
//     //check rd_data_2
//     if(rd_data_2 != expected[rd_reg_2]) begin
//       $error(
//         "FAIL:\n",
//         "Incorrect rd_data_2\n",
//         "Expected: %h\n",
//         "Actual: %h\n", 
//         expected[rd_reg_2],
//         rd_data_2
//       );
//       test_fail = 1;
//     end
//
//     //handle failed test
//     if(test_fail) begin
//       num_fails++;
//     end
//
//     num_tests++;
//   endtask
//
//   task print_test_results();
//     $display("----------------");
//     $display("Test results:");
//     $display("Total tests ran: %d", num_tests);
//     $display("Total tests failed: %d", num_fails);
//     $display("----------------");
//   endtask
//
//   //dut
//   register_file dut(.*);
//
//   //bind assertions to dut
//   bind tb_register_file.dut register_file_assert dut_assert(.*);
//
//  //instantiate coverage module
//   bind tb_register_file tb_register_file_coverage cov(.*);
//
//   initial begin
//
//     //drive initial values
//     wr_en <= '0;             //start out not writing
//     rd_reg_1 <= '0;          //reading from x0
//     rd_reg_2 <= '0;
//     wr_reg <= 'd0;           //pointing wr_reg to x0
//     wr_data <= 32'hFFFFFFFF; //driving wr_data to all 1s
//
//
//     /*********************** DIRECTED TESTS ***********************************/
//
//     //test reading x0
//     @(posedge clk);
//     rd_reg_1 <= 5'd0;
//     rd_reg_2 <= 5'd0;
//     score_test();      //read regs should output 0
//
//     //test read after write using rd_reg_1
//     write_reg_file(5'd5);
//     rd_reg_1 <= 5'd5;
//     rd_reg_2 <= 5'd0;
//     score_test();
//
//     //test read after write using rd_reg_2
//     write_reg_file(5'd15, 32'hFFFF0000);
//     rd_reg_1 <= 5'd5;
//     rd_reg_2 <= 5'd15;
//     score_test();
//
//     //test overwritting data in a register
//     write_reg_file(5'd15, 32'h0000FFFF);
//     rd_reg_1 <= 5'd5;
//     rd_reg_2 <= 5'd15;
//     score_test();
//
//     //test data persistance
//     @(posedge clk)            //dont write
//     rd_reg_1 <= 5'd5;         //dont change rd_reg_1 or 2
//     rd_reg_2 <= 5'd15;
//     score_test();             //read output should stay constant
//
//     //test attempting to write to x0
//     write_reg_file(5'd0, 32'hFFFFFFFF);  //write should not work
//     rd_reg_1 <= 5'd0;
//     rd_reg_2 <= 5'd0;
//     score_test();                        //should output 0
//
//     //test attempting to writting 0 to a register
//     write_reg_file(5'd3, '0);  //write should not work
//     rd_reg_1 <= 5'd3;
//     rd_reg_2 <= 5'd3;
//     score_test();                        //should output 0
//
//     //test reading all 1s out of both registers
//     write_reg_file(5'd20, 32'hFFFFFFFF);  //write should not work
//     rd_reg_1 <= 5'd20;
//     rd_reg_2 <= 5'd20;
//     score_test();                        //should output 0
//
//
//     /*********************** RANDOM TESTING ***********************************/
//
//     for(int i = 0; i < 1000; i++) begin
//       write_reg_file(
//         .register($urandom()),         //write to a rand reg
//         .data_in($urandom()),          //write rand data
//         .enable($urandom_range(1, 0))  //enable write randomly
//         );
//       rd_reg_1 <= $urandom();          //read from random registers
//       rd_reg_2 <= $urandom();
//       score_test();
//     end
//
//     //print results and end simulation
//     print_test_results();
//     $stop(1);
//   end



endmodule
