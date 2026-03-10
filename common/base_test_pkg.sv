package base_test_pkg;
  import base_transaction_pkg::*;
  import base_generator_pkg::*;
  import base_driver_pkg::*;
  import base_monitor_pkg::*;
  import base_scoreboard_pkg::*;

  virtual class base_test;
    typedef mailbox #(base_transaction) mailbox_t;
    mailbox_t gen_to_drv_mbx;
    mailbox_t mon_to_scb_mbx;

    string tag;
    int timeout;

    base_generator  gen;
    base_driver     drv;
    base_monitor    mon;
    base_scoreboard scb;

    task run(int num_tests);
      //run the test
      fork
        repeat(num_tests) gen.run();
        forever           drv.run();
        forever           mon.run();
        forever           scb.run();
      join_any

      //wait till we score everything, or we timeout
      fork
        wait(scb.num_tests == num_tests);
        #timeout $fatal(1, "[%s]: Timeout waiting for scoreboard, scb.num_tests=%0d", tag, scb.num_tests);
      join_any

      //cleanup the remaining processes and print results
      disable fork;
      scb.print_results(tag);
    endtask

    protected function new(string tag, int timeout = 1000000);
      this.tag = tag;
      this.timeout = timeout;
      gen_to_drv_mbx = new();
      mon_to_scb_mbx = new();
    endfunction
  endclass

endpackage
