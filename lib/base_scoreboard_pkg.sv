/*
  Base scoreboard class for the verification library.

  Pure Virtual Functions:
    - bit score()
        - User defined interface into the run() function
        - Users use this function to score each test
        - This function will run once per run() (scb.run() is being looped in the base_test)
        - RETURN:
            - 1 if test passed
            - 0 if test failed
  Member Functions:
      - run()
          - Gets trans from the monitor mailbox and passes it to score(), increments num_tests, increments num_fails if test failed
          - Called and looped in the base_test
      - print_fail(TRANS_T actual, TRANS_T expected, string msg = "")
          - Prints an error and the values of an actual and expected transaction
      - print_results(string tag = this.tag, string msg = "")
          - Prints the current results (num_tests run and num_fails)

    NOTE: score() is currently a function. So if a user needs a time-consuming operation
          they are not currently able to use it. For now im choosing to keep it as a function
          to simplify the interface, but in the future if I encounter a scenario where I need
          time-consuming ops ill convert it to a task with output arguments.
*/
package base_scoreboard_pkg;

  virtual class base_scoreboard #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t mon_to_scb_mbx;

    int num_tests = 0;
    int num_fails = 0;

    string tag;

    protected function new(string tag, mailbox_t mon_to_scb_mbx);
      this.tag = tag;
      this.mon_to_scb_mbx = mon_to_scb_mbx;
    endfunction

    pure virtual function bit score(input TRANS_T actual);

    task run();
      TRANS_T actual;
      mon_to_scb_mbx.get(actual);

      if(!score(actual)) begin
        num_fails++;
      end

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
