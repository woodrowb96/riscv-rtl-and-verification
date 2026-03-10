package base_scoreboard_pkg;

  virtual class base_scoreboard #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t mon_to_scb_mbx;

    int num_tests = 0;
    int num_fails = 0;

    protected function new(mailbox_t mon_to_scb_mbx);
      this.mon_to_scb_mbx = mon_to_scb_mbx;
    endfunction

    pure virtual function bit compare(input TRANS_T actual);

    task run();
      TRANS_T actual;
      mon_to_scb_mbx.get(actual);

      if(!compare(actual)) begin
        num_fails++;
      end

      num_tests++;
    endtask

    function void print_fail(TRANS_T actual, TRANS_T expected, string tag = "");
      $display("----------------");
      $error("[%s]: test fail", tag);
      expected.print("EXPECTED");
      actual.print("ACTUAL");
    endfunction

    function void print_results(string tag = "", string msg = "");
      $display("----------------");
      if(tag != "") $display("[%s]:", tag);
      if(msg != "") $display("%s", msg);
      $display("Test results:");
      $display("Total tests ran: %0d", num_tests);
      $display("Total tests failed: %0d", num_fails);
      $display("----------------");
    endfunction
  endclass

endpackage
