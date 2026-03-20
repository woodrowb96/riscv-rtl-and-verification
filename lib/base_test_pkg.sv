/*
    Base test class for the verification library.

    Usage:
          In your child tests new():
              1. Call super.new() first (this creates the mailboxes)
              2. Construct and assign gen, drv, mon, scb, pred (pass mailboxes from super)
              3. Do any additional wiring for custom child level stuff (events, custom mailboxes ...)

    Pure Virtual Functions: NONE

    Member Functions:
          - run(int num_tests = -1)
                - run the test
                - Tests will run until:
                    - The number of transactions generated == num_tests OR
                    - gen.finished is set (if users dont specify a num_tests) OR
                    - we timeout
                - NOTE:
                  - mon.run() and pred.run() are not called at the same time as the other .run() functions.
                  - we wait until after the first drive transaction has been driven
                    into the DUT to start monitoring and predicting
          - pre_run()
                - runs once before the main run loop
                - forks each components pre_run() function and waits for them all to return
          - post_run()
                - runs once after the main run loop
                - forks each components post_run() function and waits for them all to return
          - print_results(string msg = "")
                - print total number of tests ran and total number of failed tests
*/
package base_test_pkg;

  virtual class base_test #(parameter type TRANS_T, GEN_T, DRV_T, MON_T, PRED_T, SCB_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t gen_to_drv_mbx;
    mailbox_t mon_to_scb_mbx;
    mailbox_t pred_to_scb_mbx;

    string tag;

    int timeout;

    GEN_T  gen;
    DRV_T  drv;
    MON_T  mon;
    PRED_T pred;
    SCB_T  scb;

    protected function new(string tag, int timeout = 1000000);
      this.tag = tag;
      this.timeout = timeout;
      gen_to_drv_mbx  = new();
      mon_to_scb_mbx  = new();
      pred_to_scb_mbx = new();
    endfunction

    task run(int num_tests = -1);
      pre_run();

      fork begin

        //run the tests
        fork
          if(num_tests >= 0) repeat(num_tests)    gen.run();  //leave fork after we gen num_tests
          else               while(!gen.finished) gen.run();  //OR gen sets the finished flag
          forever drv.run();
          begin
            wait(drv.drv_started); //delay monitoring until the first drive has been driven
            forever mon.run();
          end
          begin
            wait(drv.drv_started); //delay prediction until the first drive has been driven
            forever pred.run();
          end
          forever scb.run();
          #timeout $fatal(1, "[%s]: Timeout during base_test.run(), scb.num_tests=%0d",
                          tag, scb.num_tests);
        join_any

        //wait till we score everything or timeout
        fork
          wait(scb.num_tests == gen.num_transactions);
          #timeout $fatal(1, "[%s]: Timeout waiting for scoreboard, scb.num_tests=%0d",
                          tag, scb.num_tests);
        join_any

        //cleanup the remaining forks
        disable fork; //(only disables whats in this main fork-join block)

      end join

      post_run();
    endtask

    task pre_run();
      fork
        gen.pre_run();
        drv.pre_run();
        mon.pre_run();
        pred.pre_run();
        scb.pre_run();
      join
    endtask

    task post_run();
      fork
        gen.post_run();
        drv.post_run();
        mon.post_run();
        pred.post_run();
        scb.post_run();
      join
    endtask


    function void print_results(string msg = "");
      scb.print_results(this.tag, msg);
    endfunction
  endclass

endpackage
