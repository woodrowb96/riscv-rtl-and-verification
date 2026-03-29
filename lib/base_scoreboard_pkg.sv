/*
    Base scoreboard class for the verification library.

    Pure Virtual Tasks:
        - run()
            - User defined interface into the main testing loop (initiated by base_test::run(num_tests)).
            - Users use this task to score the expected transactions (sent from the predictor)
              against the actual transaction (sent from the monitor).
            - Users can increment base_scoreboard::num_fails to keep track of the number of failed tests.
            - By default base_scoreboard::num_tests is incremented automatically each time
              base_scoreboard::run() is called (so we assume only 1 test is scored per run() call).
            - This task will run once per iteration of the main testing loop.

    Virtual Tasks:
        - pre_run()
            - Automatically runs once before the main base_test::run() loop starts.
            - Empty by default. Users can override this and add their own logic.
        - post_run()
            - Automatically runs once after the main base_test::run() loop ends.
            - Empty by default. Users can override this and add their own logic.
        - scb()
            - Wrapper around base_scoreboard::run().
            - Called and looped in the main testing loop.
            - By default this task will increment num_tests after calling run(),
              but users can override this and implement any if needed.

    Member Functions:
        - print_fail(TRANS_T actual, TRANS_T expected, string msg = "")
            - Prints an error and the values of an actual and expected transaction.
        - print_results(string tag = this.tag, string msg = "")
            - Prints the current results (num_tests run and num_fails).
*/
package base_scoreboard_pkg;

  virtual class base_scoreboard #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t mon_to_scb_mbx;
    mailbox_t pred_to_scb_mbx;

    int num_tests = 0;
    int num_fails = 0;

    string tag;

    protected function new(string tag, mailbox_t mon_to_scb_mbx, mailbox_t pred_to_scb_mbx);
      this.tag = tag;
      this.mon_to_scb_mbx = mon_to_scb_mbx;
      this.pred_to_scb_mbx = pred_to_scb_mbx;
    endfunction

    pure virtual task run();

    virtual task pre_run();
      //empty by default
    endtask

    virtual task post_run();
      //empty by default
    endtask

    virtual task scb();
      run();
      num_tests++;
    endtask

    function void print_fail(TRANS_T actual, TRANS_T expected, string msg = "");
      $display("----------------");
      $error("[%s]: test fail", tag);
      if(msg != "") $display("%s", msg);
      expected.print("EXPECTED");
      actual.print("ACTUAL");
    endfunction

    function void print_results(string tag = this.tag, string msg = "");
      $display("----------------");
      $display("[%s]:", tag);
      if(msg != "") $display("%s", msg);
      $display("Test results:");
      $display("Total tests ran: %0d", num_tests);
      $display("Total tests failed: %0d", num_fails);
      $display("----------------");
    endfunction
  endclass

endpackage
