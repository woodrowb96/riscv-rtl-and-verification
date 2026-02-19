import riscv_32i_defs_pkg::*;
import riscv_32i_config_pkg::*;
import riscv_32i_control_pkg::*;
import tb_data_mem_transaction_pkg::*;

module tb_data_mem();
  localparam int CLK_PERIOD = 10;
  localparam int PROPOGATION_DELAY = 3;

  //clk
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /************** INTERFACE *********/
  data_mem_intf intf(clk);

  /********* DUT ***********/
  data_mem dut(.clk(clk),
                .wr_sel(intf.wr_sel),
                .addr(intf.addr),
                .wr_data(intf.wr_data),
                .rd_data(intf.rd_data)
              );

  /*************  TASKS *********************/
  task drive(data_mem_trans trans);
    intf.wr_sel <= trans.wr_sel;
    intf.addr <= trans.addr;
    intf.wr_data <= trans.wr_data;
  endtask

  task monitor(data_mem_trans trans);
    trans.rd_data = intf.rd_data;
  endtask

  task test(data_mem_trans trans);
    drive(trans);
    #PROPOGATION_DELAY
    monitor(trans);
    score(trans);
    @(posedge clk);
    //TO DO: add a ref_model.update

  endtask

  int num_tests = 0;
  int num_fails = 0;

  function automatic void score(data_mem_trans actual);
    trans.print("ACTUAL");
  endfunction

  function void print_test_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %0d", num_tests);
    $display("Total tests failed: %0d", num_fails);
    $display("----------------");
  endfunction

  data_mem_trans trans;
  initial begin
    trans = new();

    print_test_results();

    $stop(1);
  end

endmodule

