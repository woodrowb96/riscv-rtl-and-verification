package base_test_pkg;
  import base_generator_pkg::*;
  import base_driver_pkg::*;
  import base_monitor_pkg::*;
  import base_scoreboard_pkg::*;

  virtual class base_test #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t gen_to_drv_mbx;
    mailbox_t mon_to_scb_mbx;

    string tag;
    int timeout;

    base_generator  #(TRANS_T) gen;
    base_driver     #(TRANS_T) drv;
    base_monitor    #(TRANS_T) mon;
    base_scoreboard #(TRANS_T) scb;

    protected function new(string tag, int timeout = 1000000);
      this.tag = tag;
      this.timeout = timeout;
      gen_to_drv_mbx = new();
      mon_to_scb_mbx = new();
    endfunction

    task run(int num_tests = -1);
      fork  //run the tests
        if(num_tests >= 0) repeat(num_tests)    gen.run();
        else              while(!gen.finished) gen.run();
        forever           drv.run();
        forever           mon.run();
        forever           scb.run();
        #timeout $fatal(1, "[%s]: Timeout during base_test.run(), scb.num_tests=%0d", tag, scb.num_tests);
      join_any

      fork  //wait till we score everthing or timeout
        wait(scb.num_tests == gen.num_transactions);
        #timeout $fatal(1, "[%s]: Timeout waiting for scoreboard, scb.num_tests=%0d", tag, scb.num_tests);
      join_any

      disable fork;   //cleanup all the remaining processes
    endtask

    function void print_results();
      scb.print_results(tag);
    endfunction

  endclass

endpackage
